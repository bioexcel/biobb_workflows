# Testing — Current State & Plan

## 1. Current state: python step-by-step tests

Only the **python** flavour is tested (in CI and locally).

### 1.1 Design

Per workflow, `tests/python/` contains:

- `biobb_wf_<name>.py` — one helper `stepN_<tool>(config, system=None)` per workflow step
  (mirrors `python/workflow.py`, adds `assert fx.not_empty(...)` per output, and
  `fx.compare_size(...)` against `reference/` for the final step(s)), plus one
  `@pytest.mark.parametrize("system", [None]) def test_stepN_...` per helper.
  Steps share a single working dir via the module global `global_work_dir` (set in
  step0, reused after); test order = file order.
- `conftest.py` — adds `--config` (path to workflow.yml) and `--remove` (clean work dir
  after last step) pytest options; session-scoped `__pycache__` cleanup.
- `reference/` — golden outputs for `compare_size` (tolerance = N bytes difference).
- Raw inputs (pdb/top/nc/xtc/zip), copied per flavour.

CI invocation (see ci.md): micromamba env from `python/workflow.env.yml` (+ pytest,
imagehash), then `pytest <wf>.py --config ../../python/workflow.yml --remove` from
`tests/python/`. The automatic pipeline (`python-tests.yaml`) fires only on changes to
`biobb_wf_*/python/**` or `biobb_wf_*/tests/python/**` (the always-on push trigger and
the weekly regression were removed 2026-09-22); it also runs on demand via the manual
Flavour e2e (`python` flavour, which delegates to `python-reusable.yaml`).

### 1.2 Local run recipe

```console
cd biobb_workflows/biobb_wf_cmip
micromamba create -n wf_cmip -f python/workflow.env.yml -c conda-forge -c bioconda -c nodefaults
micromamba run -n wf_cmip bash -lc \
  "cd tests/python && pytest biobb_wf_cmip.py --config ../../python/workflow.yml --remove -v"
```

### 1.3 Static audit (performed 2026-09-16)

| Check | Result |
| --- | --- |
| `tests/python/<wf>.py` + `conftest.py` exist for all 19 wfs | ✓ |
| Test file name matches workflow name (CI runs `pytest <wf>.py`) | ✓ |
| Reference files referenced by `compare_size` all exist | ✓ |
| Reference data present | 18/19 wfs (7 wfs use `not_empty` only, no golden compare) |
| Commented-out tests | 3: `biobb_wf_cmip` step24, `biobb_wf_md_setup` step21 (gmx_rgyr), `biobb_wf_md_setup_mutations` step21 (gmx_rgyr) |
| Disabled in CI | `biobb_wf_cmip` (Fortran ~25 GiB alloc vs 7 GiB runner) |

### 1.4 CI wiring (fixed 2026-09-16, deployed)

The problems below are fixed by `detect.yaml` + a matrix of call jobs (details in
`ci.md §1.1`):

1. ~~Path filter covered only the 3 `python/workflow*` files~~ → any change inside
   `biobb_wf_<name>/` (tests, docker, cwl, ...) selects that workflow.
2. ~~`workflow_dispatch` selected nothing~~ → dispatch accepts `wf_names`
   (comma separated; empty = all) and is validated against real folders.
3. ~~No bot-commit guard~~ → `github.actor == github-actions[bot]` pushes are skipped.
4. ~~19 hand-maintained filter/job blocks~~ → one reusable `detect` job + one matrix job;
   adding a new workflow needs zero CI edits.
A weekly full regression was added (`schedule`, Monday 04:00 UTC), and rapid re-pushes
cancel the older run (`concurrency`).

### 1.5 CI runtime reductions (per-wf, in `python-reusable.yaml`)

