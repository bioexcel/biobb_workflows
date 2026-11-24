#!/usr/bin/env python3
"""Gather everything needed to triage the drift checks into one Markdown "triage pack".

Read by the /drift-triage skill (.claude/skills/drift-triage/SKILL.md), locally or in
GitHub Actions. Read-only: it never comments, pushes or changes anything.

Sections of the pack:
  1. open issues labelled `drift` (body + the latest comments)
  2. failed jobs: of the latest SCHEDULED run of each weekly-round test workflow (default)
     or of the runs given with --run, each with the error lines of its log
  3. daily environment check: from the drift-snapshots branch, every red solve today, its
     reason, and the key package versions that changed since the last all-green day
  4. past cases: rows of docs/testing.md tables that mention the packages/tools named in
     the errors (§1.5b drift fixes, §2.1 pitfalls)

Needs: gh (authenticated), git. Usage:
  python3 common/drift/triage_collect.py [--repo OWNER/NAME] [--run ID ...] [--out FILE]
"""
import argparse
import json
import os
import re
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import report  # noqa: E402  (snapshot loading/classification of the daily check)
import weekly_report  # noqa: E402  (the weekly round's workflows)

ERR = re.compile(r"error|Error|ERROR|FAILED|Traceback|exit code|exit status|ModuleNotFound|ImportError|"
                 r"Unsatisfiable|nothing provides|conflict|cannot|No such file|not found|Killed|"
                 r"Segmentation|timed out|denied|refused|HTTP \d{3}|assert")
TOKEN = re.compile(r"\b(biobb_[a-z_]+|[a-z][a-z0-9_.+-]{2,})\b")
NOISE = {"error", "errors", "failed", "the", "and", "for", "with", "not", "found", "file", "line",
         "from", "this", "that", "run", "test", "tests", "python", "exit", "code", "cannot", "process",
         "completed", "conda", "found", "none", "true", "false", "home", "runner", "work", "usr", "lib"}


def sh(*cmd, check=False):
    r = subprocess.run(cmd, capture_output=True, text=True)
    if check and r.returncode:
        raise RuntimeError(f"{' '.join(cmd)}: {r.stderr.strip()[:300]}")
    return r.stdout


def gh_json(*args):
    out = sh("gh", *args)
    return json.loads(out) if out.strip() else []


def issues(repo):
    out = []
    for i in gh_json("issue", "list", "--repo", repo, "--label", "drift", "--state", "open",
                     "--json", "number,title,url"):
        d = gh_json("issue", "view", str(i["number"]), "--repo", repo, "--json", "body,comments")
        comments = d.get("comments", [])[-5:]
        out.append({**i, "body": d.get("body", ""), "comments": [c.get("body", "") for c in comments]})
    return out


def failed_jobs(repo, run_ids):
    """[(workflow, run_url, job_name, job_url, job_id)]"""
    runs = []
    if run_ids:
        for rid in run_ids:
            d = gh_json("run", "view", str(rid), "--repo", repo, "--json", "workflowName,url,jobs")
            runs.append((d["workflowName"], d["url"], d["jobs"]))
    else:
        for wf, _, what in weekly_report.ROUND:
            rs = weekly_report.runs(repo, wf, "schedule", 1)
            if rs and rs[0]["conclusion"] not in ("success", "skipped"):
                d = gh_json("run", "view", str(rs[0]["databaseId"]), "--repo", repo, "--json", "jobs")
                runs.append((f"{wf} ({what})", rs[0]["url"], d["jobs"]))
    out = []
    for wf, url, jobs in runs:
        for j in jobs:
            if j.get("conclusion") in weekly_report.BAD:
                out.append((wf, url, j["name"], j.get("url", ""), j.get("databaseId")))
    return out


def error_lines(repo, job_id):
    """The useful part of a failed job's log, root cause first:
    1. biobb commands that ended with a non-zero exit code (+ the module/version line),
    2. the FIRST failing pytest test and its assertion/E lines (later failures are often
       consequences of the first),
    3. pytest's short summary, 4. other error lines (last ones), 5. the last lines."""
    log = sh("gh", "run", "view", "--repo", repo, "--job", str(job_id), "--log-failed")
    lines = [re.sub(r"^[^\t]*\t[^\t]*\t\S+Z ", "", l).rstrip() for l in log.splitlines()]
    out = []

    def add(title, items, limit):
        items = [i[:300] for i in dict.fromkeys(items) if i.strip()][:limit]
        if items:
            out.append(f"--- {title} ---")
            out.extend(items)

    cmds = []
    for i, l in enumerate(lines):
        if re.search(r"finalized with exit code [1-9]|exit code [1-9]\d*\b|returned non-zero", l):
            mod = next((lines[j] for j in range(i, max(i - 6, 0), -1) if "Module:" in lines[j]), "")
            cmds += [mod.strip(), l.strip()]
    add("commands that failed", cmds, 16)

    first = next((i for i, l in enumerate(lines) if re.match(r"^_{3,} test\w* .*_{3,}$", l.strip())), None)
    if first is not None:
        block = lines[first:first + 120]
        add("first failing test", [block[0]] + [l for l in block[1:] if re.match(r"^(E |>)", l.strip())
                                                 or "exit code" in l or "Error" in l], 25)

    summ = next((i for i, l in enumerate(lines) if "short test summary info" in l), None)
    if summ is not None:
        add("pytest summary", [l for l in lines[summ + 1:summ + 40] if l.startswith(("FAILED", "ERROR"))], 20)

    add("other error lines (last)", [l for l in lines if ERR.search(l)][-15:], 15)
    add("last lines", lines[-12:], 12)
    return out


