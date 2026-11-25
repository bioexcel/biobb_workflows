#!/usr/bin/env python3
"""Change the biobb_* versions of every workflow and flavour in one go (release helper).

Used by the /biobb-release skill (.claude/skills/biobb-release/SKILL.md), which drives
it step by step. Nothing here commits or pushes.

Where a biobb version is written (all edited by `apply`):

  kind     example                                                files
  pin      biobb_gromacs==5.3.2   (optionally =<build>)            python/workflow.env.yml,
                                                                   python/requirements.txt,
                                                                   jupyter conda_env + binder envs
  conda    bioconda::biobb_gromacs=5.3.2                           nextflow modules
  image    quay.io/biocontainers/biobb_gromacs:5.3.2--pyhdfd78af_0 python container configs,
           depot.galaxyproject.org/singularity/biobb_...:...       cwl/airflow adapters,
                                                                   nextflow modules, tests
  label    2026.1                                                  docker/VERSION
Galaxy (.ga) tool versions are a separate thing: common/galaxy/galaxy_wf.py.
Markdown files are never edited (they quote versions as history); `scan` lists them.

Subcommands:
  scan                      versions currently written, per package (and where they differ)
  latest [--out FILE]       latest version of each package on bioconda vs current; writes
                            a draft release file
  check FILE                is every new version installable everywhere? (bioconda build,
                            quay.io image, depot.galaxyproject.org singularity image) and
                            can every image tag / build pin be mapped without guessing?
  apply FILE [--jupyter] [--docker-version LABEL] [--dry-run]
                            rewrite the files; prints what changed per workflow

Release file (JSON, written by `latest`, edited by hand or by the agent):
  {
    "versions": {"biobb_gromacs": "5.4.0", "biobb_analysis": "5.4.0"},
    "overrides": {
      "biobb_analysis:5.3.0--gmx2026_2": "5.4.0--gmx2027_0",     # image tag mapping
      "biobb_analysis==5.3.0=pyhdfd78af_1": "5.4.0=pyhdfd78af_1"  # env build pin mapping
    }
  }
Only packages listed in "versions" are touched. When a new version has several images
or builds (biobb_analysis 5.3.0 has a gromacs image and a cpptraj one) the script keeps
the same kind of build ("family": the build string without its trailing _N); if that is
impossible it stops and asks for an override instead of guessing.

Stdlib only. Network: api.anaconda.org, quay.io, depot.galaxyproject.org (public, no auth).
"""
import argparse
import configparser
import functools
import json
import os
import re
import sys
import urllib.error
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PKG = r"biobb_[a-z0-9_]+"
VER = r"\d+\.\d+\.\d+"
PIN_RE = re.compile(rf"(?<![\w.\-/:])({PKG})==({VER})(?:=([A-Za-z0-9_.]+))?")
CONDA_RE = re.compile(rf"(bioconda::)({PKG})=({VER})(?![\d.])")
IMAGE_RE = re.compile(rf"((?:quay\.io/biocontainers|depot\.galaxyproject\.org/singularity)/)"
                      rf"({PKG}):({VER})--([A-Za-z0-9_.]+)")
EDIT_EXT = {".yml", ".yaml", ".txt", ".cwl", ".nf", ".py", ".config", ".sh", ".json"}
SKIP_DIRS = {".git", "jupyter", "galaxy", "work", "__pycache__", "node_modules", ".nextflow"}
UA = {"User-Agent": "biobb-workflows-release-script"}


# ----------------------------------------------------------------------------- files
def workflows():
    return sorted(d for d in os.listdir(ROOT) if d.startswith("biobb_wf_") and os.path.isdir(os.path.join(ROOT, d)))


# The jupyter tutorial repos are edited in their own checkouts, never through this repo's
# <wf>/jupyter submodules: modify <tutorials>/<repo>, push, then
# `git submodule update --remote` here. Default: the folder next to this repo.
TUTORIALS = os.environ.get("BIOBB_TUTORIALS") or os.path.join(os.path.dirname(ROOT), "tutorials")


def jupyter_env_files():
    """The env files of each jupyter repo, in its checkout under TUTORIALS (one per repo:
    the three amber sub-wfs share biobb_wf_amber).
    returns ([files to edit], {repo_url: [all submodule paths]})."""
    cp = configparser.ConfigParser()
    cp.read(os.path.join(ROOT, ".gitmodules"))
    by_url = {}
    for sec in cp.sections():
        path, url = cp[sec].get("path", ""), cp[sec].get("url", "")
        if path.endswith("/jupyter"):
            by_url.setdefault(url, []).append(path)
    files = []
    for url in sorted(by_url):
        repo = os.path.join(TUTORIALS, url.rstrip("/").split("/")[-1].removesuffix(".git"))
        if not os.path.isdir(repo):
            sys.exit(f"ERROR: no checkout of {url} at {repo} (set BIOBB_TUTORIALS to the "
                     "folder holding the tutorial repos)")
        for rel in ("conda_env/environment.yml", "binder/environment.yml"):
            f = os.path.join(repo, rel)
            if os.path.isfile(f):
                files.append(f)
    return files, by_url