Before the env setup, `python-reusable.yaml` seds `python/workflow.yml` for the
workflows below so the full step-by-step test fits a 2 vCPU / 7 GiB `ubuntu-latest`
runner (`mpi_np: 2` = the runner's 2 vCPU). The other workflows run unreduced. These
are the **only** parameter changes CI applies — they are never committed to
`workflow.yml`.

| Workflow | Reduction |
| --- | --- |
| `biobb_wf_amber_abc_setup` | `mpi_np: 2`, `nstlim: 100`, `maxcyc: 50` |
| `biobb_wf_amber_md_setup`, `biobb_wf_amber_md_setup_lig` | `mpi_np: 2`, `nstlim: 500`, `maxcyc: 100` |
| `biobb_wf_pmx_tutorial` | `nsteps: 50` |
| `biobb_wf_structure_checking` | `mpi_np: 2` |
| `biobb_wf_md_setup`, `biobb_wf_md_setup_mutations`, `biobb_wf_protein-complex_md_setup` | `nsteps: 10` |

Notes:

- The `sed`s are global per file: **every** occurrence of the key gets the same value.
- `biobb_wf_cmip` is deliberately **not** in the list: its MIP/sander step needs ~25 GiB,
  no known reduction fits a 7 GiB runner (hence the disabled python test and the
  `tests/docker/SKIP` in the publish chain).
- When porting the e2e scripts (§2), each wf's `adjust_runtime()` hook must **mirror**
  that wf's values from this table, or the e2e runs full-size steps. The cwl flavour's
  config has quoted keys (`"nsteps":`), so its pattern differs — see the commented
  examples in `biobb_wf_cmip/tests/*/run_test.sh`.
- These values are what decide which wf fits which runner pool (§3.3): with reductions,
  all CI-runnable wfs fit GH-hosted `ubuntu-latest`; a `bigmem` pool is only needed to
  run heavy wfs *without* reductions (e.g. re-enable cmip).

## 2. Phase 1: e2e tests for the other flavours — first two workflows done

Local test scripts, wired to CI **per changed path** (a push to a wf's `cwl/`,
`airflow/`, `tests/jupyter/` or jupyter submodule pointer runs that wf's e2e via
`cwl-tests.yaml` / `airflow-tests.yaml` / `jupyter-tests.yaml`; docker goes through the
test-gated publish chain) and **manually** (the `Flavour e2e Tests (manual)` workflow:
Actions tab → choose flavour + `wf_names`) for ad-hoc subsets. A wf opts out of a
flavour's auto tests with `tests/<flavour>/SKIP`. Done so far:
`biobb_wf_ligand_parameterization` (the pilot — small and fast) and `biobb_wf_cmip`
(heavier, kept for later iterations). Layout, designed to be copyable to the other
workflows:

```
biobb_wf_cmip/tests/
├── README.md            # how to run, what is asserted, per-flavour prerequisites
├── run_all.sh           # convenience: run selected flavours in sequence
├── python/              # (existing) pytest
├── docker/run_test.sh   # build image + MODE=python e2e + output assertions
├── cwl/run_test.sh      # cwltool e2e over workflow.cwl + output assertions
├── airflow/
│   ├── run_test.sh      # Airflow-in-docker e2e: trigger DAG, poll, assert all tasks success
│   └── Dockerfile       # apache/airflow + cwltool (built only when needed)
└── jupyter/run_test.sh  # (pilot wf only, for now) nbconvert --execute the tutorial
                         # notebook INSIDE the wf docker image; notebook from the
                         # jupyter/ submodule, or a shallow clone of
                         # github.com/bioexcel/<WF> when the submodule is absent
```

Triggering from CI (no push trigger yet — phase 2):

```
GitHub → biobb_workflows → Actions → "Flavour e2e Tests (manual)" → Run workflow
  flavour:  docker | cwl | airflow | jupyter | python
  wf_names: biobb_wf_ligand_parameterization      (empty = every wf that has that test)
```

The `python` option has no `run_test.sh`: it delegates to `python-reusable.yaml` (the
same pipeline as the automatic python tests, incl. the per-wf runtime reductions), so a
manual run is byte-for-byte what CI would do.

Conventions (apply to every flavour script, every workflow):

- `#!/usr/bin/env bash`, `set -euo pipefail`, clear PASS/FAIL summary, non-zero exit on failure.
- Common options: `--keep` (keep scratch/images), plus per-flavour options (see README).
- Scratch is local to the test (`tests/<flavour>/work|out`) — never pollutes the git-tracked
  flavour input folders — and is removed on exit unless `--keep`.
- Each script starts with `WF_NAME=...` and an `EXPECTED_OUTPUTS=( ... )` array: the **only
  workflow-specific lines** when porting to another workflow (plus docker build args).
- Docker daemon required for docker/cwl/airflow flavours; on Apple Silicon the scripts
  auto-add `--platform linux/amd64` and warn (slow, QEMU KMP quirks — prefer the server).

What each flavour test asserts:

| Flavour | Substrate | Success criteria |
| --- | --- | --- |
| docker | `docker build` (per-wf Dockerfile) → `docker run` MODE=python with inputs bind-mounted, work dir local | exit 0 **and** final outputs present (`hACE2.energies.box.output.json`, `complex_2.energies.box.output.json`, `hACE2.energies.byat.out`, `hACE2.energies.log`) |
| cwl | `cwltool --outdir out workflow.cwl workflow_input_descriptions.yml` (adapters pull `quay.io/biocontainers/*` via the host daemon) | exit 0 **and** same final outputs in `out/` |
| airflow | host scratch dir with `dags/<wf>` + `plugins/` mounted into an `apache/airflow`+cwltool container at the *same absolute path*; `airflow dags trigger <wf>`; poll `airflow dags state` | DAG run state `success` (all 27 tasks) + per-step `outputs/step*/manifest.json` present |
| jupyter | tutorial notebook executed headlessly **inside the wf docker image** (`conda run -n <env> jupyter nbconvert --to notebook --execute`); notebook from the `jupyter/` submodule if checked out, else a shallow clone of `https://github.com/bioexcel/<WF>` (CI checkouts have no submodules, so the clone path is the CI one) | nbconvert exit 0 (aborts on first raising cell) + no `error` outputs in the executed notebook + final files present (`IBPparams.gro/.itp/.top` for the pilot) |

Caveats baked into the design:

- **Docker image fetches `main` at build time** (env.yml, notebook, workflow.py) — the docker
  test validates the *published* artefact + the local Dockerfile; it is not a test of
  unpushed `workflow.py` edits (documented in tests/README.md).
- **Full cmip runs are long** (MIP grids + sander). The scripts support `EXTRA_*` env passthrough
  and a per-wf `adjust_runtime()` hook (no-op for cmip) so heavy workflows can sed-reduce
  steps like the python CI does. The cmip docker e2e does not fit the 7 GiB GH-hosted
  runner (same ~25 GiB allocation), so it is opted out of the publish chain's gate via
  `biobb_wf_cmip/tests/docker/SKIP` (see ci.md §1.2).
- **Airflow paths**: `CWL_WORKFLOWS_BASE_DIR` / `CWL_TMP_DIR` / `CWL_PLUGINS_DIR` env vars
  point at the host scratch path (shared verbatim with the host docker daemon) → the
  `docker_wrapper.sh` rewrites never fire on Linux.

### 2.1 Recorded pitfalls (bug fixes)

- **Airflow 3 CLI `table` output wraps cells when not on a TTY** (found 2026-09-17, pilot
  airflow e2e): in `docker exec` the default table is a rich table squeezed to 200 cols and
  long cells (run ids, dag ids, filepaths) WRAP across lines, so line-based grep/awk silently
  captures truncated values. Symptom: `RUN_ID` captured as `manual__2026-09-17T13` (cut at the
  wrap point), the state poll never matched, and the script waited the 720-min timeout although
  the DAG had already succeeded. **Rule: in scripts, parse only `-o json` (single line) or
  `-o plain` (tabulate, never wraps) CLI output.** Also: `airflow dags list-runs` takes
  `dag_id` POSITIONALLY (no `-d` flag); `airflow dags trigger -o json` returns the id as
  `dag_run_id`. Fixed in both phase-1 scripts (trigger / list-runs / list-import-errors /
  states-for-dag-run now use `-o json`/`-o plain`).
- **Readiness/state probing**: the scripts read `$AIRFLOW_HOME/airflow.db` READ-ONLY via
  sqlite instead of launching the CLI in a loop (each CLI call re-parses all DAGs and grabs a
  write-lock on the metadata DB — on slow/emulated hosts those starve the scheduler's own
  parser, observed as a livelock).
- **Killing an airflow e2e mid-run**: the trap removes the airflow container and scratch dir,
  but nested tool containers (random docker names, image `quay.io/biocontainers/*`) can be
  orphaned on the host daemon — check `docker ps` after a kill.
- **Airflow cannot reach the host docker socket as the image user** (found 2026-09-21,
  airflow e2e on GH Actions): the container runs as the image's `airflow` user (uid 50000),
  but the CI runner's `/var/run/docker.sock` is `root:docker` mode `0660` → the nested
  cwltool `docker run` dies with "permission denied while trying to connect to the docker
  API". Locally it never reproduces (permissive Docker Desktop socket). **Fix: start the
  container with `--group-add <GID>` where GID = the socket's owning group
  (`stat -c %g`), applied only when the socket is not world-writable (mode & 002 == 0).**
  Do NOT use the group *name* (`--group-add docker`): runners whose socket group is
  unnamed (e.g. `root:root`) fail with "no matching entries in group file" — numeric GIDs
  always resolve. And do NOT run the container with `-u root`: the airflow CLI is installed
  in the `airflow` user's uv user-site, which root's python cannot see
  (`ModuleNotFoundError: No module named 'airflow'`).
- **Airflow dag-processor finds 0 DAG files** (found 2026-09-21): the host scratch dir is
  `mktemp -d` (mode 0700, owned by the host uid) — the container user (uid 50000) cannot
  even traverse it, so the recursive scan under `dag_discovery_safe_mode` registers nothing
  (symptom: "Found 0 files for bundle dags-folder"). Fix: `chmod -R a+rwX` the scratch
  before starting the container (it is throwaway, removed in cleanup).
- **Cleanup of root-owned test output** (found 2026-09-21): nested tool containers run as
  root on the host daemon and leave root-owned files in the host scratch/outputs → plain
  `rm` fails with "Permission denied" at test end. Fix: best-effort `rm`, then a
  `docker run -u root ... /usr/bin/chown -R <host uid>:<gid>` helper before removing.
- **Transient conda CDN failures during `docker build`** (found 2026-09-21):
  `conda env create` occasionally dies mid-repodata-download. Fix: the docker/jupyter build
  steps retry the whole build up to 3 times before failing.
- **Bash arithmetic: `(( a & b == 0 ))` is not what you think** (found 2026-09-21 while
  writing the socket-mode check): in bash `==` binds TIGHTER than `&` (C precedence), so
  the expression was `a & (b == 0)`. Parenthesize: `(( (a & b) == 0 ))`.

## 3. Phase 2 plan: scale to all workflows + wire into CI

### 3.1 Port the phase-1 scripts to the other 18 workflows

Per-workflow checklist (10–30 min each):
1. Copy `tests/{docker,cwl,airflow}` + adjust `WF_NAME`, `EXPECTED_OUTPUTS` (from the last
   step's outputs in `python/workflow.yml`), docker `--build-arg` mapping
   (REPO/SUBREPO — see `publish-ghcr.yaml` for the authoritative map).
2. Fill the `adjust_runtime()` hook for heavy wfs (same values as the python CI seds:
   amber_abc `nstlim=100/maxcyc=50`, amber_md(_lig) `nstlim=500/maxcyc=100`, pmx `nsteps=50`,
   gromacs `nsteps=10`, `mpi_np=2`).
3. For cwl: verify `workflow_input_descriptions.yml` has the same runtime knobs in its JSON
   config strings and extend the hook accordingly (e.g. `"nsteps": 10000`).
4. Galaxy wfs (11): additionally add a cheap **static validation** (JSON parse of the `.ga`,
   every step `content_id` non-empty, `input_connections` reference existing steps/outputs).
   Full Galaxy e2e (dockersGalaxy) only as a *scheduled* job — too heavy for push.
5. Jupyter wfs (17): run the notebook inside the docker image with
   `jupyter nbconvert --to notebook --execute`. **Pilot done (2026-09-17)**:
   `biobb_wf_ligand_parameterization/tests/jupyter/run_test.sh` (notebook from the
   `jupyter/` submodule or, when absent — the GH Actions case — a shallow clone of
   `https://github.com/bioexcel/<WF>`; wired to the manual Flavour e2e workflow).
   Port to the remaining 16 wfs = set `NOTEBOOK` + `EXPECTED_OUTPUTS`.

### 3.2 CI wiring (deploy when phase-1 scripts are green on the server)

- `.github/workflows/detect.yaml` (reusable, `workflow_call`): checkout (`fetch-depth: 0`),
  compute changed workflow dirs from `git diff` (push: `before..sha`; new branch: vs default
  branch; `schedule`: all; `workflow_dispatch`: `wf_names` input or all), merge with
  `wf-meta.yml`, emit JSON matrix. Guard: skip on `github.actor == github-actions[bot]`.
  `all_on_paths` input lets each flavour add "run everything" globs
  (e.g. docker tests: `^common/docker/Dockerfile$`).
- One workflow per flavour: `docker-tests.yaml`, `cwl-tests.yaml`, `airflow-tests.yaml`
  (+ later `jupyter-tests.yaml`, `galaxy-validate.yaml`), each = detect + matrix of call
  jobs to a per-flavour reusable (`docker-reusable.yaml`, ...).
- Fix the python pipeline with the same detect job (replaces dorny; keeps the
  `python-reusable.yaml` reductions).

### 3.3 Runner plan (remote swarm, `gh_runner`)

| Pool | Size | Runs |
| --- | --- | --- |
| `mmbswarm` (existing, 4C/4G × 3) | keep | light wfs' docker/cwl/airflow tests, galaxy static validation, README syncs |
| `bigmem` (proposed, e.g. 2× 8C/16G) | add to `GH_RUNNER_BIOBB_LABELS` via a second swarm service | MD-heavy wfs (amber_*, cmip, md_setup*, mem, protein-complex, structure_checking) in every flavour; re-enable cmip python test |

Rationale: ephemeral runners share the 4 GiB replica limit with the job (myoung34 runs jobs
in-container); the host-docker-socket mount gives a persistent image cache, so cwltool/airflow
tool-image pulls pay once per node. `wf-meta.yml` maps each wf to a pool label
(`runs_on: "[self-hosted, mmbswarm]"` vs `"[self-hosted, bigmem]"`).
Keep `publish-ghcr.yaml` on GH-hosted (or make it `needs:` the sync job) to fix the race
(see ci.md issue 3).

### 3.4 Scheduling

- Push: only changed workflows (all flavours of that wf).
- `workflow_dispatch` `wf_names=biobb_wf_cmip` → targeted manual run (the "I modified cmip" case).
- Weekly `schedule` → all workflows, all flavours (the "biobb got updated" regression sweep).
