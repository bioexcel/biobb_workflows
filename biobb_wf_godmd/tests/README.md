# biobb_wf_godmd — tests

Per-flavour end-to-end tests. `python/` is the step-by-step pytest suite (run
in CI); `docker/`, `cwl/`, `airflow/` and `jupyter/` are local e2e scripts
(see `docs/testing.md`).

## Running

```console
cd biobb_workflows/biobb_wf_godmd/tests

./docker/run_test.sh           # build image + run MODE=python + assert outputs
./cwl/run_test.sh              # cwltool over the CWL adapters (needs cwltool)
./airflow/run_test.sh          # Airflow standalone DAG run (needs docker socket)
./jupyter/run_test.sh          # execute the tutorial notebook headlessly in the image
./run_all.sh [docker cwl airflow jupyter]
KEEP=1 ./docker/run_test.sh    # keep image/work dir for inspection
```

All scripts exit non-zero on failure and print a `PASS:`/`FAIL:` line per check.
On failure every script keeps its work dir (with the full log / executed
notebook / task logs) and records it in `tests/<flavour>/.e2e_workdir` — in CI
the on-failure step tars + uploads it as an artefact; locally, just inspect it.

### Prerequisites

| Flavour | Needs |
| --- | --- |
| docker | docker daemon. Image build pulls the conda env and fetches env.yml/notebook/workflow.py from GitHub `main` at build time. |
| cwl | docker daemon + `cwltool` (e.g. `micromamba create -n cwl -c conda-forge cwltool`). Tool images (quay.io/biocontainers/*, 5.2.1) are pre-pulled with retries. |
| airflow | docker daemon reachable from the container (`/var/run/docker.sock`) for the nested tool containers. Builds a throwaway `biobb-airflow-test:3.3.2` image. |
| jupyter | docker daemon (same image as the docker flavour — built once, shared tag). **Network access** — the notebook fetches the 1ake/4ake PDBs from RCSB at runtime. |

Apple Silicon: the scripts auto-add `--platform linux/amd64` and warn — runs
are emulated (slow).

## What each test asserts

- **docker**: container exit code 0 and the final output exists non-empty in
  the local work dir: `origin-target.godmd.dcd` (step6_cpptraj_convert).
- **cwl**: cwltool exit code 0 (no ERROR lines) and the same output in
  `--outdir`.
- **airflow**: DAG run reaches `success` and every `outputs/step*/` dir has
  its `manifest.json`.
- **jupyter**: nbconvert exit 0 (aborts on first raising cell), no `error`
  outputs in the executed notebook, and the final output
  `1ake-4ake.godmd.xtc` (the notebook converts to XTC, not DCD).

## Notes

- **Runtime**: the GOD-MD run (godmd_run) is the compute step, but it is
  small — a ~200-residue protein on CPU (the conda build of GOD-MD has no
  CUDA) — and the python CI flavour runs it unreduced on the standard
  runner, so no runtime reduction is applied. No MPI anywhere.
- **workflow.py is custom**: it calls the tools directly and skips
  step2 (ligand removal from the origin) when no molecule is given.
- The **docker** image fetches `main` content at build time → it validates
  the published state, not unpushed `workflow.py`/env edits.
- The **jupyter** test executes the notebook from the `jupyter/` submodule
  (or a shallow clone of `github.com/bioexcel/biobb_wf_godmd` when the
  submodule is absent — the CI case).

## Porting to another workflow

Copy `tests/{docker,cwl,airflow,jupyter,run_all.sh,README.md}` to the target
workflow and edit the per-workflow sections:

1. `WF_NAME` in every script (plus `ENV_NAME`/`NOTEBOOK` in the jupyter one).
2. `EXPECTED_OUTPUTS` — take the last step's outputs from `python/workflow.yml`.
3. docker: `docker_build_args()` (REPO/SUBREPO mapping — authoritative list in
   `.github/workflows/publish-ghcr.yaml`) and `extra_data_mounts()` (the raw
   inputs referenced by absolute `/data/...` paths in `docker/workflow.yml`).
4. jupyter: `NOTEBOOK` (path inside the jupyter repo) and the input files the
   notebook reads relative to its own dir (or its runtime downloads).
5. `adjust_runtime()` hooks — reduce runtimes like the python CI does
   (amber_abc: `nstlim=100, maxcyc=50`; amber_md(_lig): `nstlim=500,
   maxcyc=100`; pmx: `nsteps=50`; gromacs wfs: `nsteps=10`; heavy wfs:
   `mpi_np=2`).
6. Skip flavours the workflow does not have (see the matrix in
   `docs/architecture.md`).
