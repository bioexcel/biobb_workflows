#!/usr/bin/env python3
"""Stage WorkflowHub submissions from workflowhub.manifest.yml.

For each selected manifest entry it builds <out>/<key>/ containing a copy of the
flavour folder (minus hidden files, tests and `exclude` globs), any `extra`
files (e.g. a shared environment.yml), and a fresh ro-crate-metadata.json with
the entry's exact isBasedOn, the given version, authors, license and the
WorkflowHub language entity for the flavour. It then writes <out>/index.json
(read by wfh_submit.py) and .workflowhub.yml (the official submission-action
format, kept for compatibility).

Hidden files (e.g. dna_helparms' .curvesplus/) cannot travel inside the crate
zip (the RO-Crate libraries skip them), so an entry's `remote:` list adds them
as links to the file on GitHub (blob/<branch>), as the existing entries do.

An isBasedOn shared by several non-skipped entries would make WorkflowHub reject
the submission: ALL entries sharing it are skipped, not only the second one.

Usage:
  python3 wfh_stage.py --version 2026.2 [--manifest workflowhub.manifest.yml] [--repo .]
                       [--out _wfh_stage] [--tutorial abc_setup] [--flavour jupyter,python]
                       [--ids 196,285] [--dry-run] [--keep-going]
  --keep-going   stage every entry that is ready and exit 0 even if some are not
                 (each problem is printed as a warning); default: exit 1 on any problem
Requires PyYAML (pip install pyyaml).
"""
import argparse
import configparser
import fnmatch
import json
import os
import re
import shutil
import sys

try:
    import yaml
except ImportError:
    sys.exit("PyYAML missing: pip install pyyaml")

# Language entities as WorkflowHub itself writes them (read from live entries, Nov 2026).
# WorkflowHub matches the workflow type by identifier first, then by name/alternateName.
LANGS = {
    "jupyter": {"@id": "#jupyter", "name": "Jupyter",
                "identifier": {"@id": "https://jupyter.org/"}, "url": {"@id": "https://jupyter.org/"}},
    "python": {"@id": "#python", "name": "Python",
               "identifier": {"@id": "https://www.python.org/"}, "url": {"@id": "https://www.python.org/"}},
    "docker": {"@id": "#docker", "name": "Docker", "alternateName": "Docker",
               "identifier": {"@id": "https://www.docker.com/"}, "url": {"@id": "https://www.docker.com/"}},
    "airflow": {"@id": "#apache_airflow", "name": "Apache Airflow", "alternateName": "Airflow",
                "identifier": {"@id": "airflow"}, "url": {"@id": "https://airflow.apache.org/"}},
    "cwl": {"@id": "#cwl", "name": "Common Workflow Language", "alternateName": "CWL",
            "identifier": {"@id": "https://w3id.org/cwl/v1.0/"}, "url": {"@id": "https://www.commonwl.org/"}},
    "nextflow": {"@id": "#nextflow", "name": "Nextflow",
                 "identifier": {"@id": "https://www.nextflow.io/"}, "url": {"@id": "https://www.nextflow.io/"}},
    "galaxy": {"@id": "#galaxy", "name": "Galaxy",
               "identifier": {"@id": "https://galaxyproject.org/"}, "url": {"@id": "https://galaxyproject.org/"}},
}
DEFAULT_EXCLUDE = ["tests", "__pycache__", "*.pyc", "ro-crate-metadata.json", "ro-crate-preview.html"]
WARN_MB = 50


def entry_key(e):
    if e.get("id"):
        return str(e["id"])
    return re.sub(r"[^A-Za-z0-9]+", "_", e["path"]).strip("_")


def excluded(rel, patterns):
    parts = rel.split("/")
    if any(p.startswith(".") for p in parts):
        return True
    return any(fnmatch.fnmatch(rel, pat) or any(fnmatch.fnmatch(p, pat) for p in parts) for pat in patterns)


