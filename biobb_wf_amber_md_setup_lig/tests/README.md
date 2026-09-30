# biobb_wf_amber_md_setup_lig — tests

End-to-end tests per flavour. `python/` is the step-by-step pytest suite
(already run in CI, with reduced runtime). `docker/`, `cwl/`, `airflow/` and
`jupyter/` are local e2e scripts (can also be triggered manually from GitHub
Actions, see `docs/testing.md`).

This workflow sets up a protein-ligand MD system from a crystal complex
(3htb, ligand JZ4): strip hydrogens / extract the molecule, concat the ions
and the heteroatoms, pdb4amber, leap gen_top with the pre-parameterized
ligand (GAFF `input_lib.zip`/`input_frcmod.zip`), solvation (TIP3P,
truncated octahedron) + ionization (NaCl 150 mM), two vacuum energy
minimizations, a solvent minimization, the heat/NVT/NPT equilibration
ladder, a free production MD and the cpptraj analysis (RMSD vs
first/experimental, radius of gyration, solute-imaged trajectory) — 23 steps
in `workflow.yml`. The unreduced workflow would run ~50 ps of production MD,
so every e2e flavour shortens the sander steps to the same values the CI
python flavour uses
(`.github/workflows/python-reusable.yaml`: `mpi_np -> 2`, `nstlim -> 500`,
`maxcyc -> 100`) on a local copy — the committed inputs are never modified.

Notes specific to this workflow:

- It is a **subrepo workflow**: the jupyter repo `biobb_wf_amber` is shared by
  the amber subrepos, and the docker image is built with
  `--build-arg REPO=biobb_wf_amber --build-arg SUBREPO=md_setup_lig` (the
  conda env inside the image is named `biobb_wf_amber`).
- The `docker/` flavour runs **serial sander**: `docker/workflow.yml` drops
  the `sander.MPI`/`mpi_np` lines that `python/workflow.yml` has (the cwl and
  airflow configs were generated serial already — see `NOTES.md`). It mounts
  five inputs at `/data`: `structure.pdb`, `ions.pdb`, `heteroatoms.pdb`,
  `input_lib.zip`, `input_frcmod.zip`.
- The jupyter notebook is **not** self-contained: it downloads the 3htb
  complex from the RCSB at run time (network needed on the GH runner) and —
  unlike the other flavours — parameterizes the ligand **on the fly** with
  acpype/antechamber (`acpype_params_ac`, local tools) instead of reading the
  committed GAFF zips, so no input files are shipped with it.
- The jupyter test runs the container as root and passes
  `OMPI_ALLOW_RUN_AS_ROOT=1` (+ `..._CONFIRM=1`): kept in case an image/notebook
  pair uses `mpirun` (e.g. a 5.2.x image); with the 5.3.x image the sander
  steps run serial (the 5.3.x env has no `sander.MPI`/`mpirun` — see the
  header of `jupyter/run_test.sh`), where they are inert.
- The biobb 5.3.x conda envs cannot resolve an openmpi ambertools (conda-forge
  ships none for ambertools >= 25, and the 24.8 one conflicts with
  `biobb_analysis` 5.3.0's gromacs 2026 dep), so the CI python flavour strips
  the MPI lines and runs the sander steps serial (`python-reusable.yaml`);
  `python/workflow.yml` itself stays MPI.
- The docker image env pins `mkl <2026` (mkl 2026.x dropped
  `libmkl_core.so.2`, which cpptraj needs — see `python/workflow.env.yml`),
   and `docker/VERSION` (2026.1) carries the image version label.

Runtime on a native amd64 machine, with reduced sander steps and
pre-pulled images: docker ~15–30 min, jupyter similar, cwl/airflow similar
(first run also pulls the per-tool biocontainers images).

## Running (one by one)

```console
cd biobb_workflows/biobb_wf_amber_md_setup_lig/tests

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
