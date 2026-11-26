---
name: biobb-release
description: Update every BioBB workflow and flavour of biobb_workflows to a new set of biobb package versions (a BioBB release), test it, publish the images and the registry entries. Use when the user says a new BioBB release is out, asks to bump/update the biobb versions of the workflows, or runs /biobb-release.
---

# BioBB release: new biobb versions in every workflow and flavour

You drive the release; the scripts do the edits. Never hand-edit version strings: run
the scripts so every file is changed the same way. Stop and ask the user at the three
**GATES**; never push, merge or publish without an explicit yes at that gate.

Tools (all in this repo):
- `common/release/bump_versions.py` (scan / latest / check / apply): pins, image tags,
  conda lines, `docker/VERSION`, jupyter env files. Read its docstring once.
- `common/python/check_versions.py --strict-flavours`: every flavour of every workflow
  pins the same versions.
- `common/galaxy/galaxy_wf.py` (check / update / run): the Galaxy `.ga` workflows against
  https://biobb.usegalaxy.es.
- `common/drift/list_envs.py`, `common/drift/solve.py`: dry-run solves (nothing installed).
- Background: `docs/ci.md` §1.1-1.2 (update flow, publish chain), `docs/testing.md`
  §1.5b (past breakages and their fixes), `AGENTS.md`.

Keep a scratch folder for the release files (use the session scratchpad); below it is
`$REL`. The release label (e.g. `2026.2`) is `$LABEL`.

## 0. Preflight

1. Ask the user for the release label if they did not give it.
2. `git status` on `main`, up to date with origin (`git pull --ff-only`). Uncommitted
   user changes: leave them alone and never stage them; ask if they block a step.
3. The jupyter tutorial repos (`bioexcel/<repo>`; the three amber sub-workflows share
   `bioexcel/biobb_wf_amber`) are edited ONLY in their own checkouts in
   `../tutorials/<repo>` next to this repo (`$BIOBB_TUTORIALS` overrides),
   never through this repo's `<wf>/jupyter` submodules. In each:
   `git status -sb` clean and on main (ask otherwise), then `git pull --ff-only`.
4. `gh auth status` works (pushes, workflow runs).
5. Create the branch `release/$LABEL` in this repo.

## 1. Choose the versions (GATE 1)

1. `python3 common/release/bump_versions.py scan --jupyter` shows what is written today
   (flavours can be out of step: the release brings them in line).
2. `python3 common/release/bump_versions.py latest --jupyter --out $REL/release.json`
   proposes the latest bioconda version of every package.
3. Show the user the table (package, current, proposed). They may: accept, change a
   version, or remove a package (removed = untouched everywhere). If they give a list
   instead, write `$REL/release.json` from it (`{"versions": {...}, "overrides": {}}`).
4. `python3 common/release/bump_versions.py check $REL/release.json` and handle every
   line that is not `ok`:
   - **DECIDE** (a pin with an explanatory comment, e.g. "3.16.2 is the last working
     release"): read the comment, check whether the new version fixes the reason (the
     package changelog / issues), and ask the user: bump it, or keep the old pin (then
     remove that package from `release.json`, or leave that file out by asking).
   - **note: DIFFERENT kind of build**: an image changes family (e.g. a gromacs build of
     biobb_analysis replaced by the noarch one). Check the new image contains the tools
     those steps need (`docker run --rm quay.io/biocontainers/<pkg>:<tag> which gmx cpptraj`)
     or set an override.
   - **PROBLEM: no image yet**: bioconda builds the quay.io and depot images a few hours
     after the package. Wait and re-run `check`; do not work around it.
   - **PROBLEM: several builds**: add the override the message suggests, after asking.
5. GATE 1: show the final table, the decisions and the overrides. Continue only on yes.

## 2. Will it install? (before touching anything)

Apply to the files (they are in git, so this is reversible), then dry-run solve:

```bash
python3 common/release/bump_versions.py apply $REL/release.json --jupyter --docker-version $LABEL
python3 common/drift/list_envs.py $REL/solve --local-jupyter
python3 common/drift/solve.py --solver conda --exe "$(command -v conda)" --platform linux-64 \
  --work $REL/solve --out $REL/solve --jobs 3
```

Every environment must say `ok`. A failure is a real conflict in the new release: read
the reason, compare with `docs/testing.md` §1.5b, propose a fix (usually a pin) to the
user. osx-64 / osx-arm64 solves are optional (`--platform osx-64`): failures there are
only expected when the wf has `tests/python/MACOS_SKIP` (arm64 falls back to osx-64).

## 3. The rest of the release edits

1. Galaxy: `python3 common/galaxy/galaxy_wf.py update` then `check`. "server behind"
   means the BioBB Galaxy server lacks the newer tool: list those for the user (the
   server admins at INB must update it); never downgrade the `.ga`. Missing tools: same.
2. Consistency: `python3 common/python/check_versions.py --strict-flavours` must pass.
   After the first release done with this skill, switch `.github/workflows/python-lint.yaml`
   to `--strict-flavours` (ask).
