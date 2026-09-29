# biobb_wf_md_setup_mutations — tests

Per-flavour end-to-end tests. `python/` is the step-by-step pytest suite (run
in CI); `docker/`, `cwl/` and `airflow/` are local e2e scripts (see
`docs/testing.md`). This workflow has **no jupyter flavour** (no jupyter
repo / notebook) — the docker image bakes `python/workflow.env.yml` +
`python/workflow.py` from this repo's `main` at build time.

## Running

```console
cd biobb_workflows/biobb_wf_md_setup_mutations/tests

./docker/run_test.sh           # build image + run MODE=python + assert outputs
./cwl/run_test.sh              # cwltool over the CWL adapters (needs cwltool)
./airflow/run_test.sh          # Airflow standalone DAG run (needs docker socket)
./run_all.sh [docker cwl airflow]
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
| docker | docker daemon. Image build pulls the conda env and fetches `python/workflow.env.yml` + `python/workflow.py` from GitHub `main` at build time. |
| cwl | docker daemon + `cwltool` (e.g. `micromamba create -n cwl -c conda-forge cwltool`). Tool images (quay.io/biocontainers/*, 5.3.x) are pre-pulled with retries; cwltool runs with `--no-match-user`. |
| airflow | docker daemon reachable from the container (`/var/run/docker.sock`) for the nested tool containers. Builds a throwaway `biobb-airflow-test:3.3.2` image. |

Apple Silicon: the scripts auto-add `--platform linux/amd64` and warn — runs
are emulated (slow).

## What each test asserts

The workflow is the 25-step GROMACS MD setup protocol on 1AKI (lysozyme +
ions) run **once per mutation** — the `mutations` list
(`A:Gly4Lys`, `A:Leu8Met`, `A:Tyr20Gln`).

- **docker**: container exit code 0 and the final output per mutation exists
  non-empty: 3 x `gppmdsim.tpr` (step24_grompp_md, one per mutation working
  dir).
- **cwl**: cwltool exit code 0 (no ERROR lines) and 3 x `gppmdsim.tpr` in
  `--outdir` (the workflow scatters over `mutations_list` and gathers each
  branch's outputs into a per-mutation directory).
- **airflow**: DAG run reaches `success` and all 73 output folders
  (4 shared steps + 23 per-mutation steps x 3 mutations) have their
  `manifest.json`.

## Notes

- **Runtime**: the 4 mdrun steps per mutation are the compute steps. Every
  e2e script (and the CI python flavour, via `python-reusable.yaml`) reduces
  every mdp `nsteps` to 10 — the 12 mdrun calls then take seconds, not days.
  No MPI anywhere (serial gromacs).
- **docker/cwl validate the published state**: the docker image and the cwl
  input yml pick up `main` content at run/build time, not unpushed edits.
- **airflow per-mutation layout**: the DAG calls
  `create_bash_command(..., mutation=...)`; per-mutation tasks read
  `airflow/inputs/<mutation_tag>/<step>.yml` (the `MUTATION` placeholder in
  `step3_mutate.yml` replaced with the real mutation; cross-step references
  point at the suffixed `outputs/<step>_<mutation_tag>/` folders) and write
  to `airflow/outputs/<step>_<mutation_tag>/`.
- **Quay image note**: `biobb_analysis:5.3.0--gmx2026_2` is used here because
  every analysis step in this workflow is a GROMACS tool (gmx_energy,
  gmx_rgyr, gmx_trjconv_str, gmx_image, gmx_rms) that needs the gromacs
  binaries baked into that build. (If a cpptraj step is ever added, it must
  use `biobb_analysis:5.3.0--pyhdfd78af_1` instead — the gmx build has no
  cpptraj.)
