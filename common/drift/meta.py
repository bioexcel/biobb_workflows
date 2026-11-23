#!/usr/bin/env python3
"""Record the runtimes our users and CI depend on, as key=value files.

OUT_DIR/meta/colab.txt   from github.com/googlecolab/backend-info (Google publishes the
                         Colab runtime there; it can lag the real Colab by 1-2 days):
                         ubuntu, python, runtimes (the "past runtime versions" list)
OUT_DIR/meta/runner.txt  the machine this runs on (GitHub's ubuntu-latest in CI):
                         os, image, python, glibc

Usage: python3 common/drift/meta.py OUT_DIR
"""
import os
import platform
import re
import subprocess
import sys
import urllib.request

BASE = "https://raw.githubusercontent.com/googlecolab/backend-info/main/"


def fetch(name):
    with urllib.request.urlopen(BASE + name, timeout=60) as r:
        return r.read().decode()


def colab():
    d = {}
    try:
        lines = [l.strip() for l in fetch("os-info.txt").splitlines() if l.strip() and not l.startswith("#")]
        for l in lines:
            if l.startswith("Ubuntu"):
                d["ubuntu"] = l
            elif l.startswith("Python "):
                d["python"] = l.split()[1]
        d["runtimes"] = ",".join(re.findall(r"^###\s+(\d{4}\.\d{2})\s*$", fetch("README.md"), re.M))
    except Exception as e:
        print(f"::warning::cannot read Colab backend-info: {e}")
    return d


def run(cmd):
    try:
        return subprocess.run(cmd, capture_output=True, text=True, timeout=30).stdout.strip()
    except Exception:
        return ""


def runner():
    os_name = run(["lsb_release", "-ds"]) or platform.platform()
    glibc = run(["ldd", "--version"]).splitlines()
    glibc = glibc[0].split()[-1] if glibc else platform.libc_ver()[1]
    py = run(["python3", "--version"]).replace("Python ", "")
    return {"os": os_name, "image": os.environ.get("ImageVersion", "?"), "python": py, "glibc": glibc or "?"}


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    out = os.path.join(sys.argv[1], "meta")
    os.makedirs(out, exist_ok=True)
    for name, data in (("colab.txt", colab()), ("runner.txt", runner())):
        with open(os.path.join(out, name), "w") as fh:
            fh.write("".join(f"{k}={v}\n" for k, v in data.items()))
        print(name, data)


if __name__ == "__main__":
    main()
