# biobb_wf_pmx_tutorial — tests

Per-flavour end-to-end tests. `python/` is the step-by-step pytest suite (run
in CI); `docker/` and `jupyter/` are local e2e scripts (see
`docs/testing.md`). This workflow has **no cwl or airflow flavour** (no
`cwl/` or `airflow/` directory).

## Running

```console
cd biobb_workflows/biobb_wf_pmx_tutorial/tests

./docker/run_test.sh            # build image + run MODE=python + assert outputs
./jupyter/run_test.sh           # execute the tutorial notebook in the image
./run_all.sh [docker jupyter]
KEEP=1 ./docker/run_test.sh     # keep image/work dir for inspection
```

All scripts exit non-zero on failure and print a `PASS:`/`FAIL:` line per
check. On failure every script keeps its work dir (with the full log /
executed notebook / container log) and records it in
`tests/<flavour>/.e2e_workdir` — in CI the on-failure step tars + uploads it
as an artefact; locally, just inspect it.

### Prerequisites

| Flavour | Needs |
| --- | --- |
| docker | docker daemon. Image build pulls the conda env and fetches the notebook/env + `python/workflow.py` from GitHub `main` at build time. |
| jupyter | docker daemon (same image as the docker flavour — both share `biobb_wf_pmx_tutorial:test`). The notebook env (from the jupyter repo) ships `jupyter` + `plotly`. |

Apple Silicon: the scripts auto-add `--platform linux/amd64` and warn — runs
are emulated (slow).

## What each test asserts

The workflow is the PMX alchemical-mutation tutorial (10Ala -> 10Ile,
fast-growth TI): per state (stateA/stateB) and per extracted trajectory frame
it runs the hybrid-topology protocol (pmx mutate, pdb2gmx, gentop, make_ndx,
energy minimization for stateB, equilibration, thermodynamic integration),
then `pmx_analyse` (FDTI) over the collected dhdl files.

- **docker**: container exit code 0 and the final outputs exist non-empty:
  `pmx.txt` + `pmx.plots.png` (step11_pmx_analyse).
- **jupyter**: `nbconvert --execute` exits 0, `executed.ipynb` has no error
  cells, and `pmx.txt` + `pmx.plots.png` exist non-empty.

## Notes

- **Runtime (docker)**: the unreduced workflow extracts ~250 frames per state
  (step0 `end: 1000`, `skip: 2` over the 1 ns trajectories) and would take
  hours. `adjust_runtime` in `docker/run_test.sh` (a) reduces every mdp
  `nsteps` to 50 — the same reduction the CI python flavour applies
  (`python-reusable.yaml`) — and (b) caps step0 at 2 frames (`end: 3`, the
  same number the pytest suite runs).
- **Runtime (jupyter)**: the notebook processes ONE frame per state (cell 3);
  `adjust_runtime` in `jupyter/run_test.sh` reduces every mdp `nsteps` to 50
  (same value as the docker/CI flavours) in the local notebook copy before
  execution.
- **Inputs**: the workflow/notebook reference the state files with relative
  paths (`pmx_tutorial/state{A,B}.tpr|xtc`), so both e2e scripts copy the
  committed `docker/pmx_tutorial/` files into the work dir. The `dhdlA.zip`/
  `dhdlB.zip` committed next to them are tutorial reference inputs for a
  standalone step11 run — the full workflow generates its own dhdl zips.
- **python 3.12 path**: `python/workflow.py` and the notebook hardcode the
  pmx force-field lib under `$CONDA_PREFIX/lib/python3.12/site-packages/pmx/
  data/mutff/` — the image env must resolve to python 3.12 (as the CI env
  does). The `python3.10` paths in `docker/workflow.yml` are dead config
  (overridden by `workflow.py` at runtime).
- **docker/jupyter validate the published state**: the image build picks up
  `main` content at build time, not unpushed edits (the executed notebook
  comes from the submodule/clone, not the copy baked into the image).
