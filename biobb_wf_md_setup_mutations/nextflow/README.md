# Mutations Protein MD Setup tutorial using BioExcel Building Blocks (biobb): Nextflow

Nextflow version of the [python workflow](../python/workflow.py), with the [BioBB Nextflow modules](https://github.com/bioexcel/biobb_adapters/tree/master/biobb_adapters/nextflow) it uses copied in `modules/`. Every step runs the BioBB block inside its biocontainer (or bioconda package) with the properties of [python/workflow.yml](../python/workflow.yml).

Ported by hand: utils_biobb `nextflow_wf_generator.py` can't translate the python loop over the mutations of `workflow.py`. Here step3 to step24 run once per system and mutation, all in parallel. Running the generator on it only refreshes the modules.

## Run

From a clone of this repository, with [Nextflow](https://www.nextflow.io/docs/latest/install.html) >=25.10.0 and Docker:

```bash
nextflow run biobb_wf_md_setup_mutations/nextflow -profile docker
```

Profiles: `docker`, `apptainer`, `singularity` and `conda`. Results are written to `results/<id>/<step>/`, and to `results/<id>/<mutation>/<step>/` for step3 to step24 (`-output-dir` to change it), with files named `<id>_<step>_<role>.<ext>`.

## Inputs

`samplesheet.csv` (`--input`): one row per system, all of them run in parallel. Paths are absolute or relative to the samplesheet folder. The default samplesheet runs the inputs of the python workflow.

| Column | Python workflow input | Used by |
|---|---|---|
| `id` | | Name of the run, prefix of the output files |
| `structure` | `structure.pdb` | step0_reduce_remove_hydrogens |
| `ions` | `ions.pdb` | step00_cat_pdb |

Parameters:

| Parameter | Default | Description |
|---|---|---|
| `--mutations` | `['A:Gly4Lys', 'A:Leu8Met', 'A:Tyr20Gln']` | Mutations of the python loop (`mutations` global property, `mutation_list` of step3_mutate): step3 to step24 run once per mutation. A list: give it in a `-params-file`, for example `mutations: ['A:Gly4Lys']` |
| `--run_md` | `true` | Run the steps under `run_md` in the python workflow: step24_grompp_md |

## Configuration

`nextflow.config` has the BioBB properties (`ext.properties`) and output extensions (`ext.outputs`) of every step, and the CPUs of the multithreaded steps (process_medium label). Change them there or in a config file given with `-c`.

## Steps

| Step | Block | Description |
|---|---|---|
| step0_reduce_remove_hydrogens | [biobb_chemistry/reduce_remove_hydrogens](modules/bioexcel/biobb_chemistry/reduce_remove_hydrogens/README.md) | Removing Hydrogens |
| step1_extract_molecule | [biobb_structure_utils/extract_molecule](modules/bioexcel/biobb_structure_utils/extract_molecule/README.md) | Extracting Protein |
| step00_cat_pdb | [biobb_structure_utils/cat_pdb](modules/bioexcel/biobb_structure_utils/cat_pdb/README.md) | Concatenating protein with included ions |
| step2_fix_side_chain | [biobb_model/fix_side_chain](modules/bioexcel/biobb_model/fix_side_chain/README.md) | Modeling the missing heavy atoms in the structure side chains |
| step3_mutate | [biobb_model/mutate](modules/bioexcel/biobb_model/mutate/README.md) | Modeling mutation |
| step4_pdb2gmx | [biobb_gromacs/pdb2gmx](modules/bioexcel/biobb_gromacs/pdb2gmx/README.md) | Generate the topology |
| step5_editconf | [biobb_gromacs/editconf](modules/bioexcel/biobb_gromacs/editconf/README.md) | Create the solvent box |
| step6_solvate | [biobb_gromacs/solvate](modules/bioexcel/biobb_gromacs/solvate/README.md) | Fill the solvent box with water molecules |
| step7_grompp_genion | [biobb_gromacs/grompp](modules/bioexcel/biobb_gromacs/grompp/README.md) | Preprocess ion generation |
| step8_genion | [biobb_gromacs/genion](modules/bioexcel/biobb_gromacs/genion/README.md) | Ion generation |
| step9_grompp_min | [biobb_gromacs/grompp](modules/bioexcel/biobb_gromacs/grompp/README.md) | Preprocess energy minimization |
| step10_mdrun_min | [biobb_gromacs/mdrun](modules/bioexcel/biobb_gromacs/mdrun/README.md) | Execute energy minimization |
| step100_make_ndx | [biobb_gromacs/make_ndx](modules/bioexcel/biobb_gromacs/make_ndx/README.md) | Creating an index file for the whole system |
| step11_grompp_nvt | [biobb_gromacs/grompp](modules/bioexcel/biobb_gromacs/grompp/README.md) | Preprocess system temperature equilibration |
| step12_mdrun_nvt | [biobb_gromacs/mdrun](modules/bioexcel/biobb_gromacs/mdrun/README.md) | Execute system temperature equilibration |
| step13_grompp_npt | [biobb_gromacs/grompp](modules/bioexcel/biobb_gromacs/grompp/README.md) | Preprocess system pressure equilibration |
| step14_mdrun_npt | [biobb_gromacs/mdrun](modules/bioexcel/biobb_gromacs/mdrun/README.md) | Execute system pressure equilibration |
| step15_grompp_md | [biobb_gromacs/grompp](modules/bioexcel/biobb_gromacs/grompp/README.md) | Preprocess free dynamics |
| step16_mdrun_md | [biobb_gromacs/mdrun](modules/bioexcel/biobb_gromacs/mdrun/README.md) | Execute free molecular dynamics simulation |
| step17_gmx_image1 | [biobb_analysis/gmx_image](modules/bioexcel/biobb_analysis/gmx_image/README.md) | Image Trajectory, step1, moving ligand to center of the water box |
| step18_gmx_image2 | [biobb_analysis/gmx_image](modules/bioexcel/biobb_analysis/gmx_image/README.md) | Image Trajectory, step2, removing rotation |
| step19_gmx_trjconv_str | [biobb_analysis/gmx_trjconv_str](modules/bioexcel/biobb_analysis/gmx_trjconv_str/README.md) | Convert final structure from GRO to PDB |
| step20_gmx_energy | [biobb_analysis/gmx_energy](modules/bioexcel/biobb_analysis/gmx_energy/README.md) | Generate energy plot from minimization/equilibration |
| step21_gmx_rgyr | [biobb_analysis/gmx_rgyr](modules/bioexcel/biobb_analysis/gmx_rgyr/README.md) | Generate Radius of Gyration plot for the resulting setup trajectory from the free md step |
| step22_rmsd_first | [biobb_analysis/gmx_rms](modules/bioexcel/biobb_analysis/gmx_rms/README.md) | Generate RMSd (against 1st snp.) plot for the resulting setup trajectory from the free md step |
| step23_rmsd_exp | [biobb_analysis/gmx_rms](modules/bioexcel/biobb_analysis/gmx_rms/README.md) | Generate RMSd (against exp.) plot for the resulting setup trajectory from the free md step |
| step24_grompp_md | [biobb_gromacs/grompp](modules/bioexcel/biobb_gromacs/grompp/README.md) | Preprocess long MD simulation after setup (only with --run_md) |
