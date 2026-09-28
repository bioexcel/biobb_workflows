# biobb_wf_autoencoder — tests

End-to-end tests per flavour. `python/` is the step-by-step pytest suite
(already run in CI, unreduced). `docker/`, `cwl/`, `airflow/` and `jupyter/`
are local e2e scripts (can also be triggered manually from GitHub Actions,
see `docs/testing.md`).

This workflow applies a multilayer autoencoder for anomaly detection to MD
trajectories: GROMACS imaging of a protein apo/holo pair (14 steps),
MDFeaturizer feature extraction, autoencoder build + training (100 epochs),
evaluation of the holo set against the apo model, RMSF analysis, feat2traj
reconstruction and a final `make_plumed` step (the `plumed.dat` /
`plumed_model.ptc` / `features.dat` outputs). There is **no MD to shorten
and no MPI anywhere**, so no e2e flavour applies a runtime reduction — the
AE training is already CI-sized (the CI python flavour runs it unreduced).

Notes specific to this workflow:

- It has its **own jupyter repo** (`biobb_wf_autoencoder`, not shared): the
  docker image is built with `--build-arg REPO=biobb_wf_autoencoder` (no
  `SUBREPO`), and the conda env inside the image is named
  `biobb_wf_autoencoder`.
- The jupyter notebook is **not** self-contained: it downloads its inputs
  from **MDDB** at run time (`biobb_io.mddb`, node `irb-dev`, project
  `MCV1900210`, frames 1-10000), so the jupyter test needs network access to
  the MDDB (the GH runner has it). That download is the most fragile part of
  the test: if the MDDB node/project changes or goes down, the first cells
  fail with a connection error, not a workflow error.
- The `docker/`, `cwl/` and `airflow/` flavours run on the committed input
  pair (`str_in.pdb`/`trj_in.xtc` apo + `test_str_in.pdb`/`test_trj_in.xtc`
  holo) — no network needed.
- Versions: these tests run the 5.3.x stack (`biobb_pytorch` 5.3.0,
  `biobb_analysis` 5.3.0 gmx build, `biobb_gromacs` 5.3.2); the cwl/airflow
  adapters carry the matching 5.3.x image tags.

Runtime on a native amd64 machine with pre-pulled images: docker ~10–20 min,
jupyter similar, cwl/airflow similar (first run also pulls the per-tool
biocontainers images).

## Running (one by one)

```console
cd biobb_workflows/biobb_wf_autoencoder/tests

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
