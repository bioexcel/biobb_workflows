#!/usr/bin/env python3
"""Draft workflowhub.manifest.yml by listing a WorkflowHub team's entries and
matching each to a flavour folder in the local repo.

For every entry it reads the entry's live RO-Crate metadata to get the exact
source link (isBasedOn), main file, workflow type and authors. The source link
must be reproduced character for character in future crates, otherwise
WorkflowHub creates a duplicate entry instead of a new version.

Usage:
  python3 wfh_bootstrap.py --team 11 --repo . [--instance https://workflowhub.eu]
                           [--out workflowhub.manifest.yml] [--filter abc]
Standard library only. Unresolved entries are written with `path: TODO`.
"""
import argparse
import concurrent.futures as cf
import difflib
import json
import os
import re
import sys
import urllib.request

FLAVOUR_BY_CLASS = {
    "jupyter": "jupyter", "python": "python", "docker": "docker",
    "apache_airflow": "airflow", "airflow": "airflow", "cwl": "cwl",
    "nextflow": "nextflow", "galaxy": "galaxy",
}


def get_json(url):
    req = urllib.request.Request(url, headers={"Accept": "application/json",
                                               "User-Agent": "wfh-bootstrap"})
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.load(r)


def entry_info(instance, wid):
    meta = get_json(f"{instance}/workflows/{wid}")["data"]["attributes"]
    crate = get_json(f"{instance}/workflows/{wid}/ro_crate_metadata")
    g = {e.get("@id"): e for e in crate.get("@graph", [])}
    root = g.get("./", {})
    main = (root.get("mainEntity") or {}).get("@id")
    lang_ref = ((g.get(main) or {}).get("programmingLanguage") or {}).get("@id")
    lang = dict(g.get(lang_ref) or {})
    authors = []
    for ref in root.get("author") or root.get("creator") or []:
        p = g.get(ref.get("@id"), {})
        authors.append({"name": p.get("name"), "orcid": ref.get("@id")
                        if str(ref.get("@id", "")).startswith("https://orcid.org/") else None})
    lic = root.get("license")
    if isinstance(lic, dict):
        lic = lic.get("@id")
    versions = meta.get("versions") or []
    return {
        "id": int(wid),
        "title": meta.get("title"),
        "class": (meta.get("workflow_class") or {}).get("key"),
        "isBasedOn": root.get("isBasedOn"),
        "main": main,
        "language": lang,
        "authors": authors,
        "license": lic,
        "latest_version": versions[-1]["version"] if versions else None,
    }


def tutorial_dirs(repo):
    return sorted(d for d in os.listdir(repo)
                  if d.startswith("biobb_wf_") and os.path.isdir(os.path.join(repo, d)))


def build_index(repo, tutorials):
    """{(flavour, filename): [dir relative to repo, ...]} for files under <tutorial>/<flavour>/."""
    index = {}
    for tut in tutorials:
        base = os.path.join(repo, tut)
        for root, dirs, files in os.walk(base):
            dirs[:] = [d for d in dirs if not d.startswith(".") and d != "tests"]
            rel = os.path.relpath(root, repo).replace(os.sep, "/")
            parts = rel.split("/")
            if len(parts) < 2:
                continue
            for f in files:
                index.setdefault((parts[1], f), []).append(rel)
    return index


def tokens(name):
    return {t for t in re.split(r"[^a-z0-9]+", name.lower()) if t and t not in ("biobb", "wf")}


def token_idf(tutorials):
    import math
    df = {}
    for t in tutorials:
        for tok in tokens(t):
            df[tok] = df.get(tok, 0) + 1
    n = len(tutorials) or 1
    return {tok: math.log(1 + n / c) for tok, c in df.items()}


def token_score(a, b, idf):
    """IDF-weighted Jaccard: rare tokens (abc, pmx) count more than md/setup."""
    ta, tb = tokens(a), tokens(b)
    w = lambda s: sum(idf.get(t, 3.0) for t in s)  # noqa: E731  unknown tokens are rare
    union = w(ta | tb)
    return w(ta & tb) / union if union else 0.0


