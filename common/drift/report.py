#!/usr/bin/env python3
"""Compare today's drift snapshot with yesterday's and the last all-green one.

Snapshot layout (written by list_envs.py, solve.py and the workflow):
  specs/<env_id>.txt                       spec list of each environment
  specs/_index.tsv                         env_id, source, workflows
  envs/<env_id>/<platform>__<solver>.txt   "# OK" | "# FAILED: reason", then packages
  meta/tools__<solver>__<platform>.txt     tool version
  meta/runner.txt, meta/colab.txt          key=value lines

Severity rules (documented in docs/ci.md §1.1d):
  RED     an unexpected failure that breaks something we ship:
            - conda (CI, Docker images, most users) on any platform
            - mamba on a jupyter env (the Colab cell installs with mamba)
  YELLOW  everything else worth knowing: key package version changes, the three tools
          disagreeing on linux-64, mamba on a python env, micromamba failures, a Colab
          or GitHub-runner change
  INFO    expected failures: osx-* when the wf has tests/{python,jupyter}/MACOS_SKIP
          (python__ / jupyter__ envs), osx-arm64
          when osx-64 solves (CI and users fall back to osx-64 under Rosetta)

Outputs in --out: report.md (job summary), issue_body.md (current state),
comment.md (only what changed today; empty when nothing did), status.json.

Usage: python3 report.py --new DIR [--prev DIR] [--green DIR] --out DIR
"""
import argparse
import json
import os
import re

KEY = re.compile(r"^(python|numpy|scipy|pandas|ambertools|reduce|gromacs|openbabel|pytorch|"
                 r"libtorch|mkl|cpptraj|rdkit|openmm|vina|acpype|mdanalysis|biopython|"
                 r"nglview|biobb_[a-z_]+)$")
MAX_REASON = 600


def read_kv(path):
    d = {}
    if os.path.isfile(path):
        for line in open(path):
            if "=" in line:
                k, v = line.rstrip("\n").split("=", 1)
                d[k.strip()] = v.strip()
    return d


def load(root):
    """{(env, platform, solver): (ok, reason, {name: version})}, specs, index, meta."""
    solves, specs, index, warnings = {}, {}, {}, set()
    if not root or not os.path.isdir(root):
        return None
    envs_dir = os.path.join(root, "envs")
    for env in sorted(os.listdir(envs_dir)) if os.path.isdir(envs_dir) else []:
        for f in os.listdir(os.path.join(envs_dir, env)):
            if not f.endswith(".txt") or "__" not in f:
                continue
            platform, solver = f[:-4].split("__", 1)
            lines = open(os.path.join(envs_dir, env, f)).read().splitlines()
            head = lines[0] if lines else "# FAILED: empty file"
            ok = head.strip() == "# OK"
            reason = None if ok else head.split(":", 1)[-1].strip()
            pkgs = {}
            for l in lines[1:]:
                parts = l.split()
                if len(parts) >= 2:
                    pkgs[parts[0]] = parts[1]
            solves[(env, platform, solver)] = (ok, reason, pkgs)
    sdir = os.path.join(root, "specs")
    if os.path.isdir(sdir):
        for f in os.listdir(sdir):
            if f.endswith(".txt"):
                text = open(os.path.join(sdir, f)).read()
                chan = os.path.join(sdir, f[:-4] + ".channels")
                if os.path.isfile(chan):  # a channel change counts as an env file edit
                    text += "channels: " + " ".join(open(chan).read().split())
                specs[f[:-4]] = text
        wfile = os.path.join(sdir, "_warnings.tsv")
        if os.path.isfile(wfile):
            for line in open(wfile):
                if "\t" in line:
                    warnings.add(tuple(line.rstrip("\n").split("\t", 1)))
        idx = os.path.join(sdir, "_index.tsv")
        if os.path.isfile(idx):
            for line in open(idx):
                parts = line.rstrip("\n").split("\t")
                if len(parts) == 3:
                    index[parts[0]] = parts[2]
    meta = {
        "runner": read_kv(os.path.join(root, "meta", "runner.txt")),
        "colab": read_kv(os.path.join(root, "meta", "colab.txt")),
        "tools": {},
    }
    mdir = os.path.join(root, "meta")
    if os.path.isdir(mdir):
        for f in sorted(os.listdir(mdir)):
            if f.startswith("tools__"):
                meta["tools"][f[7:-4]] = open(os.path.join(mdir, f)).read().strip()
    return {"solves": solves, "specs": specs, "index": index, "meta": meta, "warnings": warnings}


