# biobb_wf_structure_checking — tests

End-to-end tests per flavour. `python/` is the step-by-step pytest suite
(already run in CI). `docker/`, `cwl/`, `airflow/` and `jupyter/` are local
e2e scripts (can also be triggered manually from GitHub Actions, see
`docs/testing.md`).

The workflow is the 18-step structure quality check on the committed
`structure.pdb` (1Z83): model/chain extraction → altloc/ssbond fixes → ion
and ligand removal → hydrogen/water stripping → amide/chirality/side-chain/
backbone fixes (renumbered against the committed canonical
`sequence.fasta`) → LEAP topology → a short sander minimization (500
cycles) → final `structure_check` report, final output
`structure.report_final.json` (step17), which the python/docker suites
compare against the committed `reference/` golden file.

**Runtime reduction:** none — the sander step is a short (500-cycle)
minimization and the cwl/airflow input configs and the notebook are already
serial, so no e2e script reduces anything. The only local-copy adjustment is
in the `docker` test (and the CI python flavour): the MPI sander lines
(`binary_path: sander.MPI`, `mpi_np`, `mpi_bin`) are stripped from the
`python/workflow.yml` copy — the 5.3.x conda envs resolve the unpinned
ambertools dep to the latest nompi build, which ships no `sander.MPI`/
`mpirun`, so the minimization runs serially. The committed `workflow.yml` /
CWL input / airflow inputs / notebook are never modified.

Expect on the first run (containers are pulled/cached afterwards):

- `docker` & `jupyter`: image build (~20 min, same image — the jupyter test
  reuses the tag the docker test built).
- `cwl` / `airflow`: one `quay.io/biocontainers/*` image per tool step
  (~16 images), pulled through the host docker daemon.
- `jupyter`: the notebook downloads the 1Z83 structure from RCSB at run
  time.

## Running (one by one)

```console
cd biobb_workflows/biobb_wf_structure_checking/tests

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

Each script prints `PASS:`/`FAIL:` lines and a final `PASS`/`FAIL` summary, and
exits with a non-zero code on failure (so scripts/CI can detect it).
