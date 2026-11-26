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
    """{env: text} when the three tools disagree on whether the env installs on linux-64, or
    {env: {pkg: {tool: version}}} when they all install it but pick different key versions."""
    out = {}
    envs = sorted({k[0] for k in snap["solves"]})
    for env in envs:
        res = {s: snap["solves"].get((env, "linux-64", s)) for s in ("conda", "mamba", "micromamba")}
        res = {s: r for s, r in res.items() if r is not None}
        if len(res) < 2:
            continue
        status = {s: r[0] for s, r in res.items()}
        if len(set(status.values())) > 1:
            out[env] = "installs with " + " and ".join(s for s, v in status.items() if v) + \
                       " but not with " + " and ".join(s for s, v in status.items() if not v) + "."
            continue
        if not all(status.values()):
            continue
        diffs = {}
        names = set().union(*(set(r[2]) for r in res.values()))
        for n in sorted(x for x in names if KEY.match(x)):
            vers = {s: r[2].get(n, "—") for s, r in res.items()}
            if len(set(vers.values())) > 1:
                diffs[n] = vers
        if diffs:
            out[env] = diffs
    return out


def disagreement_lines(dis, envs=None):
    """Markdown for disagreements: status differences as bullets, version differences as a table."""
    envs = sorted(dis) if envs is None else envs
    lines, rows = [], []
    for e in envs:
        d = dis.get(e)
        if d is None:
            lines.append(f"- **{label(e)}**: conda, mamba and micromamba agree again.")
        elif isinstance(d, str):
            lines.append(f"- **{label(e)}** on Linux {d}")
        else:
            for n, vers in d.items():
                rows.append(f"| {label(e)} | {n} | " + " | ".join(vers.get(t, "") for t in TOOLS) + " |")
    if rows:
        lines += ([""] if lines else []) + ["On Linux, conda, mamba and micromamba pick different versions here, so users get a "
                  "different install depending on the tool (— = not installed):", "",
                  "| Environment | Package | conda | mamba | micromamba |", "| --- | --- | --- | --- | --- |"] + rows
    return lines


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


PLATFORM = {"linux-64": "Linux", "osx-64": "Intel Mac", "osx-arm64": "Apple-silicon Mac"}
TOOLS = ("conda", "mamba", "micromamba")
ROSETTA = "no osx-arm64 solution; osx-64 solves (CI and Mac users fall back to Rosetta)"


def label(env):
    """python__biobb_wf_pmx_tutorial -> 'pmx_tutorial (python)'; jupyter__biobb_wf_cmip -> 'cmip (tutorial)'."""
    flavour, _, wf = env.partition("__")
    name = wf[len("biobb_wf_"):] if wf.startswith("biobb_wf_") else wf
    return f"{name} ({'tutorial' if flavour == 'jupyter' else flavour})"


def fmt_key(key):
    env, platform, solver = key
    tool = f" with {solver}" if platform == "linux-64" else ""
    return f"**{label(env)}** on {PLATFORM.get(platform, platform)}{tool}"


def short(reason):
    reason = (reason or "").replace("|", "/").replace("\n", " ")
    return reason if len(reason) <= MAX_REASON else reason[:MAX_REASON] + " …"


def places(keys):
    """'Linux, Intel Mac' from env/platform/solver keys of ONE env; a Linux tool is named only
    when not all three tools are concerned."""
    by_plat = {}
    for _, platform, solver in keys:
        by_plat.setdefault(platform, set()).add(solver)
    out = []
    for platform in ("linux-64", "osx-64", "osx-arm64"):
        if platform not in by_plat:
            continue
        name = PLATFORM[platform]
        if platform == "linux-64" and by_plat[platform] != set(TOOLS):
            name += " (" + ", ".join(t for t in TOOLS if t in by_plat[platform]) + ")"
        out.append(name)
    return ", ".join(out)


def where_text(where, edited=(), limit=4):
    """where = ['env/platform/solver', ...] -> 'pmx_tutorial (python): Linux, Intel Mac (we edited ...)'."""
    by_env = {}
    for w in where:
        env, platform, solver = w.split("/")
        by_env.setdefault(env, []).append((env, platform, solver))
    parts = []
    for env in sorted(by_env)[:limit]:
        t = f"{label(env)}: {places(by_env[env])}"
        if env in edited:
            t += " (we edited its environment file)"
        parts.append(t)
    if len(by_env) > limit:
        parts.append(f"and {len(by_env) - limit} more")
    return "; ".join(parts)