def expected_failure(snap, key, repo):
    env, platform, solver = key
    flavour, _, wf = env.partition("__")
    if platform.startswith("osx") and flavour in ("python", "jupyter"):
        skip = os.path.join(repo, wf, "tests", flavour, "MACOS_SKIP")
        if os.path.isfile(skip):
            return "MACOS_SKIP: " + (open(skip).read().strip().splitlines() or ["no reason given"])[0]
    if platform == "osx-arm64":
        other = snap["solves"].get((env, "osx-64", solver))
        if other and other[0]:
            return "no osx-arm64 solution; osx-64 solves (CI and Mac users fall back to Rosetta)"
    return None


def severity(key):
    env, platform, solver = key
    if solver == "conda":
        return "red"
    if solver == "mamba" and env.startswith("jupyter__"):
        return "red"
    return "yellow"


def classify(snap, repo):
    red, yellow_fail, info = {}, {}, {}
    for key, (ok, reason, _) in snap["solves"].items():
        if ok:
            continue
        why = expected_failure(snap, key, repo)
        if why:
            info[key] = why
        elif severity(key) == "red":
            red[key] = reason
        else:
            yellow_fail[key] = reason
    return red, yellow_fail, info


def disagreements(snap):
    """{env: description} for linux-64 where the tools disagree (status or key versions)."""
    out = {}
    envs = sorted({k[0] for k in snap["solves"]})
    for env in envs:
        res = {s: snap["solves"].get((env, "linux-64", s)) for s in ("conda", "mamba", "micromamba")}
        res = {s: r for s, r in res.items() if r is not None}
        if len(res) < 2:
            continue
        status = {s: r[0] for s, r in res.items()}
        if len(set(status.values())) > 1:
            out[env] = "solves with " + ", ".join(s for s, v in status.items() if v) + \
                       "; fails with " + ", ".join(s for s, v in status.items() if not v)
            continue
        if not all(status.values()):
            continue
        diffs = []
        names = set().union(*(set(r[2]) for r in res.values()))
        for n in sorted(x for x in names if KEY.match(x)):
            vers = {s: r[2].get(n, "-") for s, r in res.items()}
            if len(set(vers.values())) > 1:
                diffs.append(n + " (" + ", ".join(f"{s} {v}" for s, v in vers.items()) + ")")
        if diffs:
            out[env] = "; ".join(diffs)
    return out


def key_changes(old, new, keys=None):
    """{(pkg, old_ver, new_ver): [env/platform/solver, ...]} for solves OK in both."""
    out = {}
    if not old:
        return out
    for key, (ok, _, pkgs) in new["solves"].items():
        if keys is not None and key not in keys:
            continue
        o = old["solves"].get(key)
        if not ok or not o or not o[0]:
            continue
        for n in sorted(set(pkgs) | set(o[2])):
            if not KEY.match(n):
                continue
            a, b = o[2].get(n, "(absent)"), pkgs.get(n, "(absent)")
            if a != b:
                out.setdefault((n, a, b), []).append("/".join(key))
    return out


def minor(v):
    m = re.match(r"(\d+\.\d+)", v or "")
    return m.group(1) if m else (v or "")


def meta_changes(old, new):
    out = []
    if not old:
        return out
    oc, nc = old["meta"]["colab"], new["meta"]["colab"]
    if oc and nc:
        if oc.get("ubuntu") != nc.get("ubuntu"):
            out.append(f"Colab Ubuntu: {oc.get('ubuntu')} → {nc.get('ubuntu')}")
        if minor(oc.get("python")) != minor(nc.get("python")):
            out.append(f"Colab Python: {oc.get('python')} → {nc.get('python')}")
        if oc.get("image", "?") != "?" and nc.get("image", "?") != "?" and oc.get("image") != nc.get("image"):
            out.append(f"Colab image: {oc.get('image')} → {nc.get('image')} (the Colab check runs on it)")
        if oc.get("runtimes") != nc.get("runtimes"):
            out.append(f"Colab runtime versions: {oc.get('runtimes')} → {nc.get('runtimes')}")
    orr, nr = old["meta"]["runner"], new["meta"]["runner"]
    if orr and nr:
        for k, label, f in (("os", "GitHub ubuntu-latest", str), ("python", "ubuntu-latest Python", minor),
                            ("glibc", "ubuntu-latest glibc", str)):
            if f(orr.get(k)) != f(nr.get(k)):
                out.append(f"{label}: {orr.get(k)} → {nr.get(k)}")
    return out


