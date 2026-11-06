# Protein MD Analysis tutorial using BioExcel Building Blocks (biobb): Nextflow

Nextflow version of the [python workflow](../python/workflow.py), with the [BioBB Nextflow modules](https://github.com/bioexcel/biobb_adapters/tree/master/biobb_adapters/nextflow) it uses copied in `modules/`. Every step runs the BioBB block inside its biocontainer (or bioconda package) with the properties of [python/workflow.yml](../python/workflow.yml).

Ported by hand: utils_biobb `nextflow_wf_generator.py` can't translate the python logic of `workflow.py`, two small processes of `main.nf` that run in the biobb_common image (Python and Biopython). Running the generator on it only refreshes the modules.

## Run

From a clone of this repository, with [Nextflow](https://www.nextflow.io/docs/latest/install.html) >=25.10.0 and Docker:

```bash
nextflow run biobb_wf_protein_md_analysis/nextflow -profile docker
```

Profiles: `docker`, `apptainer`, `singularity` and `conda`. Results are written to `results/<id>/<step>/` (`-output-dir` to change it), with files named `<id>_<step>_<role>.<ext>`.

## Inputs

`samplesheet.csv` (`--input`): one row per system, all of them run in parallel. Paths are absolute or relative to the samplesheet folder. The default samplesheet runs the inputs of the python workflow.

| Column | Python workflow input | Used by |
|---|---|---|
| `id` | | Name of the run, prefix of the output files |
| `topology` | `topology.pdb` | step1_cpptraj_average, step2_cpptraj_rms_first, step3_cpptraj_rms_average, step4_cpptraj_bfactor, step5_cpptraj_rgyr, step6_cpptraj_convert, step7_gmx_cluster |
| `trajectory` | `trajectory.nc` | step1_cpptraj_average, step2_cpptraj_rms_first, step3_cpptraj_rms_average, step4_cpptraj_bfactor, step5_cpptraj_rgyr, step6_cpptraj_convert |

## Configuration

`nextflow.config` has the BioBB properties (`ext.properties`) and output extensions (`ext.outputs`) of every step. Change them there or in a config file given with `-c`.

## Steps

| Step | Block | Description |
|---|---|---|
| step1_cpptraj_average | [biobb_analysis/cpptraj_average](modules/bioexcel/biobb_analysis/cpptraj_average/README.md) | Calculating trajectory structure average |
| step2_cpptraj_rms_first | [biobb_analysis/cpptraj_rms](modules/bioexcel/biobb_analysis/cpptraj_rms/README.md) | Generate RMSd (against 1st snp.) plot for the trajectory |
| step3_cpptraj_rms_average | [biobb_analysis/cpptraj_rms](modules/bioexcel/biobb_analysis/cpptraj_rms/README.md) | Generate RMSd (against all frames) plot for the trajectory |
| step4_cpptraj_bfactor | [biobb_analysis/cpptraj_bfactor](modules/bioexcel/biobb_analysis/cpptraj_bfactor/README.md) | Calculating trajectory Bfactor fluctuations |
| step5_cpptraj_rgyr | [biobb_analysis/cpptraj_rgyr](modules/bioexcel/biobb_analysis/cpptraj_rgyr/README.md) | Generate Radius of Gyration plot for the trajectory |
| step6_cpptraj_convert | [biobb_analysis/cpptraj_convert](modules/bioexcel/biobb_analysis/cpptraj_convert/README.md) | Convert trajectory to GMX compatible format |
| step7_gmx_cluster | [biobb_analysis/gmx_cluster](modules/bioexcel/biobb_analysis/gmx_cluster/README.md) | Clustering structures from the trajectory |

Python logic of `workflow.py`, written in the folder of its step:

| Process | Step folder | Description |
|---|---|---|
| SAVE_BFACTOR | step4_cpptraj_bfactor | B-factor PDB file: the B-factor of every residue (step4 output) on the atoms of the `topology` structure |
| SAVE_CLUSTERS | step7_gmx_cluster | Clusters JSON file: id and population of every cluster of the step7 log |
