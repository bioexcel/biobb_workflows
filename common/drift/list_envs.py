#!/usr/bin/env python3
"""Collect every conda environment the workflows ship, as plain spec lists.

Writes one file per environment into OUT_DIR/specs/<env_id>.txt (one conda spec per
line, in file order) plus OUT_DIR/specs/_index.tsv (env_id, source, workflows).

Environments:
  python__<wf>     <wf>/python/workflow.env.yml (this repo, 19 files)
  jupyter__<repo>  conda_env/environment.yml on the main branch of each jupyter repo
                   listed in .gitmodules (the three amber sub-workflows share one repo)

The jupyter env files are fetched from GitHub main (not from the submodule pointer),
because that is what users, the Colab cell and the Docker image builds get today.

Only the standard library is used (the runner's system python runs it).
Usage: python3 common/drift/list_envs.py OUT_DIR
"""
import configparser
import os
import sys
import urllib.request

RAW = "https://raw.githubusercontent.com/{owner_repo}/main/conda_env/environment.yml"


def parse_env(text, where):
    """Return (channels, dependencies) of a simple environment.yml."""
    channels, deps, section = [], [], None
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
        if section == "dependencies":
            deps.append(item)
        elif section == "channels":
            channels.append(item)
    if not deps:
        sys.exit(f"{where}: no dependencies found")
    return channels, deps


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
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    out = os.path.join(sys.argv[1], "specs")
    os.makedirs(out, exist_ok=True)
    index = []

    for wf in sorted(d for d in os.listdir(".") if d.startswith("biobb_wf_")):
        f = os.path.join(wf, "python", "workflow.env.yml")
        if not os.path.isfile(f):
            continue
        _, deps = parse_env(open(f).read(), f)
        env_id = f"python__{wf}"
        with open(os.path.join(out, env_id + ".txt"), "w") as fh:
            fh.write("\n".join(deps) + "\n")
        index.append((env_id, f, wf))

    for owner_repo, wfs in sorted(jupyter_repos().items()):
        url = RAW.format(owner_repo=owner_repo)
        try:
            with urllib.request.urlopen(url, timeout=60) as r:
                text = r.read().decode()
        except Exception as e:  # a missing env file is itself worth reporting
            print(f"::warning::cannot fetch {url}: {e}")
            continue
        _, deps = parse_env(text, url)
        env_id = "jupyter__" + owner_repo.split("/", 1)[1]
        with open(os.path.join(out, env_id + ".txt"), "w") as fh:
            fh.write("\n".join(deps) + "\n")
        index.append((env_id, url, ",".join(sorted(wfs))))

    with open(os.path.join(out, "_index.tsv"), "w") as fh:
        for row in index:
            fh.write("\t".join(row) + "\n")
    print(f"{len(index)} environments written to {out}")


if __name__ == "__main__":
    main()
