# biobb_wf_cmip — tests

Per-flavour end-to-end tests. `python/` is the step-by-step pytest suite (run
in CI); `docker/`, `cwl/` and `airflow/` are local e2e scripts (phase 1, not
wired to CI yet — see `docs/testing.md`).

## Running

```console
cd biobb_workflows/biobb_wf_cmip/tests

./docker/run_test.sh            # build image + run MODE=python + assert outputs
./cwl/run_test.sh               # cwltool over cwl/workflow.cwl + assert outputs
./airflow/run_test.sh           # Airflow standalone in docker, trigger DAG, assert all tasks
./run_all.sh [docker cwl airflow]
KEEP=1 ./docker/run_test.sh     # keep image/work dir for inspection
```

All scripts exit non-zero on failure and print a `PASS:`/`FAIL:` line per check.

### Prerequisites

| Flavour | Needs |
| --- | --- |
| docker | docker daemon. Image build pulls the conda env (~GB) and fetches env.yml/notebook/workflow.py from GitHub `main` at build time. |
| cwl | docker daemon + `cwltool` on PATH (`micromamba create -n cwl -c conda-forge cwltool`). First run pulls `quay.io/biocontainers/*` tool images. |
| airflow | docker daemon. Builds `biobb-airflow-test:3.3.2` (apache/airflow 3.3.2 + cwltool + docker CLI) once. |

Apple Silicon: the docker/cwl scripts auto-add `--platform linux/amd64` and warn —
runs are emulated (slow) and some Intel OpenMP binaries need the `KMP_*` workarounds
already present in the images. Run these tests on the Linux server for representative
results.

## What each test asserts

- **docker**: container exit code 0 and the final-step outputs exist non-empty in the
  local work dir: `hACE2.energies.box.output.json`, `complex_2.energies.box.output.json`,
  `hACE2.energies.byat.out`, `hACE2.energies.log`.
- **cwl**: `cwltool` exit code 0 and the same outputs in `tests/cwl/out/`.
- **airflow**: DAG run reaches state `success` (all 27 tasks) and every
  `outputs/step*/manifest.json` was produced.

## Porting to another workflow

Copy `tests/{docker,cwl,airflow,run_all.sh,README.md}` to the target workflow and edit
the per-workflow sections:

1. `WF_NAME` in every script.
2. `EXPECTED_OUTPUTS` — take the last step's outputs from `python/workflow.yml`.
3. docker: `docker_build_args()` (REPO/SUBREPO mapping — authoritative list in
   `.github/workflows/publish-ghcr.yaml`) and `extra_data_mounts()` (the raw inputs that
   live in `docker/`).
4. `adjust_runtime()` hooks — reduce runtimes like the python CI does
   (amber_abc: `nstlim=100, maxcyc=50`; amber_md(_lig): `nstlim=500, maxcyc=100`;
   pmx: `nsteps=50`; gromacs wfs: `nsteps=10`; heavy wfs: `mpi_np=2`).
5. Skip flavours the workflow does not have (see the matrix in `docs/architecture.md`).

## Known limitations

- The **docker** image fetches `main` content at build time → it validates the published
  state, not unpushed `workflow.py`/env edits.
- **cmip** is compute-heavy: a full run takes a long time (MIP grids + sander). There is no
  `adjust_runtime()` reduction for it yet (the python CI disables cmip for the same reason).
- The **airflow** test needs ~10 GiB+ of headroom on the host for parallel tool containers.
