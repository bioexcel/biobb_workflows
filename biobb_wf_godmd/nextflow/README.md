# Protein conformational transitions calculations tutorial using BioExcel Building Blocks (biobb) and GOdMD: Nextflow

Nextflow version of the [python workflow](../python/workflow.py), with the [BioBB Nextflow modules](https://github.com/bioexcel/biobb_adapters/tree/master/biobb_adapters/nextflow) it uses copied in `modules/`. Every step runs the BioBB block inside its biocontainer (or bioconda package) with the properties of [python/workflow.yml](../python/workflow.yml).

Ported by hand: utils_biobb `nextflow_wf_generator.py` can't translate the python logic of `workflow.py`, where step2 and step3 only run when their `molecules` property is not empty. Running the generator on it only refreshes the modules.

## Run

From a clone of this repository, with [Nextflow](https://www.nextflow.io/docs/latest/install.html) >=25.10.0 and Docker:

```bash
nextflow run biobb_wf_godmd/nextflow -profile docker
```

Profiles: `docker`, `apptainer`, `singularity` and `conda`. Results are written to `results/<id>/<step>/` (`-output-dir` to change it), with files named `<id>_<step>_<role>.<ext>`.

## Inputs

`samplesheet.csv` (`--input`): one row per system, all of them run in parallel. Paths are absolute or relative to the samplesheet folder. The default samplesheet runs the inputs of the python workflow.

| Column | Python workflow input | Used by |
|---|---|---|
| `id` | | Name of the run, prefix of the output files |
| `origin` | `origin.pdb` | step0_extract_chain |
| `target` | `target.pdb` | step1_extract_chain |

Parameters (lists: give them in a `-params-file`):

| Parameter | Default | Description |
|---|---|---|
| `step2_molecules` | `[[name: 'AP5']]` | `molecules` property of step2_remove_molecules (origin). Empty: step2 is skipped and step4/step5 take the step0 chains |
| `step3_molecules` | `[]` | `molecules` property of step3_remove_molecules (target). Empty: step3 is skipped and step4/step5 take the step1 chains |

For example, `-params-file molecules.yml` with:

```yaml
step2_molecules: [{name: AP5}]
step3_molecules: [{name: HOH}]
```

## Configuration

`nextflow.config` has the BioBB properties (`ext.properties`) and output extensions (`ext.outputs`) of every step. Change them there or in a config file given with `-c`.

## Steps

| Step | Block | Description |
|---|---|---|
| step0_extract_chain | [biobb_structure_utils/extract_chain](modules/bioexcel/biobb_structure_utils/extract_chain/README.md) | Extracting the interesting chains from the origin structure |
| step1_extract_chain | [biobb_structure_utils/extract_chain](modules/bioexcel/biobb_structure_utils/extract_chain/README.md) | Extracting the interesting chains from the target structure |
| step2_remove_molecules | [biobb_structure_utils/remove_molecules](modules/bioexcel/biobb_structure_utils/remove_molecules/README.md) | Removing the inhibitor from the closed conformation (origin), only with `step2_molecules` |
| step3_remove_molecules | [biobb_structure_utils/remove_molecules](modules/bioexcel/biobb_structure_utils/remove_molecules/README.md) | Removing the inhibitor from the closed conformation (target), only with `step3_molecules` |
| step4_godmd_prep | [biobb_godmd/godmd_prep](modules/bioexcel/biobb_godmd/godmd_prep/README.md) | Computing the mapping |
| step5_godmd_run | [biobb_godmd/godmd_run](modules/bioexcel/biobb_godmd/godmd_run/README.md) | Running GOdMD |
| step6_cpptraj_convert | [biobb_analysis/cpptraj_convert](modules/bioexcel/biobb_analysis/cpptraj_convert/README.md) | Converting trajectory to DCD  |