3. Release-only reminders (check the user's memory notes too):
   - the temporary `Set up Python 3.12` steps in `.github/workflows/python-container-tests.yaml`
     go away once the biobb release no longer fixes Python (ask; their comment says so);
   - Colab (docs/testing.md §2.4): the notebooks' Colab cell (in the jupyter repos)
     hard-codes `lib/python3.12/site-packages` and creates the env without a Python pin,
     while Colab runs Python 3.13 (check `meta/colab.txt` on `drift-snapshots`). First
     dry-run solve the new jupyter envs with `python=<Colab's version>` added (as in
     step 2): on 2026-11-24 biobb_analysis, biobb_mem, biobb_amber, biobb_flexdyn and
     biobb_flexserv still declared `python <3.13`, and pmx pinned `scipy 1.13`. Tell the
     user which envs cannot get Colab's Python with the chosen versions. Then try the fix
     without editing anything: `gh workflow run colab-check.yaml -f try_python_fix=true`
     (env with Colab's Python + matching paths, test copy only). Agree the cell change
     with the user before editing the jupyter repos (`grep -rn "python3\." $BIOBB_TUTORIALS/<repo>/*/notebooks`
     also finds pmx's `gmxlib` path);
   - `docker/VERSION` was set to `$LABEL` by `apply --docker-version`.
4. Markdown files are not edited by the script; `scan` lists those quoting versions:
   update READMEs only where a version is part of an instruction.

## 4. Review (GATE 2)

Show the user: files changed per workflow (`git diff --stat`, and `git -C tutorials/<repo> diff
--stat` for each jupyter repo), the decisions from step 1, solve results, Galaxy report.
GATE 2: push only on yes.

## 5. Push and test

Order matters (docs/ci.md §1.2): images and the jupyter e2e read the jupyter repos'
`main` at build time.

1. Switch off the daily jupyter probe so it cannot publish images from the new jupyter
   envs under the old label while this repo is still being tested:
   `gh workflow disable jupyter-sync.yaml` (drift-daily leaves manually disabled
   workflows alone).
2. Each jupyter repo, in `tutorials/<repo>`: commit
   `Update biobb packages to the $LABEL release` and push to `main`.
3. This repo, on `release/$LABEL`: `git submodule update --remote` (the `<wf>/jupyter`
   pointers move to the pushed commits), commit the edits plus the pointer bumps
   (`git add <wf>/jupyter`), push. Every touched flavour's tests start on the branch,
   for all 19 workflows in parallel (docs/ci.md §1.1b).
4. Watch with `gh run list --branch release/$LABEL` / `gh run watch`. For each failure:
   `gh run view --log-failed`, compare with docs/testing.md §1.5b, explain the cause in
   plain words, propose a fix, push it to the branch after the user agrees. macOS
   "job not acquired" cancellations are GitHub capacity, not failures: re-run them.

## 6. Merge and publish (GATE 3)

GATE 3: all green (or every red explained and accepted by the user). Then:

1. Merge `release/$LABEL` into `main` WITHOUT `[skip ci]`: the `docker/VERSION` change
   starts the publish chain for every image (docker e2e, then publish only if green),
   tagged `$LABEL` + `latest`. Watch `publish-ghcr.yaml` to the end.
2. `gh workflow enable jupyter-sync.yaml`.
3. WorkflowHub (follow `.claude/skills/workflowhub-submission/SKILL.md`): audit with
   `wfh_stage.py --version $LABEL --dry-run`, then
   `gh workflow run workflowhub-publish.yml -f version=$LABEL -f target=production
   -f tutorials=<one wf>/` first, check it on workflowhub.eu with the user, then the
   rest (no filter). Write the ids of NEW entries into `workflowhub.manifest.yml`
   (release-follow-up commit).
4. bio.tools: `gh workflow run biotools-update.yml -f version=$LABEL` (dry run: read the
   summary, every entry must say `valid`, or `not checked` for the DNA helical parameters
   entry), then the same with `-f apply=true`. It adds the
   version, the WorkflowHub links of every flavour, the GitHub folder and the GHCR image;
   it keeps a backup of each record (job artifact). "NO PERMISSION" = the entry's owner
   must add the job's account (the bio.tools user of `BIOTOOLS_TOKEN`) as an editor; "not checked" = the SDU firewall in
   front of bio.tools blocks the check-only address of that entry (the DNA one), so the
   apply run saves it directly and bio.tools checks it on save; "BLOCKED" = the firewall
   refused the save too: edit it by hand on the website. Report dead links.
5. Record what broke and how it was fixed in `docs/testing.md` §1.5b, and update the
   user's memory notes (e.g. the temporary Python pin is gone).

## Never

- edit version strings by hand, or "fix" a `check` problem by inventing an image tag;
- push, merge, publish or switch workflows off/on without the matching gate;
- add `[skip ci]` to the release merge (it must publish), or a workflow-level
  `concurrency:` to a test/publish workflow (AGENTS.md);
- downgrade a Galaxy tool version or a deliberate pin without the user's decision.
