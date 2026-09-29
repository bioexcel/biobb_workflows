# biobb_wf_protein_md_analysis — tests

Per-flavour end-to-end tests. `python/` is the step-by-step pytest suite
(run in CI); `docker/` is the local e2e script (see `docs/testing.md`).
This workflow has **no cwl, airflow or jupyter flavour** (no such
directories, no notebook repo).

## Running

```console
cd biobb_workflows/biobb_wf_protein_md_analysis/tests

./docker/run_test.sh            # build image + run the pytest suite in it + assert outputs
./run_all.sh [docker]
KEEP=1 ./docker/run_test.sh     # keep image/work dir for inspection
```

All scripts exit non-zero on failure and print a `PASS:`/`FAIL:` line per
check. On failure every script keeps its work dir (with the full log /
container log) and records it in `tests/<flavour>/.e2e_workdir` — in CI the
on-failure step tars + uploads it as an artefact; locally, just inspect it.

### Prerequisites

| Flavour | Needs |
| --- | --- |
| docker | docker daemon + network at test time (one `pip install pytest` into the image env). Image build pulls the conda env and fetches the env file + `python/workflow.py` from GitHub `main` at build time (no notebook — no jupyter repo). |

Apple Silicon: the scripts auto-add `--platform linux/amd64` and warn — runs
are emulated (slow).

## What each test asserts

The workflow analyses a committed MD trajectory (`run_md: False` — no MD
simulation): cpptraj average structure, RMSF, RMSAV, B-factors, radius of
gyration and format conversion to trr, then `gmx_cluster` over the converted
trajectory (cutoff 0.2 nm).

- **docker**: the same pytest suite the CI python flavour runs, executed
  inside the published image's conda env — pytest exit code 0 (every step's
  own output checks pass, and step7 compares its outputs against the
  committed `reference/` golden files: exact match on the cluster pdb, size
  within 10 bytes on the cluster log) and the final outputs exist non-empty:
  `output.cluster.pdb` + `output.cluster.log` (step7_gmx_cluster).

## Notes

- **Runtime (docker)**: none — the workflow is pure analysis on a small
  committed trajectory, so the docker lane runs the full suite verbatim,
  exactly as the python CI flavour does (same suite, same config path, no
  seds).
- **Inputs**: the docker lane copies the suite's own committed inputs
  (`tests/python/topology.pdb` + `trajectory.nc`, plus `reference/`) into
  the work dir with the same relative layout the CI python flavour uses
  (CWD = `tests/python`, config at `../../python/workflow.yml`).
- **biopython**: the suite and `workflow.py` use `Bio.PDB` to graft the
  cpptraj B-factors onto the topology before clustering — it comes in via
  `biobb_common` (a hard dependency of `biobb_analysis`), so nothing extra
  is installed.
- **docker validates the published state**: the image build picks up `main`
  content at build time, not unpushed edits.
