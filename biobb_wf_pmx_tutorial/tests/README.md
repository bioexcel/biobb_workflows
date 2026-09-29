# biobb_wf_pmx_tutorial — tests

Per-flavour end-to-end tests. `python/` is the step-by-step pytest suite (run
in CI); `docker/` and `jupyter/` are local e2e scripts (see
`docs/testing.md`). This workflow has **no cwl or airflow flavour** (no
`cwl/` or `airflow/` directory).

## Running

```console
cd biobb_workflows/biobb_wf_pmx_tutorial/tests

./docker/run_test.sh            # build image + run the pytest suite in it + assert outputs
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
| docker | docker daemon + network at test time (one `pip install pytest` into the image env). Image build pulls the conda env and fetches the notebook/env + `python/workflow.py` from GitHub `main` at build time. |
| jupyter | docker daemon (same image as the docker flavour — both share `biobb_wf_pmx_tutorial:test`). The notebook env (from the jupyter repo) ships `jupyter` + `plotly`. |

Apple Silicon: the scripts auto-add `--platform linux/amd64` and warn — runs
are emulated (slow).

## What each test asserts

The workflow is the PMX alchemical-mutation tutorial (10Ala -> 10Ile,
fast-growth TI): per state (stateA/stateB) and per extracted trajectory frame
it runs the hybrid-topology protocol (trjconv, pmx mutate, pdb2gmx, gentop,
make_ndx, energy minimization for stateB, equilibration, thermodynamic
integration), then `pmx_analyse` (FDTI) over the collected dhdl files.

- **docker**: the same pytest suite the CI python flavour runs, executed
  inside the published image's conda env — pytest exit code 0 (every step's
  own output checks pass) and the final outputs exist non-empty:
  `pmx.txt` + `pmx.plots.png` (step11_pmx_analyse).
- **jupyter**: `nbconvert --execute` exits 0, `executed.ipynb` has no error
  cells, and `pmx.txt` + `pmx.plots.png` exist non-empty.

## Notes

- **Runtime (docker)**: the docker lane runs the pytest suite, not
  `workflow.py` — the script loops over ALL frames step0 extracts from the 1
  ns trajectories (~25 per state, step0 `end: 1000`, `skip: 2`) and would
  take far too long for CI, while the suite runs the identical protocol on
  2 frames per state (what the python lane validates). The only reduction is
  the same one the CI python flavour applies (`python-reusable.yaml` seds
  every mdp `nsteps` in `python/workflow.yml` to 50). No frame cap, no
  preflight. `workflow.py`'s full-frame orchestration is therefore not
  exercised in CI (the notebook lane covers the protocol steps in the
  image).
- **Runtime (jupyter)**: the notebook processes ONE frame per state (cell 3);
  `adjust_runtime` in `jupyter/run_test.sh` reduces every mdp `nsteps` to 50
  (same value as the docker/CI flavours) in the local notebook copy before
  execution.
- **Inputs**: the docker lane copies the suite's own committed inputs
  (`tests/python/pmx_tutorial/state{A,B}.tpr|xtc`) into the work dir with
  the same relative layout the CI python flavour uses (CWD = `tests/python`,
  config at `../../python/workflow.yml`). The jupyter lane copies the
  committed `docker/pmx_tutorial/` files — including
  `dhdl{A,B}.zip`, because the **notebook's final pmx_analyse cell uses
  those pre-computed zips** (per the notebook comment the tutorial computes
  only one transition, so the FDTI analysis uses values from a real snase
  run) instead of the dhdl files its own TI runs write.
- **python 3.12 path**: `python/workflow.py` and the notebook hardcode the
  pmx force-field lib under `$CONDA_PREFIX/lib/python3.12/site-packages/pmx/
  data/mutff/` — the image env must resolve to python 3.12 (as the CI env
  does). The `python3.10` paths in `docker/workflow.yml` are dead config
  (overridden by `workflow.py` at runtime).
- **docker/jupyter validate the published state**: the image build picks up
  `main` content at build time, not unpushed edits (the executed notebook
  comes from the submodule/clone, not the copy baked into the image).