def snapshots(repo):
    """(red, yellow_fail, since_green, green_date) from the drift-snapshots branch, or None."""
    tmp = tempfile.mkdtemp(prefix="drift-snap-")
    url = f"https://github.com/{repo}.git"
    r = subprocess.run(["git", "clone", "--quiet", "--depth", "1", "--branch", "drift-snapshots", url, tmp],
                       capture_output=True, text=True)
    if r.returncode:
        return None
    new = report.load(os.path.join(tmp, "latest"))
    green = report.load(os.path.join(tmp, "last-green"))
    if not new:
        return None
    red, yfail, _ = report.classify(new, ROOT)
    since = report.key_changes(green, new) if green else {}
    gdate = open(os.path.join(tmp, "last-green", "DATE")).read().strip() if green else "never"
    ldate = open(os.path.join(tmp, "latest", "DATE")).read().strip()
    names = {n.lower() for (_, _, pkgs) in new["solves"].values() for n in pkgs}
    return red, yfail, since, gdate, ldate, names


GENERIC = re.compile(r"^(biob|biobb|biobb_wf.*|pytest|tools?|tests?|ligand|scree.*|complex.*|parsing|setup|"
                     r"python|conda|docker|step\d*|workflow.*|runner|home|users)$")


def past_cases(words, packages, limit=10):
    """Table rows of docs/testing.md that share PACKAGE names with the errors, best first.
    Only words that are real conda package names (from today's solves) count, so everyday
    words ("config", "final") and workflow names do not produce false matches."""
    path = os.path.join(ROOT, "docs", "testing.md")
    if not os.path.isfile(path):
        return []
    words = {w for w in words if not GENERIC.match(w) and (w in packages or w.startswith("biobb_"))}
    rows = [l for l in open(path).read().splitlines() if l.startswith("| ") and not l.startswith("| ---")]
    scored = []
    for row in rows:
        low = row.lower()
        hit = sorted(w for w in words if re.search(r"(?<![a-z0-9_])" + re.escape(w) + r"(?![a-z0-9_])", low))
        if hit:
            scored.append((len(hit), hit, row))
    scored.sort(key=lambda x: -x[0])
    return [(hit, row) for _, hit, row in scored[:limit]]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", default=os.environ.get("GITHUB_REPOSITORY", "bioexcel/biobb_workflows"))
    ap.add_argument("--run", action="append", default=[], help="triage this run id (repeatable)")
    ap.add_argument("--out")
    a = ap.parse_args()

    md, words = ["# Drift triage pack", "", f"Repository `{a.repo}`.", ""], set()

    md += ["## 1. Open drift issues", ""]
    iss = issues(a.repo)
    if not iss:
        md += ["_none open_", ""]
    for i in iss:
        md += [f"### #{i['number']} {i['title']} ({i['url']})", "", i["body"].strip(), ""]
        for c in i["comments"]:
            md += ["> " + c.strip().replace("\n", "\n> "), ""]

    md += ["## 2. Failed jobs" + (" (runs given)" if a.run else " (latest scheduled run of each flavour)"), ""]
    jobs = failed_jobs(a.repo, a.run)
    if not jobs:
        md += ["_none_", ""]
    for wf, run_url, name, job_url, jid in jobs:
        lines = error_lines(a.repo, jid)
        md += [f"### {name} — {wf}", f"run {run_url} · job {job_url}", "", "```", *lines, "```", ""]
        for l in lines:
            words |= {t.lower() for t in TOKEN.findall(l) if t.lower() not in NOISE}

    md += ["## 3. Daily environment check (drift-snapshots branch)", ""]
    snap = snapshots(a.repo)
    packages = set()
    if snap is None:
        md += ["_no snapshot branch yet_", ""]
    else:
        red, yfail, since, gdate, ldate, packages = snap
        md += [f"Latest snapshot {ldate}; last all-green day {gdate}.", ""]
        for k, reason in sorted(red.items()):
            md += [f"- RED {k[0]} {k[1]} {k[2]}: {reason[:600]}"]
            words |= {t.lower() for t in TOKEN.findall(reason) if t.lower() not in NOISE}
        for k, reason in sorted(yfail.items()):
            md += [f"- yellow {k[0]} {k[1]} {k[2]}: {reason[:300]}"]
        md += ["", "Key package changes since the last all-green day (solves that still work):", "",
               report.changes_table(since, 60)]
        words |= {n for (n, _, _) in since}

    md += ["## 4. Past cases that mention the same packages/tools (docs/testing.md)", ""]
    cases = past_cases(words, packages if snap else set())
    if not cases:
        md += ["_none found_", ""]
    for hit, row in cases[:25]:
        md += [f"- matches {', '.join(hit[:6])}:", f"  {row[:900]}"]
    md += [""]

    text = "\n".join(md)
    if a.out:
        open(a.out, "w").write(text)
        print(f"triage pack written to {a.out} ({len(jobs)} failed job(s), {len(iss)} open issue(s))")
    else:
        print(text)


if __name__ == "__main__":
    main()
