#!/usr/bin/env python3
"""Stage WorkflowHub submissions from workflowhub.manifest.yml.

For each selected manifest entry it builds <out>/<key>/ containing a copy of the
flavour folder (minus hidden files, tests and `exclude` globs), any `extra`
files (e.g. a shared environment.yml), and a fresh ro-crate-metadata.json with
the entry's exact isBasedOn, the given version, authors, license and the
WorkflowHub language entity for the flavour. It then writes <out>/index.json
(read by wfh_submit.py) and .workflowhub.yml (the official submission-action
format, kept for compatibility).

Hidden files are skipped by default. To publish one (e.g. dna_helparms'
.curvesplus/), list it under the entry's `include:` (paths relative to the flavour
folder) or, when it lives outside the folder, under `extra:` (`from` may be a
folder; it is copied recursively under `to`). They travel as real files listed in
hasPart: WorkflowHub reads every hasPart file present in the zip (wfh_submit.py zips
everything; only submission-action@v0's packing dropped hidden files). Links to
remote files are NOT turned into files by WorkflowHub's crate submission (tested
2026-11-24), so there is no `remote:` option any more.

Markdown files are copied with their RELATIVE images and links that point outside the
crate (e.g. the header <img src="../../common/images/docker.png"> of every README, or
[tests](../tests/python)) rewritten to absolute GitHub URLs (raw.githubusercontent.com
for images, github.com/.../blob|tree/<branch>/ for links), so they still work on
WorkflowHub. Links to files inside the crate stay relative. The repo is not changed.

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


REL_URL = re.compile(r'(?P<pre>\b(?:src|href)=")(?P<u>[^"]+)(?P<post>")'
                     r'|(?P<mpre>\]\()(?P<mu>[^)\s]+)(?P<mpost>[)\s])')


def github_base(repo, path, m):
    """(https://github.com/org/repo, branch, path inside that repo) for a repo-relative path;
    a submodule's own repository when the path is inside one."""
    cp = configparser.ConfigParser()
    cp.read(os.path.join(repo, ".gitmodules"))
    for sec in cp.sections():
        sp, url = cp[sec].get("path", ""), cp[sec].get("url", "")
        if sp and (path == sp or path.startswith(sp + "/")):
            return url.removesuffix(".git").rstrip("/"), cp[sec].get("branch", "main"), path[len(sp):].strip("/")
    r = m.get("repository") or {}
    return (r.get("url", "https://github.com/bioexcel/biobb_workflows").rstrip("/"),
            r.get("branch", "main"), path)


def absolutize_markdown(text, md_repo_path, entry_path, staged, repo, m):
    """Rewrite relative URLs that leave the crate to absolute GitHub URLs."""
    count = 0

    def fix(match):
        nonlocal count
        img = match.group("pre") is not None and match.group("pre").startswith("src")
        is_md = match.group("mu") is not None
        u = match.group("mu") if is_md else match.group("u")
        if re.match(r"^([a-z][a-z0-9+.-]*:|#|/)", u, re.I):
            return match.group(0)
        path, frag = (u.split("#", 1) + [""])[:2]
        target = os.path.normpath(os.path.join(os.path.dirname(md_repo_path), path)).replace(os.sep, "/")
        inside = os.path.relpath(target, entry_path).replace(os.sep, "/")
        if not inside.startswith("..") and (inside in staged or any(f.startswith(inside + "/") for f in staged)):
            return match.group(0)
        base, branch, inner = github_base(repo, target, m)
        if is_md:  # markdown: image if preceded by "!"
            start = match.start()
            img = start > 0 and "![" in match.string[max(0, match.string.rfind("[", 0, start) - 1):start + 1]
        if img:
            new = base.replace("https://github.com/", "https://raw.githubusercontent.com/") + f"/{branch}/{inner}"
        else:
            kind = "tree" if os.path.isdir(os.path.join(repo, target)) else "blob"
            new = f"{base}/{kind}/{branch}/{inner}" + (f"#{frag}" if frag else "")
        count += 1
        if is_md:
            return f"{match.group('mpre')}{new}{match.group('mpost')}"
        return f"{match.group('pre')}{new}{match.group('post')}"

    return REL_URL.sub(fix, text), count


def license_ids(lic):
    if not lic:
        return None, None
    lic = str(lic)
    spdx = lic.rstrip("/").split("/")[-1]
    return (lic if lic.startswith("http") else f"https://spdx.org/licenses/{spdx}"), spdx


def write_crate(dst, e, files, version, defaults):
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
        "mainEntity": {"@id": main}, "hasPart": [{"@id": f} for f in files],
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
                if not os.path.exists(os.path.join(a.repo, x["from"])):
                    problems.append(f"extra not found: {x['from']}")
            if e["isBasedOn"] in shared:
                problems.append("isBasedOn shared by entries " + ", ".join(shared[e["isBasedOn"]])
                                + ": WorkflowHub would reject them all; give each its own source link")
            for inc in e.get("include") or []:
                if not os.path.exists(os.path.join(src, inc)):
                    problems.append(f"include not found: {e['path']}/{inc}")
        if problems:
            errors.append((key, e.get("name"), problems))
            continue
        dst = os.path.join(out_abs, key)
        if a.dry_run:
            files = [f for f in copy_tree_list(src, patterns)]
        else:
            os.makedirs(dst)
            files = copy_tree(src, dst, patterns)
        # extra (out-of-folder, may be a folder) and include (hidden, inside the folder):
        # both copied with every file, hidden ones too
        extra_src = {}
        pairs = [(os.path.join(a.repo, x["from"]), x.get("to") or os.path.basename(x["from"].rstrip("/")))
                 for x in e.get("extra") or []]
        pairs += [(os.path.join(src, inc), inc.rstrip("/")) for inc in e.get("include") or []]
        for from_abs, to in pairs:
            if os.path.isdir(from_abs):
                items = [(os.path.join(r, f), os.path.join(to, os.path.relpath(os.path.join(r, f), from_abs)))
                         for r, _, fs in os.walk(from_abs) for f in fs]
            else:
                items = [(from_abs, to)]
            for f_abs, f_rel in items:
                f_rel = f_rel.replace(os.sep, "/")
                extra_src[f_rel] = f_abs
                if not a.dry_run:
                    os.makedirs(os.path.dirname(os.path.join(dst, f_rel)) or dst, exist_ok=True)
                    shutil.copy2(f_abs, os.path.join(dst, f_rel))
                if f_rel not in files:
                    files.append(f_rel)
        files = sorted(set(files))
        if not a.dry_run:
            for f in files:
                if f.endswith(".md") and f not in extra_src:
                    fp = os.path.join(dst, f)
                    text = open(fp, encoding="utf-8").read()
                    new, n = absolutize_markdown(text, f"{e['path']}/{f}", e["path"], set(files), a.repo, m)
                    if n:
                        open(fp, "w", encoding="utf-8").write(new)
        # size of what is actually sent: folder files + extra/include files
        size = sum(os.path.getsize(extra_src[f] if f in extra_src else os.path.join(src, f))
                   for f in files if os.path.isfile(extra_src.get(f, os.path.join(src, f))))
        if not a.dry_run:
            write_crate(dst, e, files, a.version, defaults)
        staged.append((key, e, len(files), size))

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