def repo_files(jupyter=False):
    """(editable files, markdown files) under biobb_wf_*/ (+ jupyter env files)."""
    edit, md = [], []
    for wf in workflows():
        for dirpath, dirnames, filenames in os.walk(os.path.join(ROOT, wf)):
            dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
            for fn in filenames:
                p = os.path.join(dirpath, fn)
                ext = os.path.splitext(fn)[1]
                if ext == ".md":
                    md.append(p)
                elif ext in EDIT_EXT or fn == "Dockerfile":
                    edit.append(p)
    if jupyter:
        edit += jupyter_env_files()[0]
    return edit, md


def rel(p):
    return os.path.relpath(p, ROOT)


def wf_of(p):
    return rel(p).split(os.sep, 1)[0]


def occurrences(path):
    """[(kind, pkg, version, build_or_None)] in one file."""
    try:
        text = open(path, encoding="utf-8").read()
    except (UnicodeDecodeError, OSError):
        return []
    out = [("pin", m.group(1), m.group(2), m.group(3)) for m in PIN_RE.finditer(text)]
    out += [("conda", m.group(2), m.group(3), None) for m in CONDA_RE.finditer(text)]
    out += [("image", m.group(2), m.group(3), m.group(4)) for m in IMAGE_RE.finditer(text)]
    return out


def vtuple(v):
    return tuple(int(x) for x in re.findall(r"\d+", v))


# ----------------------------------------------------------------------------- network
def get_json(url):
    req = urllib.request.Request(url, headers=UA)
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.loads(r.read().decode())


@functools.lru_cache(maxsize=None)
def bioconda_files(pkg):
    """[(version, build, subdir)] of a bioconda package."""
    try:
        return [(f["version"], f["attrs"]["build"], f["attrs"].get("subdir", ""))
                for f in get_json(f"https://api.anaconda.org/package/bioconda/{pkg}/files")]
    except urllib.error.HTTPError:
        return []


@functools.lru_cache(maxsize=None)
def quay_tags(pkg, version):
    try:
        d = get_json(f"https://quay.io/api/v1/repository/biocontainers/{pkg}/tag/"
                     f"?limit=100&onlyActiveTags=true&filter_tag_name=like:{version}--")
        return sorted(t["name"] for t in d.get("tags", []) if t["name"].startswith(version + "--"))
    except urllib.error.HTTPError:
        return []


@functools.lru_cache(maxsize=None)
def depot_exists(pkg, tag):
    req = urllib.request.Request(f"https://depot.galaxyproject.org/singularity/{pkg}:{tag}",
                                 method="HEAD", headers=UA)
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            return r.status == 200
    except urllib.error.HTTPError:
        return False


def family(build):
    return re.sub(r"_\d+$", "", build)


def build_num(build):
    m = re.search(r"_(\d+)$", build)
    return int(m.group(1)) if m else -1


def pick(old_build, candidates):
    """New build for an old one: same family, highest number; else the only candidate."""
    same = [c for c in candidates if family(c) == family(old_build)]
    if same:
        return max(same, key=build_num), None
    if len(candidates) == 1:
        return candidates[0], None
    if not candidates:
        return None, "no build/image exists for this version yet"
    return None, "several builds, none of the same kind: " + ", ".join(candidates)


# ----------------------------------------------------------------------------- planning
def load_release(path):
    d = json.load(open(path))
    return d.get("versions", {}), d.get("overrides", {})


