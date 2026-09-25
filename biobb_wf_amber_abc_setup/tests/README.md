# biobb_wf_amber_abc_setup — tests

End-to-end tests per flavour. `python/` is the step-by-step pytest suite
(already run in CI, with reduced runtime). `docker/`, `cwl/`, `airflow/` and
`jupyter/` are local e2e scripts (can also be triggered manually from GitHub
Actions, see `docs/testing.md`).

This workflow is the AMBER ABC setup for a DNA dodecamer (Drew-Dickerson
CGCGAATTCGCG): leap solvation + ionization, then a 10-step equilibration
ladder (minimization/NVT/NPT) and a production MD, ending in cpptraj
analysis (docker/cwl/airflow run the full 30-step `workflow.yml`; the jupyter
notebook stops after the production MD). The unreduced workflow would run
~100 ps of production MD, so every e2e flavour shortens the sander steps to
the same values the CI python flavour uses
(`.github/workflows/python-reusable.yaml`: `mpi_np -> 2`, `nstlim -> 100`,
`maxcyc -> 50`) on a local copy — the committed inputs are never modified.

Notes specific to this workflow:

- It is a **subrepo workflow**: the jupyter repo `biobb_wf_amber` is shared by
  the amber subrepos, and the docker image is built with
  `--build-arg REPO=biobb_wf_amber --build-arg SUBREPO=abc_setup` (the conda
  env inside the image is named `biobb_wf_amber`).
- The `docker/` flavour runs **serial sander**: `docker/workflow.yml` drops
  the `sander.MPI`/`mpi_np` lines that `python/workflow.yml` has.
- The jupyter notebook is self-contained: the PDB and the
  `ABCix_config_files/` mdin set are committed next to it (no network access
  needed at run time).

Runtime on a native amd64 machine, with reduced sander steps and
pre-pulled images: docker ~15–30 min, jupyter similar, cwl/airflow similar
(first run also pulls the per-tool biocontainers images).

## Running (one by one)

```console
cd biobb_workflows/biobb_wf_amber_abc_setup/tests

./docker/run_test.sh        # 1. docker flavour
./cwl/run_test.sh           # 2. cwl flavour
./airflow/run_test.sh       # 3. airflow flavour
./jupyter/run_test.sh       # 4. jupyter flavour
```

or all four in sequence:

```console
./run_all.sh
```

Useful options (same for all four):

- `--keep` — keep the image / scratch folders after the run, to inspect what happened
- docker & jupyter: `--pull` runs the **published** image from GitHub Container
  Registry instead of building it; `--no-build` skips the build (image must exist
  already)
- airflow only: `TIMEOUT_MIN=120 ./run_test.sh` sets the max waiting time
- jupyter only: `NB_REPO_URL=<url> ./run_test.sh` overrides the notebook repo
  (e.g. to test a fork/branch)
- cwl only: `EXTRA_CWL_ARGS="--no-match-user" ./run_test.sh` passes extra
  cwltool args (useful on Mac ARM)

Each script prints `PASS:`/`FAIL:` lines and a final `PASS`/`FAIL` summary, and exits
with a non-zero code on failure (so scripts/CI can detect it).