def tool_changes(old, new):
    if not old:
        return []
    return [f"{t}: {old['meta']['tools'].get(t, '?')} → {v}"
            for t, v in new["meta"]["tools"].items() if old["meta"]["tools"].get(t) not in (None, v)]


def fmt_key(key):
    return f"`{key[0]}` {key[1]} {key[2]}"


def short(reason):
    reason = reason or ""
    return reason if len(reason) <= MAX_REASON else reason[:MAX_REASON] + " …"


def changes_table(ch, limit=40):
    if not ch:
        return "_none_\n"
    rows = ["| package | from | to | where (count) |", "| --- | --- | --- | --- |"]
    for (n, a, b), where in sorted(ch.items())[:limit]:
        sample = ", ".join(where[:3]) + (" …" if len(where) > 3 else "")
        rows.append(f"| {n} | {a} | {b} | {sample} ({len(where)}) |")
    if len(ch) > limit:
        rows.append(f"| … | | | {len(ch) - limit} more |")
    return "\n".join(rows) + "\n"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--new", required=True)
    ap.add_argument("--prev")
    ap.add_argument("--green")
    ap.add_argument("--out", required=True)
    ap.add_argument("--repo", default=".")
    ap.add_argument("--run-url", default="")
    ap.add_argument("--green-date", default="")
    args = ap.parse_args()

    new, prev, green = load(args.new), load(args.prev), load(args.green)
    red, yfail, info = classify(new, args.repo)
    p_red, p_yfail, _ = classify(prev, args.repo) if prev else ({}, {}, {})
    dis = disagreements(new)
    p_dis = disagreements(prev) if prev else {}

    new_red = sorted(set(red) - set(p_red)) if prev else sorted(red)
    fixed = sorted(set(p_red) - set(red))
    new_yfail = sorted(set(yfail) - set(p_yfail)) if prev else []
    fixed_yfail = sorted(set(p_yfail) - set(yfail))
    dis_changed = sorted(e for e in set(dis) | set(p_dis) if dis.get(e) != p_dis.get(e)) if prev else []
    today_changes = key_changes(prev, new)
    since_green = key_changes(green, new)
    metas = meta_changes(prev, new)
    tools = tool_changes(prev, new)
    spec_changed = sorted(e for e in new["specs"] if prev and prev["specs"].get(e) not in (None, new["specs"][e]))
    spec_since_green = sorted(e for e in new["specs"]
                              if green and green["specs"].get(e) not in (None, new["specs"][e]))

    n_solves = len(new["solves"])
    n_ok = sum(1 for v in new["solves"].values() if v[0])
    run = f" ([run]({args.run_url}))" if args.run_url else ""
    headline = (f"🔴 {len(red)} environment solve(s) failing" if red else "🟢 all shipped environments solve")
    headline += f" — {n_ok}/{n_solves} solves OK{run}"

    # ---------------- issue body: the current state ----------------
    b = [f"## {headline}", "",
         "Updated by `.github/workflows/drift-daily.yaml` every day. This text always shows the "
         "**current** state; comments below record what changed and when. "
         "Rules: `docs/ci.md` §1.1d.", ""]
    if red:
        b += ["### 🔴 Failing (breaks CI, Docker image builds, users or Colab)", "",
              "| environment | platform | tool | reason |", "| --- | --- | --- | --- |"]
        for k in sorted(red):
            b.append(f"| `{k[0]}` | {k[1]} | {k[2]} | {short(red[k])} |")
        b.append("")
        where = new["index"]
        affected = sorted({w for k in red for w in where.get(k[0], "").split(",") if w})
        if affected:
            b += ["Workflows affected: " + ", ".join(f"`{w}`" for w in affected), ""]
    if yfail or dis or new["warnings"]:
        b += ["### 🟡 Worth knowing", ""]
        for env, line in sorted(new["warnings"]):
            b.append(f"- `{env}`: conda silently ignores the dependency line `{line}` "
                     "(a mapping, not a spec): the pin it means has no effect")
        for k in sorted(yfail):
            b.append(f"- {fmt_key(k)} fails: {short(yfail[k])}")
        for e in sorted(dis):
            b.append(f"- `{e}` linux-64, the tools disagree: {dis[e]}")
        b.append("")
    if green:
        gd = f" ({args.green_date})" if args.green_date else ""
        b += [f"### What changed since the last all-green day{gd}", ""]
        if spec_since_green:
            b += ["Environment files edited: " + ", ".join(f"`{e}`" for e in spec_since_green), ""]
        b += ["Key packages, in the solves that still work:", "", changes_table(since_green)]
    m = new["meta"]
    b += ["<details><summary>Runtimes, tools and expected failures</summary>", "",
          f"- Colab: {m['colab'].get('ubuntu', '?')}, Python {m['colab'].get('python', '?')}, "
          f"runtime versions {m['colab'].get('runtimes', '?')}",
          f"- GitHub ubuntu-latest: {m['runner'].get('os', '?')}, image {m['runner'].get('image', '?')}, "
          f"Python {m['runner'].get('python', '?')}, glibc {m['runner'].get('glibc', '?')}",
          "- Tools: " + "; ".join(f"{t} = {v}" for t, v in sorted(m["tools"].items()))]
    for k in sorted(info):
        b.append(f"- expected: {fmt_key(k)} — {info[k]}")
    b += ["", "</details>", ""]
    body = "\n".join(b)

    # ---------------- comment: only what changed today ----------------
    c = []
    if new_red:
        c += ["**New failures**", ""] + [f"- {fmt_key(k)}: {short(red[k])}" for k in new_red] + [""]
    if fixed:
        c += ["**Fixed**: " + ", ".join(fmt_key(k) for k in fixed), ""]
    if new_yfail:
        c += ["**New 🟡 failures**", ""] + [f"- {fmt_key(k)}: {short(yfail[k])}" for k in new_yfail] + [""]
    if fixed_yfail:
        c += ["**🟡 fixed**: " + ", ".join(fmt_key(k) for k in fixed_yfail), ""]
    if dis_changed:
        c += ["**Tools agreement changed (linux-64)**", ""]
        c += [f"- `{e}`: {dis.get(e, 'now agree')}" for e in dis_changed] + [""]
    if metas:
        c += ["**Runtime changes**", ""] + [f"- {x}" for x in metas] + [""]
    if prev and new["warnings"] != prev["warnings"]:
        added = sorted(new["warnings"] - prev["warnings"])
        if added:
            c += ["**Env file lines conda ignores**", ""] + [f"- `{e}`: `{l}`" for e, l in added] + [""]
    notable = bool(c)
    if notable:
        if spec_changed:
            c += ["Environment files edited since yesterday: " + ", ".join(f"`{e}`" for e in spec_changed), ""]
        if today_changes:
            c += ["Key package changes since yesterday:", "", changes_table(today_changes, 20)]
        if tools:
            c += ["Tool versions: " + "; ".join(tools), ""]
        c.insert(0, f"### {headline}\n")
    comment = "\n".join(c)

    # ---------------- full report (job summary) ----------------
    r = [f"## Drift daily check: {headline}", ""]
    if not prev:
        r += ["First run (no previous snapshot): today's results are the baseline.", ""]
    r += [body, "## Changes since yesterday", "",
          ("Environment files edited: " + ", ".join(f"`{e}`" for e in spec_changed) + "\n") if spec_changed else "",
          changes_table(today_changes, 200),
          ("Runtime changes: " + "; ".join(metas) + "\n") if metas else "",
          ("Tool versions: " + "; ".join(tools) + "\n") if tools else ""]
    report = "\n".join(r)

    os.makedirs(args.out, exist_ok=True)
    open(os.path.join(args.out, "issue_body.md"), "w").write(body)
    open(os.path.join(args.out, "comment.md"), "w").write(comment)
    open(os.path.join(args.out, "report.md"), "w").write(report)
    status = {"red": len(red), "yellow": len(yfail) + len(dis) + len(new["warnings"]), "notable": notable,
              "all_green": not red, "solves": n_solves, "ok": n_ok, "baseline": prev is None}
    json.dump(status, open(os.path.join(args.out, "status.json"), "w"))
    print(json.dumps(status))


if __name__ == "__main__":
    main()
