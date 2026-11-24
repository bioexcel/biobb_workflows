#!/usr/bin/env python3
"""Summarise the weekly scheduled test round into one issue ("Drift: weekly tests").

For each test workflow of the weekly round (docs/ci.md §1.1c) it takes the latest
completed run started by the schedule, lists the failed and cancelled test jobs with
links, and compares the failed set with the previous scheduled run of the same
workflow.

Writes into --out: issue_body.md (current state of the whole round), comment.md (only
when the TRIGGER workflow's failed set changed; empty otherwise), status.json.

Needs the gh CLI (GH_TOKEN). Usage:
  python3 weekly_report.py --repo OWNER/NAME --out DIR [--trigger FILE] [--event schedule]
"""
import argparse
import json
import os
import subprocess

ROUND = [  # (workflow file, day, what)
    ("python-tests.yaml", "Mon", "python (conda), Linux + macOS"),
    ("python-container-tests.yaml", "Tue", "python, container mode"),
    ("cwl-tests.yaml", "Wed", "CWL"),
    ("airflow-tests.yaml", "Wed", "Airflow"),
    ("nextflow-tests.yaml", "Thu", "Nextflow"),
    ("flavour-tests.yaml", "Thu", "Docker images (test only)"),
    ("jupyter-tests.yaml", "Fri", "Jupyter notebooks"),
    ("galaxy-tests.yaml", "Sat", "Galaxy (BioBB Galaxy server)"),
    ("colab-check.yaml", "Sat", "Colab (notebooks in Google's Colab image)"),
    ("macos-notebooks.yaml", "Sun", "notebooks on a real Mac"),
]
BAD = {"failure", "timed_out", "startup_failure"}


def gh(*args):
    out = subprocess.run(["gh", *args], capture_output=True, text=True, check=True).stdout
    return json.loads(out) if out.strip() else []


def runs(repo, wf, event, n=2):
    rs = gh("run", "list", "--repo", repo, "--workflow", wf, "--event", event, "--limit", "10",
            "--json", "databaseId,conclusion,status,createdAt,url")
    return [r for r in rs if r["status"] == "completed"][:n]


def jobs(repo, run_id):
    js = gh("run", "view", str(run_id), "--repo", repo, "--json", "jobs")["jobs"]
    failed, cancelled, ok = {}, {}, 0
    for j in js:
        name = j["name"].split(" / ")[0]
        if name.startswith("Detect workflows"):
            if j["conclusion"] in BAD:
                failed[name] = j["url"]
            continue
        if j["conclusion"] in BAD:
            failed[name] = j["url"]
        elif j["conclusion"] == "cancelled":
            cancelled[name] = j["url"]
        elif j["conclusion"] == "success":
            ok += 1
    return failed, cancelled, ok


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--trigger", default="")
    ap.add_argument("--event", default="schedule")
    args = ap.parse_args()

    rows, total_failed, comment = [], 0, []
    for wf, day, what in ROUND:
        rs = runs(args.repo, wf, args.event)
        if not rs:
            rows.append((day, what, wf, None, {}, {}, 0))
            continue
        failed, cancelled, ok = jobs(args.repo, rs[0]["databaseId"])
        total_failed += len(failed)
        rows.append((day, what, wf, rs[0], failed, cancelled, ok))
        if wf == args.trigger:
            prev_failed = jobs(args.repo, rs[1]["databaseId"])[0] if len(rs) > 1 else {}
            new = sorted(set(failed) - set(prev_failed))
            fixed = sorted(set(prev_failed) - set(failed))
            if new or fixed or len(rs) == 1 and failed:
                comment.append(f"### {what} ({day}) — [run]({rs[0]['url']})\n")
                if new:
                    comment.append("**Newly failing**: " + ", ".join(f"[{n}]({failed[n]})" for n in new) + "\n")
                if fixed:
                    comment.append("**Fixed**: " + ", ".join(fixed) + "\n")
                still = sorted(set(failed) & set(prev_failed))
                if still:
                    comment.append("Still failing: " + ", ".join(still) + "\n")

    head = (f"## 🔴 {total_failed} test job(s) failing in the latest weekly round"
            if total_failed else "## 🟢 the latest weekly round is green")
    b = [head, "",
         "Updated after every scheduled test run (`.github/workflows/drift-weekly-report.yaml`, "
         "docs/ci.md §1.1c). A red scheduled run usually means the outside world changed "
         "(conda packages, runner image), not a bad push: compare with the "
         "\"Drift: daily check\" issue and `docs/testing.md` §1.5b.", "",
         "| day | flavour | last scheduled run | result | failing |", "| --- | --- | --- | --- | --- |"]
    for day, what, wf, run, failed, cancelled, ok in rows:
        if not run:
            b.append(f"| {day} | {what} | not run yet | | |")
            continue
        res = f"{ok} ok" + (f", {len(failed)} failed" if failed else "") + \
              (f", {len(cancelled)} cancelled" if cancelled else "")
        fl = ", ".join(f"[{n}]({u})" for n, u in sorted(failed.items())) or "—"
        b.append(f"| {day} | {what} | [{run['createdAt'][:10]}]({run['url']}) | {res} | {fl} |")
    b += ["", "Cancelled jobs are not failures: a push to the same workflow cancels its scheduled "
          "job (the push run tests the newer state), and macOS jobs can be cancelled when GitHub "
          "has no runner available.", ""]

    os.makedirs(args.out, exist_ok=True)
    open(os.path.join(args.out, "issue_body.md"), "w").write("\n".join(b))
    open(os.path.join(args.out, "comment.md"), "w").write("\n".join(comment))
    status = {"red": total_failed, "notable": bool(comment)}
    json.dump(status, open(os.path.join(args.out, "status.json"), "w"))
    print(json.dumps(status))


if __name__ == "__main__":
    main()
