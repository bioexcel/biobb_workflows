---
name: drift-triage
description: Explain why the scheduled drift checks or weekly tests of biobb_workflows failed and prepare a fix for review. Use when a "Drift: daily check" or "Drift: weekly tests" issue opened or got a comment, when a scheduled test run failed, when the user runs /drift-triage, or when asked why the weekly/daily checks are red.
---

# Drift triage: why did it break, and what is the smallest fix?

The scheduled checks find breakage that comes from OUTSIDE the repository (conda
packages, GitHub's machines, Colab, external services). Your job: find the root cause,
explain it in plain words in the drift issue, and, when the fix is simple, prepare it on
a branch as a draft pull request for the user to review. The user prefers plain
language: say what broke, why, what you propose, how sure you are.

## Where things are

- Collector: `python3 common/drift/triage_collect.py [--run RUN_ID ...] --out <scratch>/pack.md`
  builds one Markdown "triage pack": open drift issues, failed jobs with the root-cause
  part of their logs (biobb commands with a non-zero exit code first, then the FIRST
  failing test; later failures are usually consequences), the daily solve results
  (red solves, key package versions changed since the last all-green day), and rows of
  `docs/testing.md` that mention the same packages. Read-only.
- How the checks work: `docs/ci.md` §1.1c (weekly round) and §1.1d (daily check).
- Past breakages and their fixes: `docs/testing.md` §1.5b (drift fixes) and §2.1
  (pitfalls). Check them first: the same thing often breaks again.
- Rules for changes: `AGENTS.md` (version-bump rules, `check_versions.py`, no
  workflow-level `concurrency:`).
- Snapshots: branch `drift-snapshots` (`latest/`, `last-green/`, history per day).

## Procedure

1. **Collect.** Run the collector (no arguments = latest scheduled runs + issues; add
   `--run <id>` for a specific failed run). Read the whole pack.
2. **Group.** Failures with the same root cause count once (e.g. one missing binary
   breaks 7 workflows on 3 flavours). Write down, per group: the workflows and flavours,
   the first error, since when (last green scheduled run / last-green snapshot date).
3. **Classify** each group with the signals below. Do not guess: every claim needs a
   line from a log, a version from the snapshots, or a date.

   | Cause | Signals | Usual fix |
   | --- | --- | --- |
   | A conda package changed upstream | the daily check's "changed since the last all-green day" lists a package used by the failing step; errors like exit code 127 (binary gone), ImportError, changed CLI/API; several workflows sharing that package fail together | pin the package (or a build) in the env files, or move to a fixed biobb version. Check the package's changelog / feedstock first |
   | GitHub's machine changed | runner change in the daily check (Ubuntu, Python, glibc); errors about wheels, compilers, glibc, executable stack; only pip/container mode or only one OS fails | a CI-side line: `.github/workflows/*.yaml`, `tests/*/run_*.sh` (e.g. setup-python, CFLAGS) |
   | conda tools disagree | daily check "tools disagree"; only micromamba or mamba fails | usually document only; pin if users are affected (mamba = the Colab cell) |
   | Colab changed | daily check Colab change (Python, Ubuntu, runtime list) | the notebooks' Colab cell, in the jupyter repos: propose only, the user decides |
   | External service or data | downloads from RCSB/PDB/MMB APIs, HTTP 5xx, timeouts, DNS; fails once, passes on re-run | re-run; report if it persists |
   | GitHub capacity | "job was not acquired", cancelled macOS jobs | re-run, nothing to fix |
   | A real regression (not drift) | the failure started with a commit to that workflow (`git log` since the last green scheduled run) | point to the commit; the author fixes it |
   | Limits of the CI machine | killed / out of memory (cmip needs ~25 GB) | a `tests/<flavour>/SKIP` file, only if the user agrees |

4. **Check the hypothesis cheaply** before proposing anything:
   - versions: compare `latest/` and `last-green/` on `drift-snapshots`; `conda search`;
     the package's release notes or feedstock;
   - a proposed pin: dry-run solve the env with it
     (`common/drift/list_envs.py` + `common/drift/solve.py`, see `common/drift/README.md`);
   - a quick local reproduction only if it takes minutes.
5. **Explain**: one comment in the matching drift issue (`gh issue comment N --body-file f`):

   ```
   ### Triage <date>: <one-line cause>
   **What broke:** <workflows, flavours, the failing step>
   **Why:** <cause in plain words> — evidence: <log line / version change / date>
   **Proposed fix:** <smallest change> (draft PR #<n> | not prepared because <reason>)
   **Confidence:** high / medium / low, and what would confirm it
   ```
6. **Prepare the fix** only when it is small and safe (a pin, a CI line, a build pin):
   - branch `claude/drift-<YYYYMMDD>-<short-slug>` from `main`;
   - follow AGENTS.md (a biobb version change also updates requirements.txt, the
     container tags and `docker/VERSION`; `python3 common/python/check_versions.py`
     must pass);
   - add the case as a row to `docs/testing.md` §1.5b in the same branch;
   - push and open a **draft** PR (`gh pr create --draft`) that links the issue and
     contains the explanation. The push runs the touched workflows' tests on the branch
     (test-what-you-changed): mention them in the PR.

## Who you run for (two modes)

- **Interactive** (the user ran `/drift-triage` in Claude Code): show the explanation
  and the planned change first; post the comment, push the branch and open the draft PR
  only after the user says yes.
- **In GitHub Actions** (`GITHUB_ACTIONS=true`, started by `drift-triage.yaml` when that
  variant is installed): you may post ONE comment per issue per run and open draft PRs on
  `claude/drift-*` branches. Nothing else.

## Never

- merge, push to `main`, or approve a PR;
- publish anything (images, WorkflowHub, bio.tools) or run publish workflows;
- touch secrets, repository settings, or switch workflows on/off;
- edit the jupyter repositories (separate repos; propose, the user decides);
- bump the biobb release versions (that is `/biobb-release`), or make tests pass by
  skipping them (`SKIP` files, deleted assertions) without the user;
- close drift issues: the checks close them when they are green again.