def copy_tree(src, dst, patterns):
    copied = []
    for root, dirs, files in os.walk(src):
        rel_root = os.path.relpath(root, src).replace(os.sep, "/")
        rel_root = "" if rel_root == "." else rel_root + "/"
        dirs[:] = sorted(d for d in dirs if not excluded(rel_root + d, patterns))
        for f in sorted(files):
            rel = rel_root + f
            if excluded(rel, patterns):
                continue
            target = os.path.join(dst, rel)
            os.makedirs(os.path.dirname(target), exist_ok=True)
            shutil.copy2(os.path.join(root, f), target)
            copied.append(rel)
    return copied


def github_base(repo, path, m):
    """(base_url, branch, path_inside_that_repo) for a repo-relative path: a submodule's own
    repo when the path is inside one, else the manifest's repository (default branch)."""
    cp = configparser.ConfigParser()
    cp.read(os.path.join(repo, ".gitmodules"))
    for sec in cp.sections():
        sp, url = cp[sec].get("path", ""), cp[sec].get("url", "")
        if sp and (path == sp or path.startswith(sp + "/")):
            return (url.removesuffix(".git").rstrip("/"), cp[sec].get("branch", "main"),
                    path[len(sp):].strip("/"))
    r = m.get("repository") or {}
    return (r.get("url", "https://github.com/bioexcel/biobb_workflows").rstrip("/"),
            r.get("branch", "main"), path)


def remote_entities(repo, e, m):
    """[(url, name)] for the entry's `remote:` paths (files, or folders expanded recursively,
    hidden files included)."""
    out = []
    for p in e.get("remote") or []:
        full = os.path.join(repo, p)
        files = []
        if os.path.isdir(full):
            for root, _, fs in os.walk(full):
                files += [os.path.relpath(os.path.join(root, f), repo) for f in fs]
        elif os.path.isfile(full):
            files = [p]
        else:
            raise FileNotFoundError(p)
        for f in sorted(files):
            base, branch, inner = github_base(repo, f.replace(os.sep, "/"), m)
            name = os.path.relpath(f, os.path.join(repo, e["path"])) if f.startswith(e["path"]) \
                else os.path.relpath(f, os.path.dirname(p.rstrip("/")) or ".")
            out.append((f"{base}/blob/{branch}/{inner}", name.replace(os.sep, "/")))
    return out


def license_ids(lic):
    if not lic:
        return None, None
    lic = str(lic)
    spdx = lic.rstrip("/").split("/")[-1]
    return (lic if lic.startswith("http") else f"https://spdx.org/licenses/{spdx}"), spdx


