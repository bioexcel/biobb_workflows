# biobb_wf_ligand_parameterization — tests

End-to-end tests per flavour. `python/` is the step-by-step pytest suite (already
run in CI). `docker/`, `cwl/`, `airflow/` and `jupyter/` are local e2e scripts
(phase 1 — can also be triggered manually from GitHub Actions, see
`docs/testing.md`).

The workflow itself is short (2 steps: babel minimisation + acpype parameterisation,
one input `ligand.pdb`), so all four tests finish in a few minutes once the
containers/images are pulled.

## Running (one by one)

```console
cd biobb_workflows/biobb_wf_ligand_parameterization/tests

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

Each script prints `PASS:`/`FAIL:` lines and a final `PASS`/`FAIL` summary, and exits
with a non-zero code on failure (so scripts/CI can detect it).

### What you need installed

| Test | Needs |
| --- | --- |
| docker | a running docker daemon. First build downloads the conda environment (~GB) and fetches the env file/notebook/workflow.py from GitHub `main`. |
| cwl | a running docker daemon + `cwltool` on PATH (e.g. `micromamba create -n cwl -c conda-forge cwltool`). First run pulls the tool containers from quay.io. |
| airflow | a running docker daemon. Builds the helper image `biobb-airflow-test:3.3.2` once (official Airflow 3.3.2 + cwltool + docker CLI), then starts/stops a throwaway Airflow. |
| jupyter | a running docker daemon (reuses the docker-test image, so the first run builds it) + `git` (only if the `jupyter/` submodule is not checked out) + network access (the notebook fetches the IBP structure from the MMB REST API). |

On Apple Silicon the docker/cwl tests run the x86 images under emulation (slow, and
some Intel OpenMP binaries need workarounds) — for representative results run them on
the Linux server.

## What each test checks

The docker, cwl and airflow tests check the **same two things**: the workflow ends
successfully, and the final files exist and are not empty:

- `output.params.gro`
- `output.params.itp`
- `output.params.top`

1. **docker** — builds `<wf>/docker/Dockerfile`, runs the container in python mode with
   `ligand.pdb` mounted, and looks at the output folder the container writes to
   (note: the workflow writes into a subfolder — the `working_dir_path` value from
   `workflow.yml` — e.g. `work/biobb_wf_ligand_parameterization/`). The built image is
   kept after the run (reruns reuse it; `docker rmi biobb_wf_ligand_parameterization:test`
   to delete it).
2. **cwl** — runs `cwltool` over `cwl/workflow.cwl` (each step runs in its official
   BioBB tool container) and checks the output folder.
3. **airflow** — starts a real Airflow in a container, triggers the DAG
   `biobb_wf_ligand_parameterization`, waits until it finishes, and checks that **all 2
   tasks** succeeded and that each step left its `manifest.json` in `outputs/`.
4. **jupyter** — executes the tutorial notebook headlessly **inside the workflow
   docker image** with `jupyter nbconvert --to notebook --execute` (the image's conda
   env ships `jupyter` + `nglview`). The notebook is taken from the `jupyter/`
   submodule when it is checked out, otherwise the script shallow-clones
   `https://github.com/bioexcel/biobb_wf_ligand_parameterization` (all jupyter repos
   follow the `https://github.com/bioexcel/<WF NAME>` pattern) into the scratch dir.
   It passes when nbconvert exits 0 (it aborts on the first raising cell), the
   executed notebook has no `error` outputs, and `IBPparams.gro` / `IBPparams.itp` /
   `IBPparams.top` exist and are not empty. Note the notebook writes
   `<ligandCode>params.*` (IBP), unlike the other flavours which write
   `output.params.*`.

## Notes

- The **docker** test validates the *published* state (the image downloads
  `environment.yml`, the notebook and `workflow.py` from GitHub `main` at build time),
  plus your local `Dockerfile`. It is not a test of unpushed edits to `workflow.py`.
- Nothing here needs MD-style parameter reduction: the workflow is already light. The
  `adjust_runtime()` hook in each script is left as a no-op, with an example (relaxing
  the babel `criteria`) commented out in case you ever want it.
- Scratch/output folders (`tests/docker/work/`, `tests/cwl/out/`,
  `tests/jupyter/work/`, the airflow temp dir) are created automatically and removed
  when the script finishes (unless `--keep`).
- The **jupyter** test reuses the docker-test image (`biobb_wf_ligand_parameterization:test`,
  same tag), so running `docker/run_test.sh` before it makes the second one much faster.
