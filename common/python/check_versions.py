#!/usr/bin/env python3
"""Check that each workflow pins the SAME biobb_* versions everywhere.

Per workflow folder (biobb_wf_*), the biobb package versions live in:

  python/workflow.env.yml           conda mode           biobb_x==5.3.1[=build]
  python/requirements.txt           container mode (pip) biobb_x==5.3.1
  python/workflow.docker.yml        container_image tag  .../biobb_x:5.3.1--build
  python/workflow.singularity.yml   container_image tag  .../biobb_x:5.3.1--build

Errors (exit 1):
  * a biobb_* package pinned in workflow.env.yml but missing from requirements.txt
    (or the other way round)
  * a version that differs between workflow.env.yml and requirements.txt
  * a container_image tag whose version differs from the pin of that package
Warnings (exit 0): a container_image of a biobb package that is not pinned at all.

Usage:  python3 common/python/check_versions.py [biobb_wf_x ...]   (default: all)
Stdlib only, so it runs on a bare CI runner.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

PIN_RE = re.compile(r"^\s*(?:-\s*)?(biobb_[a-z0-9_]+)\s*==\s*([^=\s#]+)")
IMAGE_RE = re.compile(r"^\s*container_image:\s*\S*?/(biobb_[a-z0-9_]+):([^-\s]+)--\S*", re.M)


def read(path):
    with open(path) as f:
        return f.read()


def pins(path):
    out = {}
    for line in read(path).splitlines():
        m = PIN_RE.match(line)
        if m:
            out[m.group(1)] = m.group(2)
    return out


def check(wf):
    errors, warnings = [], []
    py = os.path.join(ROOT, wf, "python")
    env_path = os.path.join(py, "workflow.env.yml")
    req_path = os.path.join(py, "requirements.txt")
    if not os.path.exists(env_path):
        return [f"missing {wf}/python/workflow.env.yml"], warnings
    env = pins(env_path)
    if not os.path.exists(req_path):
        errors.append(f"missing {wf}/python/requirements.txt")
        req = {}
    else:
        req = pins(req_path)
        for pkg in sorted(set(env) | set(req)):
            if pkg not in req:
                errors.append(f"{pkg}=={env[pkg]} in workflow.env.yml but not in requirements.txt")
            elif pkg not in env:
                errors.append(f"{pkg}=={req[pkg]} in requirements.txt but not in workflow.env.yml")
            elif env[pkg] != req[pkg]:
                errors.append(f"{pkg}: workflow.env.yml {env[pkg]} != requirements.txt {req[pkg]}")

    pinned = {**req, **env}
    for variant in ("docker", "singularity"):
        cfg = os.path.join(py, f"workflow.{variant}.yml")
        if not os.path.exists(cfg):
            continue
        for pkg, ver in sorted(set(IMAGE_RE.findall(read(cfg)))):
            if pkg not in pinned:
                warnings.append(f"workflow.{variant}.yml uses a {pkg}:{ver} image but {pkg} is not pinned")
            elif pinned[pkg] != ver:
                errors.append(f"workflow.{variant}.yml: {pkg} image tag {ver} != pinned {pinned[pkg]}")
    return errors, warnings


def main(argv):
    wfs = argv or sorted(d for d in os.listdir(ROOT)
                         if d.startswith("biobb_wf_") and os.path.isdir(os.path.join(ROOT, d)))
    failed = 0
    for wf in wfs:
        errors, warnings = check(wf)
        for w in warnings:
            print(f"::warning::{wf}: {w}")
        for e in errors:
            print(f"::error::{wf}: {e}")
        if errors:
            failed += 1
        else:
            print(f"OK  {wf}")
    if failed:
        print(f"\n{failed} workflow(s) with inconsistent biobb versions")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
