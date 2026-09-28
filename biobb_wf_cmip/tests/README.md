# biobb_wf_cmip — tests

Per-flavour end-to-end tests. `python/` is the step-by-step pytest suite;
`docker/`, `cwl/` and `airflow/` are local e2e scripts (see `docs/testing.md`).

## Machine requirement: ~25 GiB of free RAM

The MIP steps (`cmip_run`, AMBER sander) allocate ~25 GiB of RAM. These e2e
scripts therefore **run only on a big machine** (the GH-hosted 7 GiB runner
OOMs), and all three flavours are opted out of CI via the `tests/<flavour>/SKIP`
files — delete a SKIP file to re-enable that flavour once the tests can run on
a bigger runner. Run locally:

```console
./run_all.sh                 # docker, then cwl, then airflow (hours)
```

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
| cwl | docker daemon + `cwltool` on PATH (`micromamba create -n cwl -c conda-forge cwltool`). Pre-pulls the 4 `quay.io/biocontainers/*` tool images (several GB) with retries before the run. |
| airflow | docker daemon. Builds `biobb-airflow-test:3.3.2` (apache/airflow 3.3.2 + cwltool + docker CLI) once. |

On failure every script keeps its work dir (with the full log) and records it
in `tests/<flavour>/.e2e_workdir` — in CI the on-failure step tars + uploads
it as an artefact; locally, just inspect it.

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
- **cmip** is compute-heavy: a full run takes hours (MIP grids + sander) and needs the
  ~25 GiB of RAM above. There is no `adjust_runtime()` reduction for it (the allocation is
  intrinsic to the MIP grid), which is also why the python CI test is disabled for cmip.
