# biobb_wf_dna_helparms — tests

Per-flavour end-to-end tests. `python/` is the step-by-step pytest suite (run
in CI); `docker/` and `jupyter/` are local e2e scripts (see `docs/testing.md`).
This workflow has no `cwl/` or `airflow/` flavour, so there is no e2e test for
them.

## Running

```console
cd biobb_workflows/biobb_wf_dna_helparms/tests

./docker/run_test.sh           # build image + run MODE=python + assert outputs
./jupyter/run_test.sh          # execute the tutorial notebook headlessly in the image
./run_all.sh [docker jupyter]
KEEP=1 ./docker/run_test.sh    # keep image/work dir for inspection
```

All scripts exit non-zero on failure and print a `PASS:`/`FAIL:` line per check.
On failure every script keeps its work dir (with the full log / executed
notebook) and records it in `tests/<flavour>/.e2e_workdir` — in CI the
on-failure step tars + uploads it as an artefact; locally, just inspect it.

### Prerequisites

| Flavour | Needs |
| --- | --- |
| docker | docker daemon. Image build pulls the conda env and fetches env.yml/notebook/workflow.py from GitHub `main` at build time; the `.curvesplus` libraries are baked in from `docker/.curvesplus` (build context). |
| jupyter | docker daemon + `python3` on the host (same image as the docker flavour — built once, shared tag). |

Apple Silicon: the scripts auto-add `--platform linux/amd64` and warn — runs
are emulated (slow).

## What each test asserts

- **docker**: container exit code 0 and the final-step outputs exist non-empty
  in the local work dir: `bps_correlation.csv`, `bps_correlation.jpg`
  (step25_interbpcorr).
- **jupyter**: nbconvert exit 0 (aborts on first raising cell), no `error`
  outputs in the executed notebook, and the same final outputs.

## Notes

- **Runtime**: no MD and no MPI — biobb_curves + biobb_canal on the committed
  45 MB trajectory plus light numpy analysis, CI-sized (the python CI runs it
  unreduced on the standard runner). No runtime reduction is applied.
- **workflow.py is custom**: it extracts the canal zip and loops the ~40
  HelpAR parameters itself, so the `input_ser_path: input.ser` placeholders in
  `workflow.yml` are irrelevant (the docker e2e runs `workflow.py`, not a
  generic runner over the yml).
- The **docker** image fetches `main` content at build time → it validates the
  published state, not unpushed `workflow.py`/env edits.
- The **jupyter** test executes the notebook from the `jupyter/` submodule
  (or a shallow clone of `github.com/bioexcel/biobb_wf_dna_helparms` when the
  submodule is absent — the CI case) and ships `docker/TRAJ/` as the notebook
  inputs; there is no network dependency (no MDDB download).

## Porting to another workflow

Copy `tests/{docker,jupyter,run_all.sh,README.md}` to the target workflow and
edit the per-workflow sections:

1. `WF_NAME` in every script (plus `ENV_NAME`/`NOTEBOOK` in the jupyter one).
2. `EXPECTED_OUTPUTS` — take the last step's outputs from `python/workflow.yml`.
3. docker: `docker_build_args()` (REPO/SUBREPO mapping — authoritative list in
   `.github/workflows/publish-ghcr.yaml`) and `extra_data_mounts()` (the raw
   inputs referenced by absolute `/data/...` paths in `docker/workflow.yml`).
4. jupyter: `NOTEBOOK` (path inside the jupyter repo) and the input files the
   notebook reads relative to its own dir.
5. `adjust_runtime()` hooks — reduce runtimes like the python CI does
   (amber_abc: `nstlim=100, maxcyc=50`; amber_md(_lig): `nstlim=500,
   maxcyc=100`; pmx: `nsteps=50`; gromacs wfs: `nsteps=10`; heavy wfs:
   `mpi_np=2`).
6. Skip flavours the workflow does not have (see the matrix in
   `docs/architecture.md`).
