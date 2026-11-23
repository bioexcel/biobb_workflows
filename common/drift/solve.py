#!/usr/bin/env python3
"""Dry-run solve every environment with one conda tool for one platform.

For each WORK/specs/<env_id>.txt it runs
    <tool> create --dry-run --json -y -n drift_probe --override-channels \
        -c <each channel of the env file, nodefaults excluded> <specs...>
(nothing is downloaded or installed) and writes
    OUT/envs/<env_id>/<platform>__<solver>.txt
whose first line is "# OK" or "# FAILED: <reason>", followed by the sorted package list
("name version build channel"), plus OUT/meta/tools__<solver>__<platform>.txt with the
tool's version.

Other platforms are solved from Linux by setting CONDA_SUBDIR / --platform and the
virtual-package overrides, so no Mac runner is needed.

Usage: python3 solve.py --solver conda|mamba|micromamba --exe PATH --platform SUBDIR
                        --work DIR --out DIR [--jobs N]
"""
import argparse
import concurrent.futures as cf
import json
import os
import subprocess
import sys

# minimum OS assumed for the Mac solves (oldest macOS still supported by conda-forge
# builds we care about); Linux uses the runner's real glibc, like CI.
OSX_OVERRIDE = {"osx-64": "13.0", "osx-arm64": "14.0"}
TIMEOUT = 1500  # seconds per solve


def channel_name(pkg):
    ch = pkg.get("channel") or pkg.get("schannel") or ""
    # full URLs (https://conda.anaconda.org/conda-forge/linux-64) -> conda-forge
    if "://" in ch:
        parts = [p for p in ch.split("/") if p]
        ch = parts[2] if len(parts) > 2 else ch
    return ch.split("/")[0] or "?"


def short_error(text):
    """A compact one-paragraph reason from the tool's JSON or plain output."""
    try:
        d = json.loads(text)
        msg = d.get("message") or d.get("error") or json.dumps(d)[:2000]
    except Exception:
        msg = text
    lines = [l.strip() for l in str(msg).splitlines() if l.strip()]
    return " | ".join(lines)[:1500] or "unknown error"


def solve(args, env_id):
    specs = [s for s in open(os.path.join(args.work, "specs", env_id + ".txt")).read().splitlines() if s.strip()]
    env = dict(os.environ)
    env["CONDA_SUBDIR"] = args.platform
    if args.platform in OSX_OVERRIDE:
        env["CONDA_OVERRIDE_OSX"] = OSX_OVERRIDE[args.platform]
    if args.platform.startswith("linux") and not sys.platform.startswith("linux"):
        # solving for Linux from a Mac (local runs): there is no real glibc to detect
        env["CONDA_OVERRIDE_GLIBC"] = "2.28"
    chan_file = os.path.join(args.work, "specs", env_id + ".channels")
    channels = [c for c in open(chan_file).read().split() if c] if os.path.isfile(chan_file) else []
    cmd = [args.exe, "create", "--dry-run", "--json", "-y", "-n", f"drift_probe_{os.getpid()}",
           "--override-channels"]
    for c in channels or ["conda-forge", "bioconda"]:
        cmd += ["-c", c]
    if args.solver != "conda":
        cmd += ["--platform", args.platform]
    cmd += specs
    try:
        p = subprocess.run(cmd, capture_output=True, text=True, env=env, timeout=TIMEOUT)
        out, rc = p.stdout, p.returncode
        err = p.stderr
    except subprocess.TimeoutExpired:
        out, rc, err = "", -1, f"timeout after {TIMEOUT}s"

    pkgs, reason = [], None
    if rc == 0:
        try:
            d = json.loads(out)
            links = (d.get("actions") or {}).get("LINK") or []
            for pk in links:
                build = pk.get("build_string") or pk.get("build") or ""
                pkgs.append(f"{pk['name']} {pk['version']} {build} {channel_name(pk)}")
            if not d.get("success", True) or not links:
                reason = "solver reported no packages to install"
        except Exception as e:
            reason = f"unreadable JSON output: {e}"
    else:
        reason = short_error(out or err)

    dest = os.path.join(args.out, "envs", env_id)
    os.makedirs(dest, exist_ok=True)
    with open(os.path.join(dest, f"{args.platform}__{args.solver}.txt"), "w") as fh:
        fh.write("# OK\n" if reason is None else f"# FAILED: {reason}\n")
        if pkgs:
            fh.write("\n".join(sorted(pkgs)) + "\n")
    return env_id, reason


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--solver", required=True, choices=["conda", "mamba", "micromamba"])
    ap.add_argument("--exe", required=True)
    ap.add_argument("--platform", required=True)
    ap.add_argument("--work", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--jobs", type=int, default=3)
    args = ap.parse_args()

    env_ids = sorted(f[:-4] for f in os.listdir(os.path.join(args.work, "specs")) if f.endswith(".txt"))
    os.makedirs(os.path.join(args.out, "meta"), exist_ok=True)
    version = subprocess.run([args.exe, "--version"], capture_output=True, text=True).stdout.strip()
    with open(os.path.join(args.out, "meta", f"tools__{args.solver}__{args.platform}.txt"), "w") as fh:
        fh.write((version.splitlines()[-1] if version else "?") + "\n")

    # first solve alone, so the channel index is downloaded once and cached
    results = [solve(args, env_ids[0])]
    with cf.ThreadPoolExecutor(max_workers=args.jobs) as ex:
        results += list(ex.map(lambda e: solve(args, e), env_ids[1:]))

    failed = [(e, r) for e, r in results if r]
    for e, r in results:
        print(("FAILED " if r else "ok     ") + e + (f": {r[:300]}" if r else ""))
    print(f"{len(results) - len(failed)}/{len(results)} environments solve with "
          f"{args.solver} for {args.platform}")
    # a failing environment is a finding, not a job failure: the report job decides
    sys.exit(0)


if __name__ == "__main__":
    main()