def plan(versions, overrides, files):
    """Work out every replacement. Returns (mapping, problems, notes).
    mapping: {("pin"|"conda"|"image", pkg, old_ver, old_build): replacement text}."""
    mapping, problems, notes = {}, [], []
    seen = set()
    for f in files:
        for kind, pkg, ver, build in occurrences(f):
            if pkg not in versions or (kind, pkg, ver, build) in seen:
                continue
            seen.add((kind, pkg, ver, build))
            new = versions[pkg]
            if ver == new:  # same version: keep the exact image/build already used
                continue
            if kind == "conda" or (kind == "pin" and not build):
                if ver != new:
                    mapping[(kind, pkg, ver, build)] = new
                continue
            if kind == "image":
                key = f"{pkg}:{ver}--{build}"
                if key in overrides:
                    tag = overrides[key]
                else:
                    cands = [t.split("--", 1)[1] for t in quay_tags(pkg, new)]
                    nb, why = pick(build, cands)
                    if why:
                        problems.append(f"image {key} -> {pkg}:{new}: {why} "
                                        f'(add an override "{key}": "{new}--<build>")')
                        continue
                    tag = f"{new}--{nb}"
                    if family(nb) != family(build):
                        notes.append(f"image {key} -> {pkg}:{tag}: a DIFFERENT kind of build (the only "
                                     f"image of {new}); check it still contains what the steps need "
                                     f'(e.g. gromacs, cpptraj), or add an override "{key}"')
                if tag != f"{ver}--{build}":
                    mapping[(kind, pkg, ver, build)] = tag
                continue
            # env build pin: biobb_x==1.2.3=build
            key = f"{pkg}=={ver}={build}"
            if key in overrides:
                mapping[(kind, pkg, ver, build)] = overrides[key]
                continue
            builds = sorted({b for v, b, _ in bioconda_files(pkg) if v == new})
            nb, why = pick(build, builds)
            if why:
                problems.append(f"build pin {key} -> {new}: {why} "
                                f'(add an override "{key}": "{new}=<build>" or "{new}" to drop the pin)')
                continue
            if family(nb) == family(build):
                mapping[(kind, pkg, ver, build)] = f"{new}={nb}"
            else:
                mapping[(kind, pkg, ver, build)] = new
                notes.append(f"build pin {key}: no build of the same kind for {new}; pin dropped "
                             f"(only build: {nb}) - check the comment above that line")
    return mapping, problems, notes


def rewrite(text, mapping):
    def pin(m):
        r = mapping.get(("pin", m.group(1), m.group(2), m.group(3)))
        return f"{m.group(1)}=={r}" if r else m.group(0)

    def conda(m):
        r = mapping.get(("conda", m.group(2), m.group(3), None))
        return f"{m.group(1)}{m.group(2)}={r}" if r else m.group(0)

    def image(m):
        r = mapping.get(("image", m.group(2), m.group(3), m.group(4)))
        return f"{m.group(1)}{m.group(2)}:{r}" if r else m.group(0)

    text = PIN_RE.sub(pin, text)
    text = CONDA_RE.sub(conda, text)
    return IMAGE_RE.sub(image, text)


# ----------------------------------------------------------------------------- commands
def cmd_scan(args):
    files, md = repo_files(jupyter=args.jupyter)
    by_pkg = {}
    for f in files:
        for kind, pkg, ver, build in occurrences(f):
            by_pkg.setdefault(pkg, {}).setdefault(ver, set()).add(wf_of(f))
    print(f"{'package':28} versions written (number of workflows)")
    for pkg in sorted(by_pkg):
        vs = by_pkg[pkg]
        line = ", ".join(f"{v} ({len(w)})" for v, w in sorted(vs.items(), key=lambda x: vtuple(x[0])))
        print(f"{pkg:28} {line}" + ("   <- differs between workflows" if len(vs) > 1 else ""))
        if args.verbose and len(vs) > 1:
            for v, w in sorted(vs.items()):
                print(f"{'':30}{v}: {', '.join(sorted(w))}")
    md_hits = sorted({rel(f) for f in md if occurrences(f)})
    if md_hits:
        print(f"\nMarkdown files quoting versions (never edited; review by hand if needed): {len(md_hits)}")
        for f in md_hits:
            print("  " + f)


def cmd_latest(args):
    files, _ = repo_files(jupyter=args.jupyter)
    current = {}
    for f in files:
        for _, pkg, ver, _ in occurrences(f):
            current.setdefault(pkg, set()).add(ver)
    versions = {}
    print(f"{'package':28} {'current':18} {'latest on bioconda':20}")
    for pkg in sorted(current):
        vs = sorted({v for v, _, _ in bioconda_files(pkg)}, key=vtuple)
        latest = vs[-1] if vs else "?"
        cur = ", ".join(sorted(current[pkg], key=vtuple))
        mark = "" if latest in current[pkg] and len(current[pkg]) == 1 else "   <- update"
        print(f"{pkg:28} {cur:18} {latest:20}{mark}")
        if vs:
            versions[pkg] = latest
    if args.out:
        json.dump({"versions": versions, "overrides": {}}, open(args.out, "w"), indent=2)
        print(f"\nDraft release file written to {args.out}: edit it, then run `check` on it.")


