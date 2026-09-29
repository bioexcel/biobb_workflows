# biobb_wf_mem — tests

Per-flavour end-to-end tests. `python/` is the step-by-step pytest suite (run
in CI); `docker/`, `cwl/`, `airflow/` and `jupyter/` are local e2e scripts
(see `docs/testing.md`).

## Running

```console
cd biobb_workflows/biobb_wf_mem/tests

./docker/run_test.sh           # build image + run MODE=python + assert outputs
./cwl/run_test.sh              # cwltool over the CWL adapters (needs cwltool)
./airflow/run_test.sh          # Airflow standalone DAG run (needs docker socket)
./jupyter/run_test.sh          # execute the tutorial notebook in the image
./run_all.sh [docker cwl airflow jupyter]
KEEP=1 ./docker/run_test.sh    # keep image/work dir for inspection
```

All scripts exit non-zero on failure and print a `PASS:`/`FAIL:` line per
check. On failure every script keeps its work dir (with the full log /
executed notebook / task logs) and records it in `tests/<flavour>/.e2e_workdir`
— in CI the on-failure step tars + uploads it as an artefact; locally, just
inspect it.

### Prerequisites

| Flavour | Needs |
| --- | --- |
| docker | docker daemon. Image build pulls the conda env and fetches `conda_env/environment.yml` + `python/workflow.py` from GitHub `main` at build time. |
| cwl | docker daemon + `cwltool` (e.g. `micromamba create -n cwl -c conda-forge cwltool`). Tool images (quay.io/biocontainers/*, 5.2.x) are pre-pulled with retries; cwltool runs with `--no-match-user`. |
| airflow | docker daemon reachable from the container (`/var/run/docker.sock`) for the nested tool containers. Builds a throwaway `biobb-airflow-test:3.3.2` image. |
| jupyter | docker daemon + **network** (the notebook downloads the A023K DPPC system from MDDb at runtime). |

Apple Silicon: the scripts auto-add `--platform linux/amd64` and warn — runs
are emulated (slow).

## What each test asserts

The workflow is an 11-step **membrane analysis** of an existing DPPC
simulation (the A023K system): trajectory fitting (`gmx_image`), membrane
segmentation (`fatslim_membranes`), leaflet assignment + z-positions
(`lpp_assign_leaflets`, `lpp_zpositions`), area per lipid
(`fatslim_apl`), order parameter (`gorder_aa`), cpptraj density profile
(`cpptraj_density`), HOLE pore analysis (`mda_hole`) and lipids flip-flop
(`lpp_flip_flop`).

- **docker**: container exit code 0 and the final output exists non-empty:
  `flip_flop.csv` (step11_lpp_flip_flop).
- **cwl**: cwltool exit code 0 (no ERROR lines) and `flip_flop.csv` in
  `--outdir`.
- **airflow**: DAG run reaches `success` and all 11 output folders have
  their `manifest.json`.
- **jupyter**: `jupyter nbconvert --execute` over the whole tutorial
  notebook finishes without raising cells (and no error outputs), and
  `flip_flop.csv` + `executed.ipynb` exist.

## Notes

- **Runtime**: this is a pure analysis workflow — no MD run, no mdp/nsteps,
  no MPI — so no e2e script applies a runtime reduction (the CI python
  flavour runs it unreduced too). The jupyter notebook already uses its
  reduced settings (`steps=1`, downsampled frames).
- **docker/jupyter validate the published state**: the docker image bakes
  the jupyter-repo env + `python/workflow.py` from GitHub `main` at build
  time; the jupyter test executes the notebook from the `jupyter/` submodule
  (or a fresh clone) — not the copy baked into the image.
- **Inputs**: `structure.pdb`, `topology.tpr` and `trajectory.xtc` are
  committed next to each flavour's config (docker/, cwl/, airflow/inputs/);
  only the jupyter notebook fetches its own copy (A023K) from MDDb.
- **Images**: the tools run on `biobb_mem:5.2.2--pyhdfd78af_0` (ships
  cpptraj for the density step) and `biobb_analysis:5.2.1--gmx2026_2`
  (gmx_image — needs the gromacs binaries; the gmx build is correct there
  because no cpptraj step uses it).