def changes_table(ch, edited=(), limit=40):
    if not ch:
        return "Nothing changed in the key packages.\n"
    rows = ["| Package | Before → Now | Where |", "| --- | --- | --- |"]
    for (n, a, b), where in sorted(ch.items())[:limit]:
        a = "not installed" if a == "(absent)" else a
        b = "not installed" if b == "(absent)" else b
        rows.append(f"| {n} | {a} → {b} | {where_text(where, edited)} |")
    if len(ch) > limit:
        rows.append(f"| … | | {len(ch) - limit} more changes in the run details |")
    return "\n".join(rows) + "\n"


def group_envs(envs):
    """'tutorials: a, b; python: c, d' from env ids."""
    tut = sorted(label(e).rsplit(" (", 1)[0] for e in envs if e.startswith("jupyter__"))
    py = sorted(label(e).rsplit(" (", 1)[0] for e in envs if not e.startswith("jupyter__"))
    out = []
    if tut:
        out.append("tutorials: " + ", ".join(tut))
    if py:
        out.append("python: " + ", ".join(py))
    return "; ".join(out)


def known_limits(info):
    rosetta = sorted({k[0] for k, why in info.items() if why == ROSETTA})
    skip = {}
    for (env, platform, _), why in info.items():
        if why.startswith("MACOS_SKIP"):
            skip.setdefault(env, set()).add(platform)
    other = {k: why for k, why in info.items() if why != ROSETTA and not why.startswith("MACOS_SKIP")}
    lines = []
    if rosetta:
        lines.append("- **No Apple-silicon version; installs as the Intel-Mac version, which Apple-silicon "
                     "Macs run through Rosetta** (our Mac check does the same): " + group_envs(rosetta) + ".")
    if skip:
        items = []
        for env in sorted(skip):
            macs = "any Mac" if {"osx-64", "osx-arm64"} <= skip[env] else \
                   ", ".join(PLATFORM[p] for p in sorted(skip[env]))
            items.append(f"{label(env)}, {macs}")
        lines.append("- **Known not to work on Mac** (the workflow has a `MACOS_SKIP` file with the reason): "
                     + "; ".join(items) + ".")
    for k, why in sorted(other.items()):
        lines.append(f"- {fmt_key(k)}: {why}")
    return lines


def versions_line(m):
    tools = {}
    for t, v in sorted(m["tools"].items()):
        name = t.split("__")[0]
        v = v if v.startswith(name) else f"{name} {v}"
        tools.setdefault(v, None)
    c, r = m["colab"], m["runner"]
    return (f"- Versions seen today: Colab Python {c.get('python', '?')} on {c.get('ubuntu', '?')}; "
            f"GitHub's Linux machine {r.get('os', '?')} with Python {r.get('python', '?')}; "
            + ", ".join(tools) + ".")


def today():
    import datetime
    d = datetime.datetime.now(datetime.timezone.utc)
    return f"{d.day} {d:%b %Y}"