def tutorial_key(info):
    """A biobb_wf_* style key from the source link path or, failing that, the title."""
    m = re.search(r"/(?:tree|blob)/[^/]+/(biobb_wf_[^/]+)", info["isBasedOn"] or "")
    if m:
        return m.group(1)
    m = re.search(r"github\.com/[^/]+/(biobb[_-]wf[^/]*)", info["isBasedOn"] or "")
    if m:
        return m.group(1).replace("-", "_")
    words = re.sub(r"(?i)^(jupyter notebook|python|docker|apache airflow|cwl|nextflow|galaxy)\s+", "",
                   info["title"] or "")
    return "biobb_wf_" + re.sub(r"[^a-z0-9]+", "_", words.lower().replace("tutorial", "")).strip("_")


def guess_path(repo, info, tutorials, index):
    """Return (path, note). Path is relative to repo or 'TODO'."""
    flav = FLAVOUR_BY_CLASS.get(info["class"] or "", info["class"])
    src = info["isBasedOn"] or ""
    m = re.search(r"github\.com/bioexcel/biobb_workflows/(?:tree|blob)/[^/]+/(.+?)/?$", src)
    if m and os.path.isdir(os.path.join(repo, m.group(1))):
        return m.group(1), "exact match of source link path"
    hits = sorted(set(index.get((flav, info["main"]), []))) if info["main"] else []
    if len(hits) == 1:
        return hits[0], "only folder of this flavour containing the main file"
    key = tutorial_key(info)
    if hits:
        stem = os.path.splitext(os.path.basename(info["main"]))[0]
        named = [h for h in hits if h.split("/")[0] == stem]
        if len(named) == 1:
            return named[0], "tutorial folder named like the main file"
        idf = token_idf(tutorials)
        scored = sorted(((token_score(key, h.split("/")[0], idf), h) for h in hits), reverse=True)
        (best, top), (second, _) = scored[0], scored[1]
        if best >= 0.6 and best - second >= 0.1:
            return top, f"best name match among {len(hits)} folders with {info['main']} (CHECK)"
        return "TODO", f"main file in several folders: {[h for _, h in scored[:4]]}"
    close = difflib.get_close_matches(key, tutorials, n=3, cutoff=0.5)
    cands = [f"{c}/{flav}" for c in close if os.path.isdir(os.path.join(repo, c, flav))]
    return "TODO", (f"main file {info['main']} not found; candidates: {cands}" if cands
                    else f"main file {info['main']} not found; no candidate folder")


NEW_FLAVOURS = ["jupyter", "python", "cwl", "airflow", "nextflow", "docker", "galaxy"]
FLAVOUR_TITLE = {"jupyter": "Jupyter Notebook", "python": "Python", "cwl": "CWL",
                 "airflow": "Apache Airflow", "nextflow": "Nextflow", "docker": "Docker", "galaxy": "Galaxy"}
MAIN_BY_FLAVOUR = {"python": "workflow.py", "cwl": "workflow.cwl", "nextflow": "main.nf", "docker": "Dockerfile"}


def read_gitmodules(repo):
    mods, cur = {}, None
    try:
        with open(os.path.join(repo, ".gitmodules"), encoding="utf-8") as fh:
            for line in fh:
                line = line.strip()
                if line.startswith("[submodule"):
                    cur = {}
                elif "=" in line and cur is not None:
                    k, v = (s.strip() for s in line.split("=", 1))
                    cur[k] = v
                    if "path" in cur and "url" in cur:
                        mods[cur["path"]] = (cur["url"].removesuffix(".git"), cur.get("branch", "main"))
    except FileNotFoundError:
        pass
    return mods


def repo_url(repo):
    import subprocess
    try:
        url = subprocess.run(["git", "-C", repo, "remote", "get-url", "origin"], capture_output=True,
                             text=True, check=True).stdout.strip()
        # the DEFAULT branch (origin/HEAD), never the branch checked out right now: source
        # links proposed from a feature branch (tree/fix/...) would be wrong forever
        head = subprocess.run(["git", "-C", repo, "symbolic-ref", "--short", "refs/remotes/origin/HEAD"],
                              capture_output=True, text=True).stdout.strip()
        branch = head.split("/", 1)[1] if "/" in head else "main"
    except Exception:  # noqa: BLE001
        return None
    url = re.sub(r"^git@github\.com:", "https://github.com/", url).removesuffix(".git")
    return url, branch


