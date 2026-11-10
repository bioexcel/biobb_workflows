# Mutation Free Energy Calculations using BioExcel Building Blocks (biobb): Nextflow

Nextflow version of the [python workflow](../python/workflow.py), with the [BioBB Nextflow modules](https://github.com/bioexcel/biobb_adapters/tree/master/biobb_adapters/nextflow) it uses copied in `modules/`. Every step runs the BioBB block inside its biocontainer (or bioconda package) with the properties of [python/workflow.yml](../python/workflow.yml).

Ported by hand: utils_biobb `nextflow_wf_generator.py` can't translate the python logic of `workflow.py`. That logic is:

* the loops over the two states and over the frames extracted from their trajectories;
* the energy minimization, only in stateB;
* the zips of the dhdl files of each state;
* the `gmx_lib` (GMXLIB) folder of the conda env.

Here every state and frame is a task of its steps, all of them run in parallel. The frames and the dhdl files are extracted and zipped by the local `unzip` and `zip` modules (`modules/local`, in the biobb_common image). Running the generator on it only refreshes the modules.

The pmx force field (`amber99sb-star-ildn-mut`) is in the biobb_pmx image only, but pdb2gmx and grompp run in the biobb_gromacs image. The MUTFF process of `main.nf` copies its folder (`pmx/data/mutff`) from the biobb_pmx image into the work directory, and its path is the `gmx_lib` property of step1, step2, step3, step5, step7 and step9. The modules have no input for it, so `nextflow.config` mounts it in the containers of those steps (`containerOptions`, docker / podman `--volume` or apptainer / singularity `--bind`). It needs a work directory on a shared file system: a work directory in object storage (cloud executors) would not work.

## Run

From a clone of this repository, with [Nextflow](https://www.nextflow.io/docs/latest/install.html) >=25.10.0 and Docker:

```bash
nextflow run biobb_wf_pmx_tutorial/nextflow -profile docker
```

Profiles: `docker`, `apptainer`, `singularity` and `conda`. Results are written to `results/<id>/<state>/step0_trjconv/`, `results/<id>/<state>/<frame>/<step>/` for step1 to step10, and `results/<id>/step11_pmx_analyse/` (`-output-dir` to change it), with files named `<id>_<step>_<role>.<ext>`.

## Inputs

`samplesheet.csv` (`--input`): one row per system, all of them run in parallel. Paths are absolute or relative to the samplesheet folder. The default samplesheet runs the inputs of the python workflow (`input_trajs` global property).

| Column | Python workflow input | Used by |
|---|---|---|
| `id` | | Name of the run, prefix of the output files |
| `stateA_tpr` | `pmx_tutorial/stateA.tpr` | step0_trjconv (stateA) |
| `stateA_traj` | `pmx_tutorial/stateA_1ns.xtc` | step0_trjconv (stateA) |
| `stateB_tpr` | `pmx_tutorial/stateB.tpr` | step0_trjconv (stateB) |
| `stateB_traj` | `pmx_tutorial/stateB_1ns.xtc` | step0_trjconv (stateB) |

Parameters:

| Parameter | Default | Description |
|---|---|---|
| `--stateA_mutation` | `10Ala` | Mutation of the stateA frames (`mutations` global property, `mutation_list` of step1_pmx_mutate) |
| `--stateB_mutation` | `10Ile` | Mutation of the stateB frames |

## Configuration

`nextflow.config` has the BioBB properties (`ext.properties`) and output extensions (`ext.outputs`) of every step, and the CPUs of the multithreaded steps (process_medium label). Change them there or in a config file given with `-c`.

## Steps

| Step | Block | Description |
|---|---|---|
| step0_trjconv | [biobb_analysis/gmx_trjconv_str_ens](modules/bioexcel/biobb_analysis/gmx_trjconv_str_ens/README.md) | Extract snapshots from equilibrium trajectories, per state. The zip is extracted (UNZIP_FRAMES): one item per frame |
| step1_pmx_mutate | [biobb_pmx/pmxmutate](modules/bioexcel/biobb_pmx/pmxmutate/README.md) | Generate Hybrid Structure |
| step2_gmx_pdb2gmx | [biobb_gromacs/pdb2gmx](modules/bioexcel/biobb_gromacs/pdb2gmx/README.md) | Generate Topology |
| step3_pmx_gentop | [biobb_pmx/pmxgentop](modules/bioexcel/biobb_pmx/pmxgentop/README.md) | Generate Hybrid Topology |
| step4_gmx_makendx | [biobb_gromacs/make_ndx](modules/bioexcel/biobb_gromacs/make_ndx/README.md) | Generate Gromacs Index file to select atoms to freeze |
| step5_gmx_grompp | [biobb_gromacs/grompp](modules/bioexcel/biobb_gromacs/grompp/README.md) | Creating portable binary run file for energy minimization (stateB only) |
| step6_gmx_mdrun | [biobb_gromacs/mdrun](modules/bioexcel/biobb_gromacs/mdrun/README.md) | Running energy minimization (stateB only) |
| step7_gmx_grompp | [biobb_gromacs/grompp](modules/bioexcel/biobb_gromacs/grompp/README.md) | Creating portable binary run file for system equilibration, from the step2 structure (stateA) or the step6 one (stateB) |
| step8_gmx_mdrun | [biobb_gromacs/mdrun](modules/bioexcel/biobb_gromacs/mdrun/README.md) | Running system equilibration |
| step9_gmx_grompp | [biobb_gromacs/grompp](modules/bioexcel/biobb_gromacs/grompp/README.md) | Creating portable binary run file for thermodynamic integration (ti) |
| step10_gmx_mdrun | [biobb_gromacs/mdrun](modules/bioexcel/biobb_gromacs/mdrun/README.md) | Running thermodynamic integration |
| step11_pmx_analyse | [biobb_pmx/pmxanalyse](modules/bioexcel/biobb_pmx/pmxanalyse/README.md) | Calculate free energies from fast growth thermodynamic integration simulations, from the zips of the step10 dhdl files of each state (ZIP_DHDL, also in this folder) |