def write_crate(dst, e, files, version, defaults, remotes=()):
    flav = e["flavour"]
    if flav not in LANGS:
        raise ValueError(f"unknown flavour {flav!r}; add it to LANGS")
    main = e["main"]
    lic_url, spdx = license_ids(e.get("license") or defaults.get("license"))
    root = {
        "@id": "./", "@type": "Dataset",
        "conformsTo": [{"@id": "https://w3id.org/ro/crate/1.1"},
                       {"@id": "https://w3id.org/workflowhub/workflow-ro-crate/1.0"}],
        "name": e["name"], "isBasedOn": e["isBasedOn"], "version": str(version),
        "mainEntity": {"@id": main}, "hasPart": [{"@id": f} for f in files] + [{"@id": u} for u, _ in remotes],
    }
    if e.get("description"):
        root["description"] = e["description"]
    graph = [{"@id": "ro-crate-metadata.json", "@type": "CreativeWork",
              "conformsTo": {"@id": "https://w3id.org/ro/crate/1.1"}, "about": {"@id": "./"}}, root]
    if lic_url:
        root["license"] = {"@id": lic_url}
        graph.append({"@id": lic_url, "@type": "CreativeWork", "name": spdx, "identifier": spdx})
    people = []
    for i, p in enumerate(e.get("authors") or defaults.get("authors") or []):
        pid = p.get("orcid") or f"#person-{i + 1}"
        people.append({"@id": pid})
        graph.append({"@id": pid, "@type": "Person", "name": p["name"]})
    if people:
        root["author"] = people
        root["creator"] = people
    lang = dict(LANGS[flav], **{"@type": "ComputerLanguage"})
    for f in files:
        ent = {"@id": f, "@type": "File"}
        if f == main:
            ent = {"@id": f, "@type": ["File", "SoftwareSourceCode", "ComputationalWorkflow"],
                   "name": e["name"], "programmingLanguage": {"@id": lang["@id"]}}
            if people:
                ent["author"] = people
        graph.append(ent)
    for url, name in remotes:
        graph.append({"@id": url, "@type": "File", "name": name})
    graph.append(lang)
    with open(os.path.join(dst, "ro-crate-metadata.json"), "w", encoding="utf-8") as fh:
        json.dump({"@context": "https://w3id.org/ro/crate/1.1/context", "@graph": graph},
                  fh, indent=2, ensure_ascii=False)
        fh.write("\n")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--version", required=True, help="Version name for every staged entry (e.g. the release tag)")
    ap.add_argument("--manifest", default="workflowhub.manifest.yml")
    ap.add_argument("--repo", default=".")
    ap.add_argument("--out", default="_wfh_stage", help="Staging folder inside the repo (not hidden)")
    ap.add_argument("--tutorial", help="comma-separated substrings matched against entry paths")
    ap.add_argument("--flavour", help="comma-separated flavours, e.g. jupyter,python,cwl,airflow,nextflow,docker")
    ap.add_argument("--ids", help="comma-separated WorkflowHub entry ids")
    ap.add_argument("--dry-run", action="store_true", help="validate and list, write nothing")
    ap.add_argument("--keep-going", action="store_true", help="stage what is ready, exit 0 despite problems")
    a = ap.parse_args()
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._\-]*", a.version):
        sys.exit(f"bad version name {a.version!r} (letters, digits, . _ - only)")

    with open(a.manifest, encoding="utf-8") as fh:
        m = yaml.safe_load(fh)
    defaults = m.get("defaults") or {}
    patterns = DEFAULT_EXCLUDE + list(m.get("exclude") or [])
    sel = m.get("workflows") or []
    if a.ids:
        want = {s.strip() for s in a.ids.split(",") if s.strip()}
        sel = [e for e in sel if str(e.get("id")) in want]
    if a.flavour:
        want = {s.strip() for s in a.flavour.split(",") if s.strip()}
        sel = [e for e in sel if e.get("flavour") in want]
    if a.tutorial:
        subs = [s.strip() for s in a.tutorial.split(",") if s.strip()]
        sel = [e for e in sel if any(s in str(e.get("path")) for s in subs)]
    sel = [e for e in sel if not e.get("skip")]
    # source links used by more than one non-skipped entry of the WHOLE manifest
    counts = {}
    for e in m.get("workflows") or []:
        if not e.get("skip") and e.get("isBasedOn"):
            counts.setdefault(e["isBasedOn"], []).append(str(e.get("id") or e.get("path")))
    shared = {k: v for k, v in counts.items() if len(v) > 1}

    errors, staged = [], []
    out_abs = os.path.join(a.repo, a.out)
    if not a.dry_run and os.path.isdir(out_abs):
        shutil.rmtree(out_abs)
    for e in sel:
        key = entry_key(e) if e.get("path") else str(e.get("id"))
        problems = []
        for field in ("path", "main", "isBasedOn", "name", "flavour"):
            if not e.get(field) or str(e.get(field)) == "TODO":
                problems.append(f"missing {field}")
        if not problems:
            src = os.path.join(a.repo, e["path"])
            if not os.path.isdir(src):
                problems.append(f"folder not found: {e['path']}")
            elif not os.path.isfile(os.path.join(src, e["main"])):
                problems.append(f"main file not found: {e['path']}/{e['main']}")
            for x in e.get("extra") or []:
                if not os.path.isfile(os.path.join(a.repo, x["from"])):
                    problems.append(f"extra file not found: {x['from']}")
            if e["isBasedOn"] in shared:
                problems.append("isBasedOn shared by entries " + ", ".join(shared[e["isBasedOn"]])
                                + ": WorkflowHub would reject them all; give each its own source link")
            try:
                remotes = remote_entities(a.repo, e, m)
            except FileNotFoundError as err:
                problems.append(f"remote path not found: {err}")
        if problems:
            errors.append((key, e.get("name"), problems))
            continue
        dst = os.path.join(out_abs, key)
        if a.dry_run:
            files = [f for f in copy_tree_list(src, patterns)]
        else:
            os.makedirs(dst)
            files = copy_tree(src, dst, patterns)
        for x in e.get("extra") or []:
            to = x.get("to") or os.path.basename(x["from"])
            if not a.dry_run:
                os.makedirs(os.path.dirname(os.path.join(dst, to)) or dst, exist_ok=True)
                shutil.copy2(os.path.join(a.repo, x["from"]), os.path.join(dst, to))
            if to not in files:
                files.append(to)
        files = sorted(set(files))
        # size of what is actually sent: folder files + extra files
        extra_src = {(x.get("to") or os.path.basename(x["from"])): os.path.join(a.repo, x["from"])
                     for x in e.get("extra") or []}
        size = sum(os.path.getsize(extra_src[f] if f in extra_src else os.path.join(src, f))
                   for f in files if os.path.isfile(extra_src.get(f, os.path.join(src, f))))
        if not a.dry_run:
            write_crate(dst, e, files, a.version, defaults, remotes)
        staged.append((key, e, len(files) + len(remotes), size))

    for key, e, n, size in staged:
        warn = f"  WARNING: {size / 1e6:.0f} MB" if size > WARN_MB * 1e6 else ""
        print(f"{'would stage' if a.dry_run else 'staged'} {key:>6}  {e['flavour']:<8} {n:>3} files  "
              f"{e['path']}  ->  {e['isBasedOn']}{warn}")
    for key, name, probs in errors:
        print(f"SKIPPED {key} ({name}): {'; '.join(probs)}", file=sys.stderr)
        if a.keep_going:
            print(f"::warning::WorkflowHub entry {key} not staged: {'; '.join(probs)}")

    if not a.dry_run:
        index = [{"key": k, "id": e.get("id"), "name": e["name"], "flavour": e["flavour"],
                  "path": e["path"], "isBasedOn": e["isBasedOn"], "dir": f"{a.out}/{k}"}
                 for k, e, *_ in staged]
        os.makedirs(out_abs, exist_ok=True)
        with open(os.path.join(out_abs, "index.json"), "w", encoding="utf-8") as fh:
            json.dump({"version": a.version, "team_id": m.get("team_id"),
                       "instance": m.get("instance"), "entries": index}, fh, indent=2)
        cfg = {"workflows": [{"path": f"{a.out}/{k}"} for k, *_ in staged]}
        if m.get("team_id"):
            cfg["team_id"] = m["team_id"]
        if m.get("instance"):
            cfg["instance"] = m["instance"]
        with open(os.path.join(a.repo, ".workflowhub.yml"), "w", encoding="utf-8") as fh:
            yaml.safe_dump(cfg, fh, sort_keys=False)
        print(f"Wrote .workflowhub.yml with {len(staged)} workflows (version {a.version})")
    if not staged:
        sys.exit("Nothing staged")
    if errors and not a.keep_going:
        sys.exit(1)


def copy_tree_list(src, patterns):
    out = []
    for root, dirs, files in os.walk(src):
        rel_root = os.path.relpath(root, src).replace(os.sep, "/")
        rel_root = "" if rel_root == "." else rel_root + "/"
        dirs[:] = [d for d in dirs if not excluded(rel_root + d, patterns)]
        out += [rel_root + f for f in files if not excluded(rel_root + f, patterns)]
    return out


if __name__ == "__main__":
    main()
