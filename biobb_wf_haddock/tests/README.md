# biobb_wf_haddock — tests

End-to-end tests per flavour. `python/` is the step-by-step pytest suite
(already run in CI). `jupyter/` is a local e2e script (can also be triggered
manually from GitHub Actions, see `docs/testing.md`).

The workflow is HADDOCK3 antibody–antigen docking (antibody 4G6K, antigen
4I1B, complex 4G6M): pdb_tools preparation → paratope/epitope restraints →
topology → rigid body → CAPRI eval → top selection → flexible refinement →
CAPRI eval → electrostatics refinement → CAPRI eval → clustering → top
selection → CAPRI eval → contact map.

**Flavour availability:**

- `jupyter` — full-pipeline e2e: the tutorial notebook runs inside the
  workflow's docker image. It is self-contained (downloads the three PDBs
  from RCSB at run time), and it already ships the reduced docking settings
  (rigid_body `sampling: 10` instead of 1000, `select: 8`, `top_models: 4`) —
  the same values the CI python flavour runs. The test only disables the four
  `open_results_mod(...)` browser-open calls in its local copy (they raise
  `IndexError` in a headless run, where no jupyter server is registered) —
  the notebook in the jupyter repo is never touched.
- `docker` — **opted out** via `docker/SKIP`: the committed
  `docker/workflow.yml` expects prepared inputs (heavy-light zips, clean
  pdbs) that the image's python mode cannot produce from the raw inputs
  shipped in `docker/`. The jupyter e2e covers the full pipeline in the same
  image, so the env is validated anyway. See the SKIP file for the
  re-enablement plan.
- `cwl` / `airflow` — not available: the workflow has no `cwl/` or
  `airflow/` adapters in this repo.

Expect on the first run (containers are pulled/cached afterwards):

- `jupyter`: image build (~15-20 min), then the notebook run — the docking
  steps take the same order of magnitude as the CI python e2e for this
  workflow (the CI flavour job allows 720 min).
- `jupyter`: needs network access at run time (RCSB PDB downloads).

## Running

```console
cd biobb_workflows/biobb_wf_haddock/tests

./jupyter/run_test.sh   # jupyter flavour
```

or:

```console
./run_all.sh
```

Useful options:

- `--keep` — keep the image / scratch folder after the run, to inspect what
  happened
- `--pull` — run the **published** image from GitHub Container Registry
  instead of building it; `--no-build` skips the build (image must exist
  already)
- `NB_REPO_URL=<url> ./jupyter/run_test.sh` — override the notebook repo
  (e.g. to test a fork/branch)

The script prints `PASS:`/`FAIL:` lines and a final `PASS`/`FAIL` summary,
and exits with a non-zero code on failure (so scripts/CI can detect it).

## Known risk

The notebook has never been executed headlessly before this test. If a cell
fails, the most likely suspects are the visualization/analysis cells
(pytraj `superpose_models` over the generated ensembles, or the
`haddock_wf_data` subfolder names the analysis cells read) — not the docking
steps, which are the same code path the green CI python e2e runs.
