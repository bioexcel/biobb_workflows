#!/usr/bin/env python3
"""Collect every conda environment the workflows ship, as plain spec lists.

Writes one file per environment into OUT_DIR/specs/<env_id>.txt (one conda spec per
line, in file order), its channels into OUT_DIR/specs/<env_id>.channels (without
nodefaults), plus OUT_DIR/specs/_index.tsv (env_id, source, workflows) and
OUT_DIR/specs/_warnings.tsv (env_id, line) for dependency lines conda ignores.

Environments:
  python__<wf>     <wf>/python/workflow.env.yml (this repo, 19 files)
  jupyter__<repo>  conda_env/environment.yml on the main branch of each jupyter repo
                   listed in .gitmodules (the three amber sub-workflows share one repo)

The jupyter env files are fetched from GitHub main (not from the submodule pointer),
because that is what users, the Colab cell and the Docker image builds get today.

Only the standard library is used (the runner's system python runs it).
Usage: python3 common/drift/list_envs.py OUT_DIR [--local-jupyter]
  --local-jupyter  read the jupyter env files from the local tutorial checkouts
                   (<tutorials>/<repo>/conda_env/environment.yml; <tutorials> =
                   $BIOBB_TUTORIALS or the "tutorials" folder next to this repo) instead
                   of GitHub main: used by the release skill to test edits before pushing
"""
import configparser
import os
import re
import sys
import urllib.request

RAW = "https://raw.githubusercontent.com/{owner_repo}/main/conda_env/environment.yml"


def parse_env(text, where):
    """Return (channels, dependencies, ignored) of a simple environment.yml.

    A mapping item such as `- numpy: '<2'` is not a conda spec: conda treats it as
    another installer section and silently drops it. It is skipped the same way and
    returned in `ignored`, so the report can flag it.
    """
    channels, deps, ignored, section = [], [], [], None
    for raw in text.splitlines():
        if raw.lstrip().startswith("#"):
            continue
        line = raw.split(" #", 1)[0].rstrip()
        if not line.strip():
            continue
        if not line.startswith((" ", "\t", "-")):
            section = line.split(":", 1)[0].strip()
            continue
        item = line.strip()
        if not item.startswith("-"):
            continue
        item = item[1:].strip().strip("'\"")
        if item.endswith(":"):
            sys.exit(f"{where}: nested section '{item}' (pip?) is not supported by the drift check")
        if section == "dependencies" and re.match(r"^[A-Za-z0-9_.\-]+:\s", item):
            ignored.append(line.strip()[1:].strip())
            continue
        if section == "dependencies":
            deps.append(item)
        elif section == "channels":
            channels.append(item)
    if not deps:
        sys.exit(f"{where}: no dependencies found")
    return channels, deps, ignored


def write_env(out, env_id, parsed, warnings):
    channels, deps, ignored = parsed
    with open(os.path.join(out, env_id + ".txt"), "w") as fh:
        fh.write("\n".join(deps) + "\n")
    with open(os.path.join(out, env_id + ".channels"), "w") as fh:
        fh.write("\n".join(c for c in channels if c != "nodefaults") + "\n")
    warnings += [(env_id, line) for line in ignored]


def jupyter_repos():
    """{owner/repo: [wf, ...]} from .gitmodules (path biobb_wf_x/jupyter)."""
    cp = configparser.ConfigParser()
    cp.read(".gitmodules")
    repos = {}
    for sec in cp.sections():
        path, url = cp[sec].get("path", ""), cp[sec].get("url", "")
        if not path.endswith("/jupyter") or "github.com/" not in url:
            continue
        owner_repo = url.split("github.com/", 1)[1].removesuffix(".git").strip("/")
        repos.setdefault(owner_repo, []).append(path.split("/", 1)[0])
    return repos


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    local = "--local-jupyter" in sys.argv[1:]
    if len(args) != 1:
        sys.exit(__doc__)
    out = os.path.join(args[0], "specs")
    os.makedirs(out, exist_ok=True)
    index, warnings = [], []

    for wf in sorted(d for d in os.listdir(".") if d.startswith("biobb_wf_")):
        f = os.path.join(wf, "python", "workflow.env.yml")
        if not os.path.isfile(f):
            continue
        env_id = f"python__{wf}"
        write_env(out, env_id, parse_env(open(f).read(), f), warnings)
        index.append((env_id, f, wf))

    for owner_repo, wfs in sorted(jupyter_repos().items()):
        url = RAW.format(owner_repo=owner_repo)
        try:
            if local:
                tutorials = os.environ.get("BIOBB_TUTORIALS") or os.path.join(
                    os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(
                        os.path.abspath(__file__))))), "tutorials")
                url = os.path.join(tutorials, owner_repo.split("/", 1)[1],
                                   "conda_env", "environment.yml")
                text = open(url).read()
            else:
                with urllib.request.urlopen(url, timeout=60) as r:
                    text = r.read().decode()
        except Exception as e:  # a missing env file is itself worth reporting
            print(f"::warning::cannot read {url}: {e}")
            continue
        env_id = "jupyter__" + owner_repo.split("/", 1)[1]
        write_env(out, env_id, parse_env(text, url), warnings)
        index.append((env_id, url, ",".join(sorted(wfs))))

    with open(os.path.join(out, "_index.tsv"), "w") as fh:
        for row in index:
            fh.write("\t".join(row) + "\n")
    with open(os.path.join(out, "_warnings.tsv"), "w") as fh:
        for env_id, line in warnings:
            fh.write(f"{env_id}\t{line}\n")
            print(f"::warning::{env_id}: conda ignores the dependency line '{line}'")
    print(f"{len(index)} environments written to {out}")


if __name__ == "__main__":
    main()
