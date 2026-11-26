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
    ("python-tests.yaml", "Mon", "Python, with conda (Linux and Mac)"),
    ("python-container-tests.yaml", "Tue", "Python, with containers"),
    ("cwl-tests.yaml", "Wed", "CWL"),
    ("airflow-tests.yaml", "Wed", "Airflow"),
    ("nextflow-tests.yaml", "Thu", "Nextflow"),
    ("flavour-tests.yaml", "Thu", "Docker images (built and tested, not published)"),
    ("jupyter-tests.yaml", "Fri", "Jupyter notebooks"),
    ("galaxy-tests.yaml", "Sat", "Galaxy (tools installed on the BioBB Galaxy server)"),
    ("colab-check.yaml", "Sat", "Notebooks in Google Colab"),
    ("macos-notebooks.yaml", "Sun", "Notebooks on a real Mac"),
]


def short_name(job):
    """'biobb_wf_md_setup (ubuntu-latest)' -> 'md_setup (Linux)'."""
    n = job.replace("biobb_wf_", "")
    for a, b in (("(ubuntu-latest)", "(Linux)"), ("(macos-latest)", "(Mac)"), ("(macOS)", "(Mac)")):
        n = n.replace(a, b)
    return n


def links(d):
    return ", ".join(f"[{short_name(n)}]({u})" for n, u in sorted(d.items()))


def nice_date(iso):
    import datetime
    try:
        d = datetime.date.fromisoformat(iso[:10])
        return f"{d.day} {d:%b}"
    except ValueError:
        return iso[:10]
BAD = {"failure", "timed_out", "startup_failure"}
BOT_STARTED = {"colab-check.yaml"}  # also counts its runs started by drift-daily.yaml


def gh(*args):
    out = subprocess.run(["gh", *args], capture_output=True, text=True, check=True).stdout
    return json.loads(out) if out.strip() else []


def runs(repo, wf, event, n=2):
    fields = "databaseId,conclusion,status,createdAt,url"
    rs = gh("run", "list", "--repo", repo, "--workflow", wf, "--event", event, "--limit", "10",
            "--json", fields)
    if wf in BOT_STARTED and event == "schedule":
        # the daily check starts the Colab check by itself when Colab changes
        rs += gh("run", "list", "--repo", repo, "--workflow", wf, "--event", "workflow_dispatch",
                 "--user", "github-actions[bot]", "--limit", "10", "--json", fields)
        rs.sort(key=lambda r: r["createdAt"], reverse=True)
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
            if len(rs) == 1 and failed:
                new = sorted(failed)
            if new:  # only a NEW failure comments (each comment emails the user)
                comment.append(f"### 🔴 {what}: something needs fixing — [run]({rs[0]['url']})\n")
                comment.append("These tests passed last time and fail now: " +
                               links({n: failed[n] for n in new}) + "\n")
                still = sorted(set(failed) & set(prev_failed))
                if still:
                    comment.append("Already failing before (no change): " +
                                   ", ".join(short_name(n) for n in still) + "\n")
                comment.append("Claude will add its explanation and a proposed fix below in a few minutes.\n")

    n_fail_flavours = sum(1 for r in rows if r[4])
    head = (f"## 🔴 Last weekly round: {total_failed} test{'s' if total_failed != 1 else ''} failing"
            f" in {n_fail_flavours} flavour{'s' if n_fail_flavours != 1 else ''}"
            if total_failed else "## 🟢 Last weekly round: all tests pass")
    b = [head, "",
         "Every day one flavour of the tests runs on a timetable; this table shows the latest "
         "result of each. A red result usually means something outside our code changed (conda "
         "packages, GitHub's machines, Colab): the \"Drift: daily check\" issue often shows what.", "",
         "| Day | Tests | Last run | Result |", "| --- | --- | --- | --- |"]
    for day, what, wf, run, failed, cancelled, ok in rows:
        if not run:
            b.append(f"| {day} | {what} | not run yet | |")
            continue
        total = ok + len(failed)
        if failed:
            res = f"🔴 {len(failed)} of {total} failed: {links(failed)}"
        else:
            res = f"🟢 {ok} passed" if ok else "🟢 nothing to test"
        if cancelled:
            res += f" ({len(cancelled)} cancelled)"
        b.append(f"| {day} | {what} | [{nice_date(run['createdAt'])}]({run['url']}) | {res} |")
    b += ["", "<sub>Cancelled is not failed: a push cancels the scheduled run of the same tests (the "
          "push run tests the newer code), and Mac jobs are cancelled when GitHub has no Mac free. "
          "Updated after every scheduled run by `drift-weekly-report.yaml`; how it works: "
          "`docs/ci.md` §1.1c.</sub>", ""]

    os.makedirs(args.out, exist_ok=True)
    open(os.path.join(args.out, "issue_body.md"), "w").write("\n".join(b))
    open(os.path.join(args.out, "comment.md"), "w").write("\n".join(comment))
    status = {"red": total_failed, "notable": bool(comment)}
    json.dump(status, open(os.path.join(args.out, "status.json"), "w"))
    print(json.dumps(status))


if __name__ == "__main__":
    main()
