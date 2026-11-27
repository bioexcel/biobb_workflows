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

CI invocation (see ci.md): conda 26.7.1 env (libmamba solver — see ci.md for why not
micromamba) from `python/workflow.env.yml` (+ pytest, imagehash), then
`pytest <wf>.py --config ../../python/workflow.yml --remove` from
`tests/python/`. The automatic pipeline (`python-tests.yaml`) fires only on changes to
`biobb_wf_*/python/**` or `biobb_wf_*/tests/python/**` (the always-on push trigger and
the weekly regression were removed 2026-09-22); it also runs on demand via the manual
Flavour e2e (`python` flavour, which delegates to `python-reusable.yaml`).

### 1.2 Local run recipe

```console
# conda 26.7.1 + libmamba, same as CI (ci.md) — micromamba's solver cannot
# resolve the biobb 5.3.x MD dependency knot
cd biobb_workflows/biobb_wf_cmip
conda create -n wf_cmip -f python/workflow.env.yml pytest imagehash -y
conda run -n wf_cmip bash -lc \
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
A weekly full regression was added (`schedule`, Monday 04:00 UTC; removed 2026-09-22).
Concurrency is per workflow folder since 2026-11-16 (ci.md §1.1b): a newer run of the same
wf cancels the stale one, different wfs never cancel each other.

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
| `biobb_wf_structure_checking` | MPI sander lines stripped (`binary_path: sander.MPI`, `mpi_np`, `mpi_bin`) — the 5.3.x envs resolve the unpinned ambertools dep to the latest nompi build, which ships no `sander.MPI`/`mpirun`; the (short, 500-cycle) minimization runs serially, no step reduction. step16 `fix_pdb` gets `forced_uniprot_references: [P00568]` (human adenylate kinase 1 = 1Z83, committed in the workflow configs): without it the tool BLASTs the chain against NCBI, which is flaky in CI (hangs or times out in containers). step0/step17 `structure_check` on the raw PDB fetches each metal/ligand residue name from the BSC monomers API (`mdb-login.bsc.es`, 10 s timeout, no fallback in biobb_structure_checking ≤3.16.2): one failed lookup aborts the whole check, and the endpoint is flaky from CI runners — hence the bounded retries (suite step0: 3×10 s; cwl/docker/jupyter e2e: 3 full attempts, non-hang failures only; airflow: no auto-retry, re-run the lane manually if it hits this) |
| `biobb_wf_md_setup`, `biobb_wf_md_setup_mutations` | `nsteps: 10` |
| `biobb_wf_protein-complex_md_setup` | free-MD `nsteps: 250000 → 10` only — min/NVT/NPT keep the workflow's own 5000/50000/50000 (a blanket `nsteps: 10` makes the NPT run on an un-equilibrated system: the pressure coupling blows it up and `gmx mdrun` segfaults, exit -11, before writing its `.gro`) |

Notes:

- The `sed`s are global per file: **every** occurrence of the key gets the same value.
- `biobb_wf_cmip` is deliberately **not** in the list: its MIP/sander step needs ~25 GiB,
  no known reduction fits a 7 GiB runner (hence the disabled python test and the
  `tests/docker/SKIP` in the publish chain).
- When porting the e2e scripts (§2), each wf's `adjust_runtime()` hook must **mirror**
  that wf's values from this table, or the e2e runs full-size steps. The cwl flavour's
  config has quoted keys (`"nsteps":`), so its pattern differs — see the commented
  examples in `biobb_wf_cmip/tests/*/run_test.sh`. The nextflow flavour's hook is
  generated from `TEST_SETTINGS` in utils_biobb `nextflow_wf_generator.py` (§2.2):
  change the values there and regenerate. The 7 hand-ported nextflow workflows have them
  in their own `run_test.sh` (md_setup_mutations, pmx_tutorial).
- These values are what decide which wf fits which runner pool (§3.3): with reductions,
  all CI-runnable wfs fit GH-hosted `ubuntu-latest`; a `bigmem` pool is only needed to
  run heavy wfs *without* reductions (e.g. re-enable cmip).

### 1.5b Environment drift fixes (2026-11-16)

`ubuntu-latest` moved to **Ubuntu 26.04** (Oct 2026) and conda-forge/bioconda moved on;
the 2026-11-16 full run failed in 21 jobs, all from these causes:

| Cause | Affected | Fix |
| --- | --- | --- |
| AmberTools 26.0 (conda-forge, 2026-11-06) no longer ships `reduce`; `biobb_chemistry==5.3.0` does not depend on the separate bioconda `reduce` package → `reduce -Trim` exit 127 | md_setup, md_setup_mutations, protein-complex_md_setup, amber_md_setup(_lig), structure_checking (+ cmip, CI-skipped) | `biobb_chemistry` 5.3.0 → **5.3.2** (depends on `reduce >=4.14`) in `python/` (env, requirements, container tags), `cwl/` and `airflow/` adapters. Jupyter repos: left at 5.3.0 at first; moved to 5.3.2 on 2026-11-27 in `biobb_wf_amber`, `biobb_wf_structure_checking` (the Docker images build from them; `biobb_wf_md_setup` already had it, `biobb_wf_protein-complex_md_setup` lists `reduce`) and in `biobb_wf_cmip` (after its Mol* migration). The binder envs that pin `ambertools<26` get bioconda `reduce` next to AmberTools 25's own |
| `biobb_chemistry` 5.3.0 build 1 (2026-10-19) relaxed `openbabel 3.1.1` → `>=3.1.1`; Open Babel 3.2.1 copies COMPND/AUTHOR into the ligand `.pdbqt` → Vina 1.2.7 "PDBQT parsing error" | virtual-screening_fpocket (conda) | `openbabel==3.1.1` in `python/workflow.env.yml` and (2026-11-27) in the jupyter repo's `conda_env`/`binder` env files (the Docker image builds from them) (container mode uses the image's Open Babel; fpocket keeps the `biobb_chemistry:5.3.0--pyhdfd78af_0` image, built with 3.1.1) |
| CI conda pulled packages from Anaconda's `defaults` channel (Miniconda sets it in its install config; `conda create -f` ignores the env files' `nodefaults`). For autoencoder this meant `mkl` 2022/2025 from defaults and an ancient `pytorch` 2.5/2.6 `cpu_generic` build, which on Ubuntu 26.04 failed with `libtorch_cpu.so: cannot enable executable stack` (old builds carry that ELF flag; the new glibc refuses it) and, once the flag was cleared, made the training step run for hours | autoencoder (conda, Linux); potentially any wf | `python-reusable.yaml`: remove `defaults` from every conda config file and pass `--override-channels -c conda-forge -c bioconda` to `conda create`; the *List installed package versions* step warns if a defaults package leaks in. Env now gets `pytorch` 2.14.1 `cpu_mkl` (as in Oct), no executable-stack library, 14 passed in 3 min. **Docker images too** (2026-11-26, first scheduled Docker round): `conda env create` does NOT honour `nodefaults` either (the build log lists `conda-forge, bioconda, nodefaults, defaults`); defaults' `mkl` 2025.0.0 + `nomkl` + `tbb` gave pytorch 2.5.1 `cpu_generic` and the same executable-stack error. Fixed in `common/docker/Dockerfile` (same channel cleanup before `conda env create`). Users who install a tutorial with Miniconda (which configures `defaults`) can hit it as well. Also: pytest now streams live (`--no-capture-output -v`) and dumps thread stacks of a test running > 30 min |
| Ubuntu 26.04 system `python3` is 3.14: no wheels for `torch==2.5.0`, `scipy` 1.13, `biobb_mem` 5.3.0 (`<3.13`) | autoencoder, flexdyn, mem, pmx_tutorial (container mode) | **TEMPORARY** `actions/setup-python` 3.12 in `python-container-tests.yaml`; remove with the next biobb release (Python no longer fixed) |

### 1.6 Container flavours (docker / singularity) — pip-installed biobb, no conda

Some workflows ship extra python configs — `workflow.docker.yml` and
`workflow.singularity.yml`. The python biobb code always runs natively (pip-installed
from `workflow.env.yml`, **no conda**); a step's *executables* run inside a declared
container **only when that step actually launches a binary** — that step carries a
`container_image` + `container_path: docker|singularity` (e.g. `gmx`, `babel`,
`acpype`, Curves+ `Cur+`/`Canal`). Steps that are pure-Python (e.g. `biobb_dna`'s
analysis tools, `biobb_pytorch`'s MDAE torch tools) run natively on the host and carry
**no** container properties: putting a container on one makes biobb remap its inputs
to the container's `/data`, which the native code then can't read. Today
`biobb_wf_md_setup`, `biobb_wf_ligand_parameterization`, `biobb_wf_protein_md_analysis`,
`biobb_wf_dna_helparms`, `biobb_wf_autoencoder`, `biobb_wf_virtual-screening_fpocket`
and `biobb_wf_structure_checking` have these.

`tests/python/` adds, per such flavour:

- `biobb_wf_<name>_<flavour>.py` — a thin module that only re-imports the
  `test_stepN_...` functions from `biobb_wf_<name>.py` (same step order). The step
  helpers are config-agnostic, so the *only* difference from the standard test is the
  `--config` (the `workflow.<flavour>.yml`). These are run by **explicit filename**
  only — a bare `pytest` collects nothing, since none of the files match `test_*.py`.
  (For a workflow whose name contains a hyphen — e.g. `biobb_wf_virtual-screening_fpocket` —
  the standard test file is not a valid Python identifier, so the wrapper loads it from its
  file path with `importlib.util.spec_from_file_location` instead of a plain `import`.)
- `run_container_test.sh <flavour> [wf_name]` — the local + CI entry point. It:
  1. creates a venv and `pip install`s `python/requirements.txt` — the committed pip
      list users install for the container mode (`biobb_*` pins = `workflow.env.yml`,
      plus python-level extras such as `matplotlib`, flexserv `numpy`, pmx
      `scipy==1.13`/`numpy<2`) — + pytest, imagehash;
   2. copies `workflow.<flavour>.yml` to a scratch file and seds `nsteps → 10`
      where present (MD workflows; a no-op otherwise; `FULL_STEPS=1` skips it);
    3. **docker**: checks the daemon, and injects `container_user_id: <uid>:<gid>` into
       the scratch config's `global_properties` so biobb adds `--user` and runs the
       container as the host user; without it the container runs as the image user, owns
       the output files it writes into the sandbox, and biobb's host-side post-processing
       (e.g. acpype's gro/itp/top via fileinput) hits a `PermissionError`. Images are
        pulled lazily per step and cached by docker. **singularity**: installs it if
        missing (exporting a `SINGULARITY_CACHE` for download dedup), then for each
        **unique** image pulls it to a local `.sif` under the scratch dir and rewrites the
        scratch config's `container_image` from the registry URL to that **absolute local
        path**. This is required because biobb's `create_cmd_line` re-issues its own
        `singularity pull` for any `container_image` that is a URL (a URL never
        `Path().exists()`), naming the target with a `:` taken from the tag (e.g.
        `biobb_dna:5.3.sif`) which the registry rejects → `FileNotFoundError`; pointing
        `container_image` at a pre-fetched local `.sif` makes `Path(...).exists()` True, so
        biobb skips that failing re-pull and execs the `.sif` directly. It already runs as
        the host user, so no `container_user_id` is needed there;
   4. puts `$VENV/bin` on `PATH`, then runs `pytest biobb_wf_<name>_<flavour>.py
      --config <scratch> --remove` from `tests/python/` (CWD — `file:` inputs + the work
      dir + `*.sif` land here), then removes the venv / scratch / work dir / `*.sif`
      (`KEEP=1` to keep them).

`matplotlib` is in `requirements.txt` because the biobb plotting tools (e.g. `biobb_dna`'s
`dna_averages`/correlation steps) render their `.jpg` plots from the **native** python:
conda supplies matplotlib, but `pip install biobb_*` omits it, so without it those steps
die with `ModuleNotFoundError: No module named 'matplotlib'`.

Putting `$VENV/bin` on `PATH` (step 4) matters for host-mode steps that shell out to a
**pip-installed console_script**: `biobb_structure_utils.extract_molecule` (step1 of
`biobb_wf_md_setup`, a pure-Python tool with no container) runs `check_structure`, a
console_script shipped by its `biobb_structure_checking` dependency, at
`$VENV/bin/check_structure`. biobb's `cmd_wrapper` launches the command via a shell that
inherits the process env, but invoking `$VENV/bin/python` directly does not put
`$VENV/bin` on `PATH`, so without the export the shell reports `check_structure: command
not found`. (Passing `binary_path:` to the step would also work, but `$VENV` is a
`mktemp` dir, so the shared script sets `PATH` instead — one line that covers any such
host-mode tool.)

CI wiring: `python-container-tests.yaml` uses the shared `detect.yaml` (as the cwl /
airflow / jupyter e2e do) to test **only the workflow(s) changed in the push** — so
editing `biobb_wf_ligand_parameterization` does not also run `biobb_wf_md_setup`. A
`docker` + a `singularity` job each fan out over the detected workflows (matrix,
`ubuntu-latest`, 720 min, bot guard, `fail-fast: false`). It fires on pushes to any wf's
`python/workflow.{docker,singularity}.yml`, `python/workflow.env.yml` or
`tests/python/**` (detect narrows to the wf's that actually ship a container config) and
on manual dispatch. A workflow opts in simply by having `python/workflow.docker.yml` —
nothing else to wire up. The python opt-out `tests/python/SKIP` also applies here
(`detect` input `skip_file`; before 2026-11-16 it was silently ignored because the derived
path was `python/workflow.docker.yml/SKIP`). The singularity jobs rely on the runner allowing unprivileged
user namespaces (GH `ubuntu-latest` does by default), because biobb runs `singularity
exec` as the non-root CI user.

Local run (the script derives the workflow from its own location):

```console
biobb_wf_md_setup/tests/python/run_container_test.sh docker        # needs a running docker daemon
biobb_wf_ligand_parameterization/tests/python/run_container_test.sh singularity   # linux only
```

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
| nextflow | `nextflow run <wf>/nextflow -profile docker -c out/test.config` (a copy of `nextflow.config` with the runtime cuts), default samplesheet; the modules pull `quay.io/biocontainers/*` via the host daemon | exit 0 **and** every output of every step present and non-empty in `out/results/<id>/<step>/` |

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
- **cwltool runs tool containers as the invoking uid — breaks tools that call `getpass`**
  (found 2026-09-28, autoencoder cwl e2e on GH Actions): bare `cwltool` matches the
  container user to the invoking user (`--user 1001` on GH runners); that uid has no
  `/etc/passwd` entry inside the tool image, so anything that resolves a username dies
  before doing its job — torch does this on import (its inductor cache-dir lookup calls
  `getpass.getuser()` → `OSError: No username set in the environment`), which kills the
  `biobb_pytorch` steps while gromacs/amber steps in the same run pass. Symptom: the step's
  outputs are null + `Did not find output file with glob pattern`, workflow aborts within
  seconds; the traceback is only in `cwltool.log` (see next entry). **Fix: pass
  `--no-match-user` to cwltool in the cwl e2e scripts** — tools run as the image's default
  user, which is what the airflow flavour does anyway (its cwltool goes through
  `--user-space-docker-cmd`, which never passes `--user`).
- **On-failure artefacts only materialise if the script records its workdir** (found
  2026-09-28): `flavour-test-reusable.yaml` tars + uploads, on failure, the dir recorded in
  `tests/<flavour>/.e2e_workdir`. A script that never writes the marker loses the full log
  (e.g. cwl's `cwltool.log`), leaving only the last 50 console lines — the first
  autoencoder cwl failure was undiagnosable exactly like that. **Rule: e2e scripts write
  `.e2e_workdir` pointing at their workdir and keep that dir on failure** (autoencoder's
  docker/cwl/airflow/jupyter scripts all do this; before that only jupyter did).
- **biobb 5.3.x: two image traps the amber workflows hit** (found 2026-09,
  abc_setup/md_setup(_lig) 5.3.x port): (1) the `biobb_amber:5.3.1` env resolves to the
  bare-ambertools build (no openmpi) → no `sander.MPI`/`mpirun`; the openmpi ambertools +
  gromacs-2026 combination is UNSAT on conda-forge, so the amber wfs run **serial sander**
  in CI (the `sander.MPI`/`mpi_np`/`mpi_bin` props are stripped per-wf in
  `python-reusable.yaml`, and the jupyter e2e `adjust_runtime` strips them from the
  notebook copy). (2) `biobb_analysis:5.3.0--gmx2026_2` (gromacs build) has **no cpptraj**;
  cpptraj adapters must use `biobb_analysis:5.3.0--pyhdfd78af_1` (depends on
  `ambertools >=23`).

### 2.2 Nextflow flavour (2026-11)

`<wf>/nextflow/` and `<wf>/tests/nextflow/run_test.sh` are both **generated** by
utils_biobb `nextflow/nextflow_wf_generator.py` from `python/workflow.yml` +
`workflow.py` (regenerate them, never edit them: the files carry a generated mark)
for the 12 workflows whose python steps form a plain graph.

The other 7 have Python logic between the steps that the generator can't translate. The
generator stops on them: any block not called as
`<block>(**global_paths[<step>], properties=global_prop[<step>])`, a step called inside a
loop or a condition that is not a global property, or a change of the step paths or
properties. They are **ported by hand**, with the same layout and conventions (from a
generator run on a flattened copy of the python workflow):

| Workflow | Python logic, as ported |
| --- | --- |
| dna_helparms | Loops over the helical parameters: one task each (`meta.helpar`), input from the extracted Canal zip. Loops over the base pairs (steps) found in the extracted timeseries zips (`meta.pair`). Zip of the outputs of every step (`<id>_<step>_outputs.zip`) |
| flexdyn | Zip of the five ensembles concatenated by step25_trjcat. `CONCOORDLIB` (set from `$CONDA_PREFIX` by `workflow.py`) is left to the biobb_flexdyn container, which sets it |
| godmd | step2/step3 run only when their `molecules` property is not empty: `step2_molecules` / `step3_molecules` params (lists, given in a `-params-file`), otherwise step4/step5 take the step0/step1 chains |
| haddock | pdb_tools pipelines of step0 and step2 to step8: one `<step>_<n>_PDB_<BLOCK>` call per block, H and L chains as `meta.chain`, concatenated by cat_pdb. Inputs of the haddock3 steps made by them |
| md_setup_mutations | Loop over the mutations: `mutations` param (list), step3 to step24 once per mutation (`meta.mutation`, `mutation_list` of step3), results in `results/<id>/<mutation>/<step>/` |
| pmx_tutorial | Loops over the states and the frames extracted from their trajectories (`meta.state`, `meta.frame`, results in `results/<id>/<state>/<frame>/<step>/`). stateA without energy minimization. Zip of the dhdl files of each state for step11. `gmx_lib` (GMXLIB): the pmx force field folder, copied from the biobb_pmx image by the MUTFF process |
| protein_md_analysis | B-factor PDB file (Biopython) and clusters JSON file, written in the step4 and step7 folders |

- The python logic runs in small processes: the local `zip` and `unzip` modules
  (`nextflow/modules/local/`, the same in every workflow) or processes of `main.nf`. They
  run in the biobb_common image (Python and Biopython), except MUTFF (biobb_pmx image).
- Running the generator on a hand-ported workflow (its `main.nf` has no generated mark)
  only refreshes the modules of `modules/bioexcel` that `main.nf` includes, so the new
  module versions reach them with the same command. The rest is kept.
- Their `run_test.sh` is written from the generator's template (same steps, options and
  PASS/FAIL), with every output of the loops for the default inputs: 9 base-pair steps and
  12 base pairs (dna_helparms), 3 mutations (md_setup_mutations), 25 frames per state
  (pmx_tutorial). Runtime cuts (§1.5): md_setup_mutations `nsteps: 10`, pmx_tutorial
  `nsteps: 50`.

The script follows the conventions above (`WF_NAME`, `EXPECTED_OUTPUTS`,
`adjust_runtime()`, `--keep`, `.e2e_workdir`, PASS/FAIL) with these differences:

- The committed files are never touched: `adjust_runtime()` seds a copy of
  `nextflow.config` (`out/test.config`, given with `-c`, so it overrides the
  workflow's), with the §1.5 values from `TEST_SETTINGS` in the generator.
- `EXPECTED_OUTPUTS` is **every** published output of every step run by default
  (`<id>/<step>/<id>_<step>_<role>.<ext>`), not just the final ones.
- `MAX_ATTEMPTS` (3 for structure_checking, flaky structure_check lookups): a failed
  attempt is resumed with `-resume`, so only the failed steps run again.
- `process.resourceLimits` caps the task CPUs to the host's (the multithreaded mdrun
  steps ask for 4, more than a 2 vCPU runner has). `PROFILE=apptainer` runs the
  Galaxy depot images instead of docker.

Opted out of CI (`tests/nextflow/SKIP`): cmip (memory, as for every flavour). The 4
workflows with cpptraj steps (amber_abc_setup, amber_md_setup, amber_md_setup_lig,
flexserv) were opted out until 2026-11-05, while the biobb_analysis Nextflow modules
used the image of the biobb_analysis v5.3.0 JSON schema, `5.3.0--gmx2026_2`, which has
no cpptraj (§2.1). The modules of biobb_analysis 5.3.1 use `5.3.1--pyhdfd78af_0`,
which has cpptraj and GROMACS.

pmx_tutorial failed in step3_pmx_gentop until 2026-11-10 with the first biobb_pmx 5.3.1
image, `5.3.1--pyhdfd78af_0` (Python 3.14, pmx `KeyError: 'N3'`). Its bioconda rebuild
`5.3.1--pyhdfd78af_1` (Python 3.13), now in the biobb_pmx JSON schema and modules,
passes (module tests 7/7, pmx_tutorial 931/931).

Pitfalls found while testing the generated workflows (2026-10-28):

- **MPI**: the python configs run sander as `binary_path: sander.MPI` with `mpi_bin` /
  `mpi_np`; the biocontainers have no MPI, so the generator leaves those three
  properties out (as the cwl/airflow flavours do by hand).
- **sander's 256-character file names**: sander truncates longer paths ("Error
  opening unit 9 ... is missing or unreadable"). The work dir hash, biobb's
  `sandbox_<uuid>/` and the `<id>_<step>_<role>` file names make the paths long:
  a launch folder deeper than ~80 characters hits it. Workaround: a shorter launch
  folder, or `sandbox_path: '/tmp'` in the step properties (inside the container).
- **protein-complex_md_setup**: cutting every `nsteps` to 10 makes the NPT mdrun blow
  up (same as the python CI, §1.5): only the free MD (`nsteps: 250000`) is cut.

Pitfalls found while porting the other 7 (2026-11-06):

- **pmx force field (pmx_tutorial)**: pdb2gmx and grompp run in the biobb_gromacs image,
  which has no pmx `mutff` force field, and the modules have no input for a GMXLIB
  folder. MUTFF copies it from the biobb_pmx image into the work directory and its path
  goes to `gmx_lib` (`meta.gmx_lib`), mounted with `containerOptions` in the containers
  of the steps that read it. Nextflow only mounts the common parent folder of a task's
  inputs (`work/` or just `work/<xx>/`), so without that mount pmxmutate failed at
  random ("forcefield path not found"). Needs a work directory on a shared file system
  (not in object storage).

### 2.3 Galaxy flavour (2026-11)

The 11 `.ga` workflows run on the BioBB Galaxy server (https://biobb.usegalaxy.es, INB).
There the biobb tools are local tools (ids like `biobb_io_pdb_ext`), and only the latest
version of each tool is installed. `tests/galaxy/run_test.sh` (CI: `galaxy-tests.yaml`)
has two parts:

1. `common/galaxy/galaxy_wf.py check <wf>` uses anonymous API calls and fails if a tool
   is not installed. It also lists version differences:
   - "server newer": the server has a newer version, and the release updates the `.ga`;
   - "server behind": the server only has an older version, and its admins must update
     it. This is never fixed by downgrading the `.ga`.
2. `galaxy_wf.py run <wf>` only runs when the repository secret `GALAXY_API_KEY` is set
   (an account on that server). It imports the workflow, runs it in a new history, waits,
   and cleans up.
   - Not exercised yet (no key as of 2026-11-23).
   - The workflows have no input steps (they download their own structures), so no upload
     is needed.
   - Their MD steps are full length: expect long runs, and agree the load with the server
     admins before enabling it weekly.

State on 2026-11-23, at the first check (the `.ga` files were last edited for biobb 4.0):

| | |
| --- | --- |
| tools missing on the server | godmd (`biobb_godmd_godmd_prep_ext`, `biobb_godmd_godmd_run_ext`), flexdyn (ToolShed `cmonjeau/ziptool`): both opted out with `tests/galaxy/SKIP` |
| server behind | every `biobb_analysis_*` tool: the server has 3.0.2, the workflows ask for 4.0.x (md_setup, protein-complex_md_setup, amber_md_setup(_lig), flexserv, flexdyn, godmd) |
| server newer | 152 steps in all 11 workflows (4.0.x → 5.3.x): `galaxy_wf.py update` |

Update on 2026-11-25, after INB said the server was updated:

| | |
| --- | --- |
| now installed | godmd tools (5.3.1): godmd's `tests/galaxy/SKIP` removed |
| still missing | ToolShed `cmonjeau/ziptool` (flexdyn, still skipped) |
| still behind | all 20 `biobb_analysis_*` tools at 3.0.2 (23 steps in 7 workflows); asked INB for 5.3.0 |

Second update on 2026-11-25: INB installed the rest. `galaxy_wf.py check` reports 0 missing
tools and 0 steps where the server is behind in all 11 workflows.

| | |
| --- | --- |
| now installed | ToolShed `cmonjeau/ziptool`: flexdyn's `tests/galaxy/SKIP` removed, so no Galaxy workflow is skipped |
| now up to date | `biobb_analysis_*` tools at 5.3.1 |
| left for the release | `galaxy_wf.py update`: the `.ga` files still name 4.0.x tool versions; the server is newer in all 11 |

Run on the server (2026-11-26, secret `GALAXY_API_KEY` set; `galaxy_wf.py run`):

| | |
| --- | --- |
| import | works |
| invoke | Galaxy refuses steps whose newer server tool has a parameter the `.ga` lacks ("Workflow step has upgrade messages", e.g. `properties|assembly` of `biobb_io_pdb_ext` 5.3.2). `run` now reports them as a warning and invokes with `allow_tool_state_corrections` (the tools' defaults, as the Galaxy editor does) |
| md_setup (run 45793366901) | step 1 `biobb_io_pdb_ext` 5.3.2 fails: the JSON the wrapper builds from the `properties` section (`config.sele: option3`) reaches `pdb --config` sanitized (`__oc____dq__properties__dq__...`), so biobb_common looks for a file of that name (`FileNotFoundError: Configuration file ... not found`). A fault of the server's `_ext` wrapper (installed locally by INB, not from the ToolShed; not in bioexcel/biobb_adapters). All 251 tool steps of the 11 workflows use `option3`; reported to INB |
| amber_abc_setup (run 45794058350) | its first job fails before running (no exit code, no stderr): the workflow needs an input dataset, and `run` does not upload any yet (the other 10 download their structure themselves) |

`run` prints each failed job's stderr/stdout before purging the history. Wait limit 330 min
(GitHub-hosted jobs stop at 6 h).

The run part is OFF until INB fixes the wrappers: CI passes the key only when the repository
variable `GALAXY_RUN` is `true` (`gh variable set GALAXY_RUN --body true -R bioexcel/biobb_workflows`
to switch it on, `gh variable delete GALAXY_RUN ...` to switch it off). The tool check runs
every Saturday either way.

### 2.4 Colab check (2026-11-24)

How it works: `docs/ci.md` §1.1f (`common/colab/run_colab_test.sh`, `colab-check.yaml`).

**Why Colab breaks.** The Colab cell builds the env with `mamba create` (no Python pin)
and appends `/usr/local/miniforge/envs/<env>/lib/python3.12/site-packages/` to Colab's
own Python. Colab moved to Python 3.13 (Ubuntu 24.04) in 2026, so compiled modules built
for 3.12 cannot load in Colab's kernel. Programs started as separate processes (gmx,
sander, ...) still work, which is why some notebooks get far before failing.

First runs (canary, 2026-11-24, image `release-colab-external-images_20261109`):

| wf | result | first error |
| --- | --- | --- |
| md_setup | all MD steps ran and the outputs exist; the analysis/view cell fails | `ImportError: MDAnalysis not installed properly` (`MDAnalysis.lib._cutil`, built for 3.12) |
| amber_md_setup | fails from the first biobb import (38 cells) | `No module named 'Bio.PDB.ccealign'` (Biopython built for 3.12) |

The solver also picks a different Python per env today (drift snapshot, mamba linux-64):
3.12 for most, 3.13 for haddock, 3.14 for dna_helparms, ligand_parameterization and
virtual-screening. For those, the `python3.12` path in the cell does not exist at all.

**The fix** (in the jupyter repos, at the release): create the env with Colab's Python
(`mamba create -f ... python=3.13 -y`) and use the matching `lib/python3.13/` paths in the
Colab cell and in the cells that build paths from it (pmx `gmxlib`). The Colab check can
try exactly this on its test copy first: `gh workflow run colab-check.yaml -f
try_python_fix=true`.

**What blocks it today** (dry-run solves of the 15 jupyter envs with `python=3.13`,
linux-64, 2026-11-24):

| result | envs | blocker |
| --- | --- | --- |
| installs | dna_helparms, haddock, ligand_parameterization, virtual-screening | none |
| no solution | amber, autoencoder, godmd, md_setup, protein-complex_md_setup, flexdyn, flexserv | `biobb_analysis` 5.3.x declares `python <3.13`; flexdyn and flexserv are also only built up to 3.12 |
| no solution | mem | `biobb_mem` 5.3.x declares `python <3.13` |
| no solution | structure_checking, cmip | `biobb_amber` 5.3.x is only built up to 3.12 |
| no solution | pmx_tutorial | the env pins `scipy 1.13`, which has no build for 3.13 |

So the release must bring biobb_analysis, biobb_mem, biobb_amber, biobb_flexdyn and
biobb_flexserv builds that allow Python 3.13 (and pmx a newer scipy), or those notebooks
stay broken in Colab.

**First full run** (2026-11-24, notebooks as users get them): 1 of 16 works
(ligand_parameterization). protein-complex_md_setup, like md_setup, runs all MD steps and only
fails at the MDAnalysis view cell.
The first error of every other notebook is the Python mismatch: a compiled module built
for 3.12 (`Bio.PDB.ccealign`: amber ×3, structure_checking, flexdyn, flexserv, godmd, pmx;
MDAnalysis: md_setup, mem; mdtraj: autoencoder), or, where the env got 3.13/3.14, a module
not found at all because the `python3.12` path does not exist (`biobb_dna`, `nglview`:
dna_helparms, haddock, virtual-screening).

**Fix tried** (`try_python_fix`, on the 4 envs that can get 3.13 + md_setup):
ligand_parameterization works; md_setup's env does not install (biobb_analysis, as
expected); dna_helparms, haddock and virtual-screening get past the imports and stop later:

- **manual Colab instructions in the notebooks**: dna_helparms needs
  `'stdlib_path': '.curvesplus/standard'` uncommented ("uncomment when running in google
  colab"), haddock needs `import pytraj` commented ("not compatible": its libcurl needs a
  newer OpenSSL than Colab's Ubuntu has). The same kind of comment exists in amber ×3 and
  structure_checking (`AMBERHOME`, "uncomment ALWAYS"), flexdyn (`simpletraj`, `CONCOORD*`,
  `CONDA_PREFIX`), flexserv (`CONDA_PREFIX`) and godmd (viewer lines). The check runs the
  cells as they are (like a user who does not read those comments), so these fail.
  Proposal for the release: make them automatic with `if 'google.colab' in sys.modules:`
  (as flexdyn's `prefix` lines already do), so no manual edit is needed;
- virtual-screening: the Vina output viewer gets no file (`nglview ... you must provide
  file extension`): the docking step left no `output_vina_pdbqt`. Confirmed on macOS
  (§2.5): Vina stops with "PDBQT parsing error ... COMPND", the Open Babel 3.2.1 case of
  §1.5b; fix at the release (pin `openbabel 3.1.1`).

### 2.5 macOS check (2026-11-24, run 45417825057)

`macos-notebooks.yaml` (docs/ci.md §1.1g), GitHub's Apple Silicon runner, first full round:

| Result | Workflows |
|---|---|
| PASS, native arm64 conda | amber_abc_setup, amber_md_setup, flexserv, godmd, ligand_parameterization, md_setup, mem, pmx_tutorial, protein-complex_md_setup |
| FAIL: `reduce: command not found` (AmberTools 26, §1.5b); env only installs with the Intel conda | structure_checking |
| FAIL: Vina "PDBQT parsing error" (Open Babel 3.2.1, §1.5b) | virtual-screening_fpocket |
| FAIL: CNS "Library not loaded: /opt/homebrew/opt/gcc/lib/gcc/current/libquadmath.0.dylib" | haddock → PASS with `brew install gcc` (`MACOS_BREW`) |
| not run: "job was not acquired" (GitHub macOS arm64 capacity, not a test result); re-run 2026-11-25 (run 45588426439), results below | amber_md_setup_lig, autoencoder, dna_helparms, flexdyn |
| PASS (re-run): autoencoder native arm64; dna_helparms only with the Intel conda (Python 3.14) | autoencoder, dna_helparms |
| FAIL (re-run): `reduce: command not found` (AmberTools 26, §1.5b), then acpype exit 19; Intel conda | amber_md_setup_lig |
| FAIL (re-run): `cpptraj: command not found`: the env has no AmberTools on a Mac (below); Intel conda | flexdyn |

- haddock: `biobb_haddock 5.3.3` needs `haddock_biobb ==2025.11`. Its current recipe
  (build 1) is linux-64 only (`skip: true  # [osx]`: the bundled macOS CNS binaries are
  arm64 only, `x86_64-darwin.bin` included, and link Homebrew's libquadmath). On a Mac,
  conda silently falls back to the old noarch build `haddock_biobb-2025.11-pyhdfd78af_0`,
  which installs and then fails at the first CNS step (the later haddock3 "division by
  zero" only means no models came out).
  Decision 2026-11-25: `brew install gcc` first is enough (run 45580641026: the whole
  notebook passes on arm64 with build 0 and Homebrew gcc 16.2.0). So the tutorial README
  tells Mac users to run it, `tests/jupyter/MACOS_BREW` (`gcc`) makes the weekly check do
  the same (replaces the first day's `MACOS_SKIP`), and the request to bioconda to mark
  build 0 broken (bioconda-recipes#72215) was withdrawn: it would remove the only Mac
  route. Lasting fix, not done: an osx build of `haddock_biobb` that uses conda-forge's
  `libgfortran` (it ships `libquadmath`) via `install_name_tool`, so no Homebrew is needed.
- flexdyn: on osx-64 the solver takes `biobb_analysis-5.3.0-gmx2026_2` (an older arch
  build, gromacs only) instead of `noarch/biobb_analysis-5.3.0-pyhdfd78af_1` (needs
  `ambertools >=23.0`), so there is no cpptraj. It is the only Mac solution, not a
  preference: adding `ambertools` to the env makes osx-64 unsolvable (checked
  2026-11-25). Cause: `imods` (needed by biobb_flexdyn) pins `arpack ==3.7.0` in every
  osx-64 build (prebuilt binaries; recipe `recipes/imods`, sources on mmb.irbbarcelona.org),
  while AmberTools >=23.6 needs arpack 3.8-3.9 and older AmberTools conflict with
  gromacs 2026's icu. On linux-64, imods build 0 has no arpack pin, so AmberTools 26
  installs. Fix: rebuild the imods macOS binaries against arpack 3.9 (no env change can
  do it). Of all our envs only jupyter flexdyn on osx-64 gets the gmx2026_2 build
  (drift snapshots).
  Decision 2026-11-25: `tests/jupyter/MACOS_SKIP` for flexdyn and a note in its tutorial
  README (macOS not supported for now; Binder instead) until imods is rebuilt.
- Quiet failures: the haddock3 and Vina wrappers log "exit code 1" without raising; the
  notebook only fails later on a missing file (often as nglview's misleading "you must
  provide file extension"). `report_executed` lists those earlier cells.
- Logs: a job's log is readable while the run goes on
  (`gh api --allow-escape-sequences repos/bioexcel/biobb_workflows/actions/jobs/<id>/logs`);
  the executed notebook of a failed job is the artifact `<wf>-macos-executed`.

## 3. Phase 2 plan: scale to all workflows + wire into CI

### 3.1 Port the phase-1 scripts to the other 18 workflows

Progress (2026-09): done in all four flavours — `biobb_wf_amber_abc_setup`,
`biobb_wf_amber_md_setup`, `biobb_wf_amber_md_setup_lig` (5.3.x baselines),
`biobb_wf_autoencoder` (5.2.x → 5.3.x), `biobb_wf_md_setup`, `biobb_wf_godmd`
and `biobb_wf_mem` (5.3.x). `biobb_wf_md_setup_mutations` is done in the
three available flavours (5.3.x; no jupyter flavour — no notebook repo),
`biobb_wf_pmx_tutorial`, `biobb_wf_dna_helparms` and `biobb_wf_haddock` in
the two available ones (docker + jupyter, 5.3.x; no cwl/airflow
directories), `biobb_wf_protein_md_analysis` in the one
available one (docker, 5.3.x; no cwl/airflow/jupyter directories),
`biobb_wf_protein-complex_md_setup` and `biobb_wf_structure_checking` in
all four flavours (5.3.x) and `biobb_wf_virtual-screening_fpocket` in all
four flavours (5.2.x → 5.3.x; the jupyter env also bumped biobb_io to
5.3.1 — 5.2.3 pins biobb_common 5.2.2 and would not resolve next to the
5.3.0 packages) and `biobb_wf_flexserv` in all four flavours (5.2.x → 5.3.x;
also fixed the input dir committed as `FIles` in `python/`, `cwl/` and
`airflow/inputs/` → `Files`: every config references
`Files/1a32.MoDEL.pcz`, which would not resolve on case-sensitive
filesystems; the envs pin `biobb_analysis==5.3.0=pyhdfd78af_1` because that
is the only 5.3.0 build that ships cpptraj/ambertools and nothing else in the
env provides it — the adapters use the same build). `biobb_wf_flexdyn`
(the last workflow in the campaign) is done in all four flavours
(5.2.x → 5.3.x; as for flexserv, the envs pin
`biobb_analysis==5.3.0=pyhdfd78af_1` — the only 5.3.0 build with cpptraj,
which flexdyn needs and nothing else in the env provides; the gromacs
binary for `gmx_cluster` comes from `biobb_gromacs==5.3.2`, whose
cwl/airflow adapter uses the matching `biobb_analysis:5.3.0--gmx2026_2`
gromacs build). Note: the
committed cwl/airflow flavours of flexdyn have **no trjcat step** — step27
(gmx_cluster) clusters the DMD fitted trajectory (step14) instead of the
concatenated 5-method trajectory the python flavour builds (step25), and use
`cutoff: 0.07` vs the python `0.12`; a pre-existing divergence the e2e does
not change (each flavour validates its own pipeline).

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
    All 17 jupyter wfs ported (2026-09); the per-wf port = set `NOTEBOOK` +
    `EXPECTED_OUTPUTS`.

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