def commented_pins(files, versions):
    """Pins of released packages with a comment right above them: usually a deliberate
    choice (e.g. 'last working release') that a version bump must not undo silently."""
    out = []
    for f in files:
        if not f.endswith((".yml", ".yaml", ".txt")):
            continue
        lines = open(f, encoding="utf-8").read().splitlines()
        for i, line in enumerate(lines):
            for m in PIN_RE.finditer(line):
                pkg, ver = m.group(1), m.group(2)
                if pkg not in versions or versions[pkg] == ver:
                    continue
                j, comment = i - 1, []
                while j >= 0 and lines[j].strip().startswith("#"):
                    comment.insert(0, lines[j].strip().lstrip("# "))
                    j -= 1
                if comment:
                    out.append((rel(f), pkg, ver, versions[pkg], " ".join(comment)))
    return out


def cmd_check(args):
    versions, overrides = load_release(args.file)
    problems = []
    for pkg, ver in sorted(versions.items()):
        files = bioconda_files(pkg)
        if not any(v == ver for v, _, _ in files):
            problems.append(f"{pkg} {ver} is not on bioconda")
            continue
        tags = quay_tags(pkg, ver)
        if not tags:
            problems.append(f"{pkg} {ver}: no quay.io/biocontainers image yet (bioconda builds it "
                            "a few hours after the package; try again later)")
        for t in tags:
            if not depot_exists(pkg, t):
                problems.append(f"{pkg}:{t}: no singularity image on depot.galaxyproject.org yet")
        print(f"ok  {pkg} {ver}  builds: {', '.join(sorted({b for v, b, _ in files if v == ver}))}"
              f"  images: {', '.join(tags) or '-'}")
    files, _ = repo_files(jupyter=True)
    mapping, plan_problems, notes = plan(versions, overrides, files)
    for n in notes:
        print("note: " + n)
    for f, pkg, old, new, comment in commented_pins(files, versions):
        print(f"DECIDE: {f}: {pkg} {old} -> {new}, but the line has a comment: \"{comment[:300]}\"")
    for p in problems + plan_problems:
        print("PROBLEM: " + p)
    print(f"\n{len(mapping)} distinct replacements planned, {len(problems) + len(plan_problems)} problem(s)")
    return 1 if problems or plan_problems else 0


def cmd_apply(args):
    versions, overrides = load_release(args.file)
    files, _ = repo_files(jupyter=args.jupyter)
    mapping, problems, notes = plan(versions, overrides, files)
    if problems:
        for p in problems:
            print("PROBLEM: " + p)
        print("Nothing written: fix the problems (run `check`) first.")
        return 1
    for n in notes:
        print("note: " + n)
    changed = {}
    for f in files:
        text = open(f, encoding="utf-8").read()
        new = rewrite(text, mapping)
        if new != text:
            n = sum(1 for a, b in zip(text.splitlines(), new.splitlines()) if a != b)
            changed.setdefault(wf_of(f), []).append((rel(f), n))
            if not args.dry_run:
                open(f, "w", encoding="utf-8").write(new)
    if args.docker_version:
        for wf in workflows():
            d = os.path.join(ROOT, wf, "docker")
            if not os.path.isdir(d):
                continue
            vf = os.path.join(d, "VERSION")
            old = open(vf).read().strip() if os.path.isfile(vf) else ""
            if old != args.docker_version:
                changed.setdefault(wf, []).append((rel(vf), 1))
                if not args.dry_run:
                    open(vf, "w").write(args.docker_version + "\n")
    total = 0
    for wf in sorted(changed):
        lines = sum(n for _, n in changed[wf])
        total += len(changed[wf])
        print(f"{wf}: {len(changed[wf])} files, {lines} lines")
        if args.verbose:
            for f, n in changed[wf]:
                print(f"    {f} ({n})")
    verb = "would change" if args.dry_run else "changed"
    print(f"\n{verb} {total} files in {len(changed)} folders")
    if args.jupyter and not args.dry_run:
        print(f"note: the jupyter env files were edited in {TUTORIALS}/<repo>: commit and push "
              "there, then `git submodule update --remote` in this repo")
    return 0


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    sub = ap.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("scan")
    s.add_argument("--jupyter", action="store_true", help="include the jupyter env files")
    s.add_argument("-v", "--verbose", action="store_true")
    s = sub.add_parser("latest")
    s.add_argument("--jupyter", action="store_true")
    s.add_argument("--out")
    s = sub.add_parser("check")
    s.add_argument("file")
    s = sub.add_parser("apply")
    s.add_argument("file")
    s.add_argument("--jupyter", action="store_true", help="also edit the jupyter env files")
    s.add_argument("--docker-version", help="write this label to every <wf>/docker/VERSION")
    s.add_argument("--dry-run", action="store_true")
    s.add_argument("-v", "--verbose", action="store_true")
    args = ap.parse_args()
    return {"scan": cmd_scan, "latest": cmd_latest, "check": cmd_check, "apply": cmd_apply}[args.cmd](args) or 0


if __name__ == "__main__":
    sys.exit(main())
