# Conformational ensembles generation, data representation and visualization of predicted flexibility properties using BioExcel Building Blocks (biobb) and FlexDyn tools: Nextflow

Nextflow version of the [python workflow](../python/workflow.py), with the [BioBB Nextflow modules](https://github.com/bioexcel/biobb_adapters/tree/master/biobb_adapters/nextflow) it uses copied in `modules/`. Every step runs the BioBB block inside its biocontainer (or bioconda package) with the properties of [python/workflow.yml](../python/workflow.yml).

Ported by hand: utils_biobb `nextflow_wf_generator.py` can't translate the python logic of `workflow.py`, the zip of the five ensembles concatenated by step25_trjcat (ZIP_TRAJECTORIES, the local zip module in `modules/local`, in the biobb_common image). The `CONCOORDLIB` environment variable that `workflow.py` sets for step4 and step5 is left to the biobb_flexdyn container or conda env, which set it. Running the generator on it only refreshes the modules.

## Run

From a clone of this repository, with [Nextflow](https://www.nextflow.io/docs/latest/install.html) >=25.10.0 and Docker:

```bash
nextflow run biobb_wf_flexdyn/nextflow -profile docker
```

Profiles: `docker`, `apptainer`, `singularity` and `conda`. Results are written to `results/<id>/<step>/` (`-output-dir` to change it), with files named `<id>_<step>_<role>.<ext>`.

## Inputs

`samplesheet.csv` (`--input`): one row per system, all of them run in parallel. Paths are absolute or relative to the samplesheet folder. The default samplesheet runs the inputs of the python workflow.

| Column | Python workflow input | Used by |
|---|---|---|
| `id` | | Name of the run, prefix of the output files |
| `structure` | `structure.pdb` | step0_extract_model |

## Configuration

`nextflow.config` has the BioBB properties (`ext.properties`) and output extensions (`ext.outputs`) of every step. Change them there or in a config file given with `-c`.

## Steps

| Step | Block | Description |
|---|---|---|
| step0_extract_model | [biobb_structure_utils/extract_model](modules/bioexcel/biobb_structure_utils/extract_model/README.md) | Selecting a model |
| step1_extract_chain | [biobb_structure_utils/extract_chain](modules/bioexcel/biobb_structure_utils/extract_chain/README.md) | Selecting a monomer |
| step2_cpptraj_mask | [biobb_analysis/cpptraj_mask](modules/bioexcel/biobb_analysis/cpptraj_mask/README.md) | Generating the reduced (coarse-grained) structure (backbone) |
| step3_cpptraj_mask | [biobb_analysis/cpptraj_mask](modules/bioexcel/biobb_analysis/cpptraj_mask/README.md) | Generating the reduced (coarse-grained) structure (alpha carbons) |
| step4_concoord_dist | [biobb_flexdyn/concoord_dist](modules/bioexcel/biobb_flexdyn/concoord_dist/README.md) | CONCOORD dist |
| step5_concoord_disco | [biobb_flexdyn/concoord_disco](modules/bioexcel/biobb_flexdyn/concoord_disco/README.md) | CONCOORD disco |
| step6_cpptraj_rms | [biobb_analysis/cpptraj_rms](modules/bioexcel/biobb_analysis/cpptraj_rms/README.md) | RMSd distribution of the generated ensemble (CONCOORD) |
| step7_cpptraj_convert | [biobb_analysis/cpptraj_convert](modules/bioexcel/biobb_analysis/cpptraj_convert/README.md) | Converting the generated ensemble (CONCOORD) |
| step8_prody_anm | [biobb_flexdyn/prody_anm](modules/bioexcel/biobb_flexdyn/prody_anm/README.md) | PRODY Anisotropic network model |
| step9_cpptraj_rms | [biobb_analysis/cpptraj_rms](modules/bioexcel/biobb_analysis/cpptraj_rms/README.md) | RMSd distribution of the generated ensemble (PRODY) |
| step10_cpptraj_convert | [biobb_analysis/cpptraj_convert](modules/bioexcel/biobb_analysis/cpptraj_convert/README.md) | Converting the generated ensemble (PRODY) |
| step11_bd_run | [biobb_flexserv/bd_run](modules/bioexcel/biobb_flexserv/bd_run/README.md) | Brownian Dynamics (BD) |
| step12_cpptraj_rms | [biobb_analysis/cpptraj_rms](modules/bioexcel/biobb_analysis/cpptraj_rms/README.md) | Fitting and converting the generated ensemble (BD) |
| step13_dmd_run | [biobb_flexserv/dmd_run](modules/bioexcel/biobb_flexserv/dmd_run/README.md) | Discrete Molecular Dynamics (DMD) |
| step14_cpptraj_rms | [biobb_analysis/cpptraj_rms](modules/bioexcel/biobb_analysis/cpptraj_rms/README.md) | RMSd distribution of the generated ensemble (DMD) |
| step15_nma_run | [biobb_flexserv/nma_run](modules/bioexcel/biobb_flexserv/nma_run/README.md) | Normal Mode Analysis (NMA) |
| step16_cpptraj_rms | [biobb_analysis/cpptraj_rms](modules/bioexcel/biobb_analysis/cpptraj_rms/README.md) | RMSd distribution of the generated ensemble (NMA) |
| step17_cpptraj_convert | [biobb_analysis/cpptraj_convert](modules/bioexcel/biobb_analysis/cpptraj_convert/README.md) | Converting the generated ensemble (NMA) |
| step18_nolb_nma | [biobb_flexdyn/nolb_nma](modules/bioexcel/biobb_flexdyn/nolb_nma/README.md) | NOn-Linear rigid Block NMA approach (NOLB) |
| step19_cpptraj_rms | [biobb_analysis/cpptraj_rms](modules/bioexcel/biobb_analysis/cpptraj_rms/README.md) | RMSd distribution of the generated ensemble (NOLB) |
| step20_cpptraj_convert | [biobb_analysis/cpptraj_convert](modules/bioexcel/biobb_analysis/cpptraj_convert/README.md) | Converting the generated ensemble (NOLB) |
| step21_imod_imode | [biobb_flexdyn/imod_imode](modules/bioexcel/biobb_flexdyn/imod_imode/README.md) | iMOD imode |
| step22_imod_imc | [biobb_flexdyn/imod_imc](modules/bioexcel/biobb_flexdyn/imod_imc/README.md) | iMOD imc |
| step23_cpptraj_rms | [biobb_analysis/cpptraj_rms](modules/bioexcel/biobb_analysis/cpptraj_rms/README.md) | RMSd distribution of the generated ensemble (iMOD) |
| step24_cpptraj_convert | [biobb_analysis/cpptraj_convert](modules/bioexcel/biobb_analysis/cpptraj_convert/README.md) | Converting the generated ensemble (iMOD) |
| step25_trjcat | [biobb_gromacs/trjcat](modules/bioexcel/biobb_gromacs/trjcat/README.md) | Building the meta-trajectory, from the zip of the step7, step10, step24, step12 and step17 trajectories (ZIP_TRAJECTORIES, also in this folder) |
| step26_make_ndx | [biobb_gromacs/make_ndx](modules/bioexcel/biobb_gromacs/make_ndx/README.md) | Clustering the meta-trajectory: make index |
| step27_gmx_cluster | [biobb_analysis/gmx_cluster](modules/bioexcel/biobb_analysis/gmx_cluster/README.md) | Clustering the meta-trajectory: clustering |
| step28_cpptraj_rms | [biobb_analysis/cpptraj_rms](modules/bioexcel/biobb_analysis/cpptraj_rms/README.md) | Fitting and converting the generated ensemble (meta-trajectory) |
| step29_pcz_zip | [biobb_flexserv/pcz_zip](modules/bioexcel/biobb_flexserv/pcz_zip/README.md) | Computing the Principal Component Analysis (PCA) - ensemble |
| step30_pcz_zip | [biobb_flexserv/pcz_zip](modules/bioexcel/biobb_flexserv/pcz_zip/README.md) | Computing the Principal Component Analysis (PCA) - ensemble gaussian |
| step31_pcz_info | [biobb_flexserv/pcz_info](modules/bioexcel/biobb_flexserv/pcz_info/README.md) | Analysing the PCA report |
| step32_pcz_evecs | [biobb_flexserv/pcz_evecs](modules/bioexcel/biobb_flexserv/pcz_evecs/README.md) | PCA Eigenvectors & Eigenvalues |
| step33_pcz_animate | [biobb_flexserv/pcz_animate](modules/bioexcel/biobb_flexserv/pcz_animate/README.md) | Animate Principal Components |
| step34_cpptraj_convert | [biobb_analysis/cpptraj_convert](modules/bioexcel/biobb_analysis/cpptraj_convert/README.md) | Converting the generated ensemble (PCA) |
| step35_pcz_bfactor | [biobb_flexserv/pcz_bfactor](modules/bioexcel/biobb_flexserv/pcz_bfactor/README.md) | B-Factor x Principal Components |
| step36_pcz_hinges | [biobb_flexserv/pcz_hinges](modules/bioexcel/biobb_flexserv/pcz_hinges/README.md) | Hinge Points Prediction - Bfactor_slope |
| step37_pcz_hinges | [biobb_flexserv/pcz_hinges](modules/bioexcel/biobb_flexserv/pcz_hinges/README.md) | Hinge Points Prediction - Dynamic_domain |
| step38_pcz_hinges | [biobb_flexserv/pcz_hinges](modules/bioexcel/biobb_flexserv/pcz_hinges/README.md) | Hinge Points Prediction - Force_constant |
| step39_pcz_stiffness | [biobb_flexserv/pcz_stiffness](modules/bioexcel/biobb_flexserv/pcz_stiffness/README.md) | Apparent Stiffness |
| step40_pcz_collectivity | [biobb_flexserv/pcz_collectivity](modules/bioexcel/biobb_flexserv/pcz_collectivity/README.md) | Collectivity Index |