def nice_date(iso):
    import datetime
    try:
        d = datetime.date.fromisoformat(iso)
        return f"{d.day} {d:%b}"
    except ValueError:
        return iso


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
    n_envs = len({k[0] for k in new["solves"]})
    date = today()
    run_link = f"[Run details]({args.run_url})" if args.run_url else ""
    n_red_envs = len({k[0] for k in red})
    if red:
        headline = f"🔴 {n_red_envs} environment{'s' if n_red_envs != 1 else ''} no longer install — {date}"
    else:
        headline = f"🟢 All environments install — {date}"

    # ---------------- issue body: the current state ----------------
    b = [f"## {headline}", "",
         f"Checked {n_envs} environment files on Linux and Mac. "
         + ("Nothing new is broken. " if not red else "Some no longer install (below). ") + run_link, ""]
    if red:
        b += ["### 🔴 No longer installs", "",
              "This breaks CI, the Docker image builds, users or Colab.", "",
              "| Environment | Where | Why (from the installer) |", "| --- | --- | --- |"]
        for k in sorted(red):
            tool = f" with {k[2]}" if k[1] == "linux-64" else ""
            b.append(f"| {label(k[0])} | {PLATFORM.get(k[1], k[1])}{tool} | {short(red[k])} |")
        b.append("")
        idx = new["index"]
        affected = sorted({w for k in red for w in idx.get(k[0], "").split(",") if w})
        if affected:
            b += ["Workflows affected: " + ", ".join(f"`{w}`" for w in affected), ""]
    if yfail or dis or new["warnings"]:
        b += ["### 🟡 Worth a look (not broken)", ""]
        for env, line in sorted(new["warnings"]):
            b.append(f"- **{label(env)}**: conda ignores the line `{line}` in its environment file, "
                     "so that pin has no effect.")
        for k in sorted(yfail):
            b.append(f"- {fmt_key(k)} does not install: {short(yfail[k])}")
        b += disagreement_lines(dis)
        b.append("")
    if green:
        gd = f" ({nice_date(args.green_date)})" if args.green_date else ""
        b += [f"### Changed since the last good day{gd}", ""]
        b += [changes_table(since_green, spec_since_green)]
        b += ["Only key packages are compared (Python, numpy, AmberTools, GROMACS, Open Babel, "
              "PyTorch, the biobb packages, …).", ""]
        if spec_since_green:
            b += ["Environment files we edited since then: " + ", ".join(label(e) for e in spec_since_green), ""]
    m = new["meta"]
    b += ["<details><summary>Known limits, not counted as failures</summary>", ""]
    b += known_limits(info)
    b += [versions_line(m),
          f"- In numbers: {n_ok} of {n_solves} checks pass ({n_envs} files × 5: conda on Linux, Intel Mac "
          "and Apple-silicon Mac, plus mamba and micromamba on Linux); the rest are the known limits above"
          + (" and the failures listed above." if red or yfail else "."),
          "", "</details>", "",
          "<sub>Updated every day by `drift-daily.yaml`; this text is always the current state, the "
          "comments say what changed and when. How it works: `docs/ci.md` §1.1d.</sub>", ""]
    body = "\n".join(b)

    # ---------------- comment: only what changed today ----------------
    c = []
    if new_red:
        c += ["**No longer installs**", ""] + [f"- {fmt_key(k)}: {short(red[k])}" for k in new_red] + [""]
    if fixed:
        c += ["**Installs again**: " + "; ".join(fmt_key(k) for k in fixed), ""]
    if new_yfail:
        c += ["**🟡 New, not broken**", ""] + [f"- {fmt_key(k)} does not install: {short(yfail[k])}"
                                              for k in new_yfail] + [""]
    if fixed_yfail:
        c += ["**🟡 Installs again**: " + "; ".join(fmt_key(k) for k in fixed_yfail), ""]
    if dis_changed:
        c += ["**conda, mamba and micromamba: new differences (or agreeing again)**", ""]
        c += disagreement_lines(dis, dis_changed) + [""]
    if metas:
        c += ["**Colab or GitHub's machine changed**", ""] + [f"- {x}" for x in metas] + [""]
    if prev and new["warnings"] != prev["warnings"]:
        added = sorted(new["warnings"] - prev["warnings"])
        if added:
            c += ["**Lines conda ignores in an environment file**", ""] + \
                 [f"- {label(e)}: `{l}`" for e, l in added] + [""]
    notable = bool(c)
    if notable:
        if today_changes:
            c += ["**Package changes since yesterday**", "", changes_table(today_changes, spec_changed, 20)]
        elif spec_changed:
            c += ["Environment files we edited since yesterday: " + ", ".join(label(e) for e in spec_changed), ""]
        if tools:
            c += ["Install tool versions: " + "; ".join(tools), ""]
        icon = "🔴" if red else "🟢"
        c.insert(0, f"### {icon} {date}: what changed since yesterday\n")
        if run_link:
            c.append(run_link)
    comment = "\n".join(c)

    # ---------------- full report (job summary) ----------------
    r = [f"## Drift daily check: {headline}", ""]
    if not prev:
        r += ["First run (no previous snapshot): today's results are the baseline.", ""]
    r += [body, "## Changes since yesterday", "",
          changes_table(today_changes, spec_changed, 200),
          ("Environment files we edited: " + ", ".join(label(e) for e in spec_changed) + "\n") if spec_changed else "",
          ("Colab / GitHub changes: " + "; ".join(metas) + "\n") if metas else "",
          ("Install tool versions: " + "; ".join(tools) + "\n") if tools else ""]
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
