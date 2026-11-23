# AGENTS.md

## Test entry points
- Python: `pytest <wf>.py --config ../../python/workflow.yml --remove` from `tests/python/` (micromamba env; see `.github/workflows/python-reusable.yaml`).
- Flavour e2e: `biobb_wf_<name>/tests/<flavour>/run_test.sh` (flavours: docker, cwl, airflow, jupyter). cwl/airflow run nested `quay.io/biocontainers/*` tool containers on the HOST docker daemon via `/var/run/docker.sock`; cwl must run cwltool with `--no-match-user` (see `docs/testing.md` §2.1).

## Notes for agents
- Recorded e2e pitfalls + bug fixes: `docs/testing.md` §2.1 — read it before touching `tests/` scripts or calling the Airflow CLI (key rule: never parse `table` CLI output in non-TTY; use `-o json`/`-o plain`).
- When bumping a wf's biobb versions, also create/update `<wf>/docker/VERSION` (one line, e.g. `2026.1`) — `common/docker/sync_dockerfiles.sh` uses it as the image's version label.
- The same bump must also update `<wf>/python/requirements.txt` (container mode pip list) and the `container_image` tags in `<wf>/python/workflow.{docker,singularity}.yml`; `python3 common/python/check_versions.py` must pass (CI: `python-lint.yaml`).
- A BioBB release (new biobb versions everywhere) goes through the `/biobb-release` skill (`.claude/skills/biobb-release/`, scripts in `common/release/`). Never edit version strings by hand.
- Every test workflow also runs weekly on a schedule, one flavour per day (`docs/ci.md` §1.1c). A red scheduled run usually means outside drift (conda packages, runner image), not a bad push: check `docs/testing.md` §1.5b first.
- CI concurrency is per workflow folder at JOB level (`docs/ci.md` §1.1b) — never re-add a workflow-level `concurrency: <workflow>-<ref>` block to a test/publish workflow: it makes runs for different wfs cancel each other.
- Backgrounding long-running commands from the shell tool: the process group is SIGTERMed when the tool call times out (default 120 s). To survive, fully detach, e.g. `python3 -c 'import os; os.setsid(); ...' &` with stdout/stderr redirected to a file and stdin from /dev/null.
