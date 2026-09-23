# biobb_wf_md_setup — tests

End-to-end tests per flavour. `python/` is the step-by-step pytest suite
(already run in CI). `docker/`, `cwl/`, `airflow/` and `jupyter/` are local
e2e scripts (can also be triggered manually from GitHub Actions, see
`docs/testing.md`).

The workflow is the full 25-step GROMACS MD protocol on 1AKI (lysozyme):
pdb2gmx → solvate → genion → minimization → NVT → NPT → free MD → rmsd/rgyr →
trajectory imaging, final output `gppmdsim.tpr` (step24 grompp).

**Runtime reduction:** every e2e script reduces all `mdp nsteps` to `10` in
the local copy it runs (the `adjust_runtime` hook) — the same reduction the
CI python flavour applies in `python-reusable.yaml` — so the 4 mdrun steps
take seconds instead of days. The committed `workflow.yml` / CWL input /
airflow inputs / notebook are never modified.

Expect on the first run (containers are pulled/cached afterwards):

- `docker` & `jupyter`: image build (~20 min, same image — the jupyter test
  reuses the tag the docker test built).
- `cwl` / `airflow`: one `quay.io/biocontainers/*` image per tool step
  (~20 images), pulled through the host docker daemon.
- `jupyter`: the notebook also fetches the 1AKI PDB from RCSB at run time.

## Running (one by one)

```console
cd biobb_workflows/biobb_wf_md_setup/tests

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
- cwl only: `EXTRA_CWL_ARGS="--no-match-user" ./run_test.sh` (needed on Mac ARM)
- airflow only: `TIMEOUT_MIN=120 ./run_test.sh` sets the max waiting time
- jupyter only: `NB_REPO_URL=<url> ./run_test.sh` overrides the notebook repo
  (e.g. to test a fork/branch)

Each script prints `PASS:`/`FAIL:` lines and a final `PASS`/`FAIL` summary, and exits
with a non-zero code on failure (so scripts/CI can detect it).

## Known risk

`step21` (gmx_rgyr) is commented out in the pytest suite, so the e2e flavours
are the first to run it end-to-end; with a 10-step trajectory the rmsd/rgyr
xvg files contain a single point — if a step fails there, suspect the short
trajectory first.