def source_link_for(path, submods, origin):
    for sp, (url, branch) in submods.items():
        if path == sp or path.startswith(sp + "/"):
            rest = path[len(sp):].strip("/")
            return f"{url}/tree/{branch}/{rest}" if rest else url
    if origin:
        return f"{origin[0]}/tree/{origin[1]}/{path}"
    return None


def find_env_file(repo, path, submods):
    """environment.yml for a notebook folder: in the folder itself (nothing to add), else at the
    submodule/repo root (conda_env/, binder/ or top level)."""
    if os.path.isfile(os.path.join(repo, path, "environment.yml")):
        return None
    roots = [sp for sp in submods if path == sp or path.startswith(sp + "/")]
    for root in roots + [""]:
        for cand in ("conda_env/environment.yml", "environment.yml", "binder/environment.yml"):
            rel = f"{root}/{cand}" if root else cand
            if os.path.isfile(os.path.join(repo, rel)):
                return rel
    return None


def propose_main(repo, tut, flav, index):
    base = f"{tut}/{flav}"
    if flav == "jupyter":
        hits = sorted(set(index.get(("jupyter", f"{tut}.ipynb"), [])))
        if len(hits) == 1:
            return hits[0], f"{tut}.ipynb"
        return "TODO", None
    if flav == "airflow":
        cands = [f for f in os.listdir(os.path.join(repo, base)) if f.endswith(".py")]
        return base, (f"{tut}.py" if f"{tut}.py" in cands else (cands[0] if len(cands) == 1 else None))
    if flav == "galaxy":
        cands = [f for f in os.listdir(os.path.join(repo, base)) if f.endswith(".ga")]
        return base, (cands[0] if len(cands) == 1 else None)
    main = MAIN_BY_FLAVOUR.get(flav)
    return base, (main if main and os.path.isfile(os.path.join(repo, base, main)) else None)


def proposed_name(flav, tut, sibling):
    if sibling and sibling.get("title"):
        rest = re.sub(r"(?i)^(jupyter notebook|python|docker|apache airflow|cwl|nextflow|galaxy)\s+", "",
                      sibling["title"])
        return f"{FLAVOUR_TITLE[flav]} {rest}"
    return f"{FLAVOUR_TITLE[flav]} {tut.replace('biobb_wf_', '').replace('_', ' ')} tutorial"


