# biobb_wf_haddock — tests

End-to-end tests per flavour. `python/` is the step-by-step pytest suite
(already run in CI). `docker/` and `jupyter/` are local e2e scripts (can also
be triggered manually from GitHub Actions, see `docs/testing.md`).

The workflow is HADDOCK3 antibody–antigen docking (antibody 4G6K, antigen
4I1B, complex 4G6M): pdb_tools preparation → paratope/epitope restraints →
topology → rigid body → CAPRI eval → top selection → flexible refinement →
CAPRI eval → electrostatics refinement → CAPRI eval → clustering → top
selection → CAPRI eval → contact map.

**Flavour availability:**

- `docker` — the workflow's baked-in `python/workflow.py` is self-contained:
  it runs the full preparation (heavy/light reduction, H/L zips, clean
  structures) *and* the docking inside the container. It reads the four raw
  inputs (`antibody.pdb`, `antigen.pdb`, `complex.pdb`,
  `antibody_actpass.txt`) from the working dir — the image CMD copies them
  there from `/data` (per-workflow Dockerfile patch in
  `common/docker/sync_dockerfiles.sh`). The test mounts the committed raw
  inputs read-only at `/data`, exactly like a user would per `docker/README.md`.
- `jupyter` — the tutorial notebook runs inside the workflow's docker image.
  It is self-contained (downloads the three PDBs from RCSB at run time), and
  it already ships the reduced docking settings (`rigid_body sampling: 10`
  instead of 1000, `select: 8`, `top_models: 4`) — the same values the CI
  python flavour runs. The test only disables the four
  `open_results_mod(...)` browser-open calls in its local copy (they raise
  `IndexError` in a headless run, where no jupyter server is registered) —
  the notebook in the jupyter repo is never touched.
- `cwl` / `airflow` — not available: the workflow has no `cwl/` or
  `airflow/` adapters in this repo.

Both flavours share the same image tag (`biobb_wf_haddock:test`), so running
one after the other reuses the build.

Expect on the first run (containers are pulled/cached afterwards):

- image build (~15-20 min, once).
- `docker`: the docking steps take the same order of magnitude as the CI
  python e2e for this workflow (the CI flavour job allows 720 min).
- `jupyter`: needs network access at run time (RCSB PDB downloads).

## Running

```console
cd biobb_workflows/biobb_wf_haddock/tests

./docker/run_test.sh    # 1. docker flavour
./jupyter/run_test.sh   # 2. jupyter flavour
```

or both in sequence:

```console
./run_all.sh
```

Useful options (same for both):

- `--keep` — keep the image / scratch folders after the run, to inspect what
  happened
- `--pull` — run the **published** image from GitHub Container Registry
  instead of building it; `--no-build` skips the build (image must exist
  already)
- jupyter only: `NB_REPO_URL=<url> ./jupyter/run_test.sh` overrides the
  notebook repo (e.g. to test a fork/branch)

Each script prints `PASS:`/`FAIL:` lines and a final `PASS`/`FAIL` summary,
and exits with a non-zero code on failure (so scripts/CI can detect it).

## Known risk

The notebook has never been executed headlessly before the jupyter test. If
a cell fails, the most likely suspects are the visualization/analysis cells
(pytraj `superpose_models` over the generated ensembles, or the
`haddock_wf_data` subfolder names the analysis cells read) — not the docking
steps, which are the same code path the green CI python e2e runs.
