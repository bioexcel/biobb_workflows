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

The other flavours of the same workflow (cwl/airflow adapters' dockerPull, nextflow
modules' container + conda lines, tests/) must use the same versions too. Those
mismatches are WARNINGS by default (the flavours were out of step before the 2026.2
release) and ERRORS with --strict-flavours (used by the /biobb-release skill; switch CI
to it once every flavour is in step).

Usage:  python3 common/python/check_versions.py [--strict-flavours] [biobb_wf_x ...]
Stdlib only, so it runs on a bare CI runner.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "common", "release"))
import bump_versions  # noqa: E402  (same patterns the release script edits)

OTHER_FLAVOURS = ("cwl", "airflow", "nextflow", "tests")

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


def other_flavours(wf, pinned):
    """Mismatches between the python pins and the other flavours of the workflow."""
    found = {}
    for flavour in OTHER_FLAVOURS:
        base = os.path.join(ROOT, wf, flavour)
        for dirpath, dirnames, filenames in os.walk(base):
            dirnames[:] = [d for d in dirnames if d not in bump_versions.SKIP_DIRS]
            for fn in filenames:
                if os.path.splitext(fn)[1] not in bump_versions.EDIT_EXT:
                    continue
                for _, pkg, ver, _ in bump_versions.occurrences(os.path.join(dirpath, fn)):
                    found.setdefault((pkg, ver), set()).add(flavour)
    out = []
    for (pkg, ver), flavours in sorted(found.items()):
        if pkg in pinned and pinned[pkg] != ver:
            out.append(f"{pkg} {ver} in {'/'.join(sorted(flavours))} != python pin {pinned[pkg]}")
    versions = {}
    for (pkg, ver) in found:
        versions.setdefault(pkg, set()).add(ver)
    for pkg, vs in sorted(versions.items()):
        if pkg not in pinned and len(vs) > 1:
            out.append(f"{pkg}: several versions across flavours ({', '.join(sorted(vs))})")
    return out


def check(wf, strict_flavours=False):
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
    (errors if strict_flavours else warnings).extend(other_flavours(wf, pinned))
    return errors, warnings


def main(argv):
    strict = "--strict-flavours" in argv
    argv = [a for a in argv if a != "--strict-flavours"]
    wfs = argv or sorted(d for d in os.listdir(ROOT)
                         if d.startswith("biobb_wf_") and os.path.isdir(os.path.join(ROOT, d)))
    failed = 0
    for wf in wfs:
        errors, warnings = check(wf, strict)
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