def yaml_str(v):
    if v is None:
        return "null"
    s = str(v)
    if re.match(r"^[A-Za-z0-9_./:@+-][A-Za-z0-9_ ./:@+()-]*$", s) and ": " not in s and not s.endswith(":"):
        return s
    return json.dumps(s, ensure_ascii=False)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--team", required=True, type=int)
    ap.add_argument("--repo", default=".")
    ap.add_argument("--instance", default="https://workflowhub.eu")
    ap.add_argument("--out", default="workflowhub.manifest.yml")
    ap.add_argument("--filter", help="only entries whose title or source link contains this (case-insensitive)")
    a = ap.parse_args()
    inst = a.instance.rstrip("/")

    items = get_json(f"{inst}/projects/{a.team}/workflows")["data"]
    ids = [i["id"] for i in items]
    print(f"Team {a.team}: {len(ids)} entries; reading crate metadata...", file=sys.stderr)
    infos, failed = [], []
    with cf.ThreadPoolExecutor(8) as ex:
        futs = {ex.submit(entry_info, inst, i): i for i in ids}
        for f in cf.as_completed(futs):
            try:
                infos.append(f.result())
            except Exception as e:  # noqa: BLE001
                failed.append((futs[f], str(e)))
    if a.filter:
        q = a.filter.lower()
        infos = [i for i in infos if q in (i["title"] or "").lower() or q in (i["isBasedOn"] or "").lower()]
    infos.sort(key=lambda i: (i["isBasedOn"] or "", i["id"]))

    tutorials = tutorial_dirs(a.repo)
    index = build_index(a.repo, tutorials)
    langs = {}
    lines = [
        "# Generated by wfh_bootstrap.py. REVIEW every entry before use.",
        "# isBasedOn MUST stay identical to the entry's current source link on WorkflowHub,",
        "# or submissions create duplicates. Change it only after editing the source link on WorkflowHub.",
        f"instance: {inst}",
        f"team_id: {a.team}",
        "exclude: []   # extra glob patterns to drop when staging (tests, hidden files, __pycache__ are always dropped)",
        "workflows:",
    ]
    def emit(entry_id, comment, flav, path, note, main, src, name, lic, authors, skip, jupyter_hint):
        out = [
            f"  - id: {entry_id}   # {comment}",
            f"    flavour: {flav}",
            f"    path: {yaml_str(path)}   # {note}",
            f"    main: {yaml_str(main)}",
            f"    isBasedOn: {yaml_str(src)}",
            f"    name: {yaml_str(name)}",
        ]
        if skip:
            out.append("    skip: true   # remove once path/isBasedOn are confirmed")
        if jupyter_hint:
            env = find_env_file(a.repo, path, submods) if path != "TODO" else None
            if env:
                out.append(f"    extra: [{{from: {env}, to: environment.yml}}]   # shared env file copied into the crate")
            else:
                out.append("    extra: []   # e.g. [{from: <submodule>/conda_env/environment.yml, to: environment.yml}]")
        if lic:
            out.append(f"    license: {yaml_str(lic)}")
        if authors:
            out.append("    authors:")
            for p in authors:
                out.append(f"      - {{name: {yaml_str(p['name'])}, orcid: {yaml_str(p['orcid'])}}}")
        return out

    submods = read_gitmodules(a.repo)
    todo = 0
    assigned = {}
    by_tutorial = {}
    for i in infos:
        path, note = guess_path(a.repo, i, tutorials, index)
        if not i["isBasedOn"]:
            note += "; NO SOURCE LINK on WorkflowHub: set one on the entry (Edit), then put it in isBasedOn"
            path = "TODO"
        todo += path == "TODO"
        flav = FLAVOUR_BY_CLASS.get(i["class"] or "", i["class"])
        if i["language"]:
            langs.setdefault(flav, i["language"])
        if path != "TODO":
            assigned[path] = i["id"]
            by_tutorial.setdefault(path.split("/")[0], i)
        lines += emit(i["id"], f"{i['title']} (latest v{i['latest_version']})", flav, path, note, i["main"],
                      i["isBasedOn"], i["title"], i["license"], i["authors"], path == "TODO", flav == "jupyter")

    # Flavour folders with no WorkflowHub entry yet: proposed as NEW entries (skipped until reviewed).
    origin = repo_url(a.repo)
    new = 0
    new_lines = ["", "  # ---- Flavour folders with NO WorkflowHub entry yet. First submission CREATES the entry",
                 "  # ---- in team_id. Review, remove `skip: true`, and afterwards put the new id here."]
    for tut in tutorials:
        sibling = by_tutorial.get(tut)
        for flav in NEW_FLAVOURS:
            base = os.path.join(a.repo, tut, flav)
            if not os.path.isdir(base):
                continue
            if any(p == f"{tut}/{flav}" or p.startswith(f"{tut}/{flav}/") for p in assigned):
                continue
            path, main = propose_main(a.repo, tut, flav, index)
            src = source_link_for(path, submods, origin) if path != "TODO" else None
            name = proposed_name(flav, tut, sibling)
            new += 1
            new_lines += emit("null", "NEW entry", flav, path, "proposed; CHECK", main, src or "TODO", name,
                              sibling["license"] if sibling else None,
                              sibling["authors"] if sibling else None, True, flav == "jupyter")
    if new:
        lines += new_lines
    with open(a.out, "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines) + "\n")
    with open(os.path.splitext(a.out)[0] + ".languages.json", "w", encoding="utf-8") as fh:
        json.dump(langs, fh, indent=2)
    print(f"Wrote {a.out}: {len(infos)} existing entries ({todo} need a path), "
          f"{new} folders without an entry (proposed as new, skipped)", file=sys.stderr)
    for wid, err in failed:
        print(f"  could not read entry {wid}: {err}", file=sys.stderr)


if __name__ == "__main__":
    main()
