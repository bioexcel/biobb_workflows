# Structural DNA helical parameters from MD trajectory tutorial using BioExcel Building Blocks (biobb): Nextflow

Nextflow version of the [python workflow](../python/workflow.py), with the [BioBB Nextflow modules](https://github.com/bioexcel/biobb_adapters/tree/master/biobb_adapters/nextflow) it uses copied in `modules/`. Every step runs the BioBB block inside its biocontainer (or bioconda package) with the properties of [python/workflow.yml](../python/workflow.yml).

Ported by hand: utils_biobb `nextflow_wf_generator.py` can't translate the python logic of `workflow.py`. That logic is:

* the loops over the helical parameters, whose inputs are files of the Canal zip;
* the loops over the base pairs and base-pair steps, found in the files of the timeseries zips;
* the zips of the outputs of every step.

Here every helical parameter and base pair is a task of its step, all of them run in parallel. The zips are extracted and written by the local `unzip` and `zip` modules (`modules/local`, in the biobb_common image). Running the generator on it only refreshes the modules.

## Run

From a clone of this repository, with [Nextflow](https://www.nextflow.io/docs/latest/install.html) >=25.10.0 and Docker:

```bash
nextflow run biobb_wf_dna_helparms/nextflow -profile docker
```

Profiles: `docker`, `apptainer`, `singularity` and `conda`. Results are written to `results/<id>/<step>/` (`-output-dir` to change it), with files named `<id>_<step>_<role>.<ext>`, or `<id>_<step>_<helpar>_<role>.<ext>`, `<id>_<step>_<pair>_<role>.<ext>` and `<id>_<step>_<helpar>_<pair>_<role>.<ext>` for the steps run per helical parameter and base pair (step). Every step but step1 and step2 also has `<id>_<step>_outputs.zip`, with all its outputs, as the python workflow.

## Inputs

`samplesheet.csv` (`--input`): one row per system, all of them run in parallel. Paths are absolute or relative to the samplesheet folder. The default samplesheet runs the inputs of the python workflow.

| Column | Python workflow input | Used by |
|---|---|---|
| `id` | | Name of the run, prefix of the output files |
| `trajectory` | `trajectory.nc` | step1_biobb_curves |
| `topology` | `topology.top` | step1_biobb_curves |

## Configuration

`nextflow.config` has the BioBB properties (`ext.properties`) and output extensions (`ext.outputs`) of every step. Change them there or in a config file given with `-c`. The `helpar_name` property of the steps run per helical parameter is set from the loop (`meta.helpar`). The `sequence` property (`CGCGAATTCGCG`) is the one of the default input: change it for other systems.

## Steps

Helical parameter lists of the python loops: base-pair step (`rise`, `roll`, `twist`, `shift`, `slide`, `tilt`), base pair (`shear`, `stretch`, `stagger`, `buckle`, `propel`, `opening`), axis base pairs (`inclin`, `tip`, `xdisp`, `ydisp`), grooves (`majd`, `majw`, `mind`, `minw`) and backbone torsions (`alphaC`, `alphaW`, `betaC`, `betaW`, `gammaC`, `gammaW`, `deltaC`, `deltaW`, `epsilC`, `epsilW`, `zetaC`, `zetaW`, `chiC`, `chiW`, `phaseC`, `phaseW`).

| Step | Block | Description |
|---|---|---|
| step1_biobb_curves | [biobb_dna/biobb_curves](modules/bioexcel/biobb_dna/biobb_curves/README.md) | Running Curves+ |
| step2_biobb_canal | [biobb_dna/biobb_canal](modules/bioexcel/biobb_dna/biobb_canal/README.md) | Running Canal. Its zip is extracted (UNZIP_CANAL): the `canal_output_<helpar>.ser` files are the inputs of the next steps |
| step4_dna_averages_base_pair_step | [biobb_dna/dna_averages](modules/bioexcel/biobb_dna/dna_averages/README.md) | Extracting Helical Base Pair Step (Inter Base Pair) Parameters, per base-pair step parameter |
| step5_dna_averages_base_pair | [biobb_dna/dna_averages](modules/bioexcel/biobb_dna/dna_averages/README.md) | Extracting Helical Base Pair (Intra Base Pair) Parameters, per base pair parameter |
| step6_dna_averages_axis_base_pairs | [biobb_dna/dna_averages](modules/bioexcel/biobb_dna/dna_averages/README.md) | Extracting Axis Base Pair Parameters, per axis parameter |
| step7_dna_averages_grooves | [biobb_dna/dna_averages](modules/bioexcel/biobb_dna/dna_averages/README.md) | Extracting Grooves Parameters, per groove parameter |
| step8_puckering | [biobb_dna/puckering](modules/bioexcel/biobb_dna/puckering/README.md) | Sugar Puckering |
| step9_canonicalag | [biobb_dna/canonicalag](modules/bioexcel/biobb_dna/canonicalag/README.md) | Canonical Alpha/Gamma |
| step10_bipopulations | [biobb_dna/bipopulations](modules/bioexcel/biobb_dna/bipopulations/README.md) | BI/BII Population |
| step12_dna_timeseries_base_pair_step | [biobb_dna/dna_timeseries](modules/bioexcel/biobb_dna/dna_timeseries/README.md) | Computing timeseries for all base-pair step parameters, per parameter. The zips are extracted (UNZIP_TIMESERIES) for step18, step19 and step23 |
| step13_dna_timeseries_base_pair | [biobb_dna/dna_timeseries](modules/bioexcel/biobb_dna/dna_timeseries/README.md) | Computing timeseries for all base-pair parameters, per parameter. The zips are extracted (UNZIP_TIMESERIES) for step22 |
| step14_dna_timeseries_axis_base_pairs | [biobb_dna/dna_timeseries](modules/bioexcel/biobb_dna/dna_timeseries/README.md) | Computing timeseries for all axis parameters, per parameter |
| step15_dna_timeseries_grooves | [biobb_dna/dna_timeseries](modules/bioexcel/biobb_dna/dna_timeseries/README.md) | Computing timeseries for all grooves parameters, per parameter |
| step16_dna_timeseries_backbone_torsions | [biobb_dna/dna_timeseries](modules/bioexcel/biobb_dna/dna_timeseries/README.md) | Computing timeseries for all backbone torsions parameters, per parameter |
| step18_basepair_stiffness | [biobb_dna/basepair_stiffness](modules/bioexcel/biobb_dna/basepair_stiffness/README.md) | Computing basepair stiffness, per base-pair step (`series_shift_<pair>.csv` of step12) |
| step19_dna_bimodality | [biobb_dna/dna_bimodality](modules/bioexcel/biobb_dna/dna_bimodality/README.md) | Computing basepair bimodality, per base-pair step and parameter |
| step20_intraseqcorr | [biobb_dna/intraseqcorr](modules/bioexcel/biobb_dna/intraseqcorr/README.md) | Sequence Correlations: Intra-base pairs, per base pair parameter |
| step21_interseqcorr | [biobb_dna/interseqcorr](modules/bioexcel/biobb_dna/interseqcorr/README.md) | Sequence Correlations: Inter-base pair steps, per base-pair step parameter |
| step22_intrahpcorr | [biobb_dna/intrahpcorr](modules/bioexcel/biobb_dna/intrahpcorr/README.md) | Helical Parameter Correlations: Intra-base pair, per base pair (`series_shear_<pair>.csv` of step13) |
| step23_interhpcorr | [biobb_dna/interhpcorr](modules/bioexcel/biobb_dna/interhpcorr/README.md) | Helical Parameter Correlations: Inter-base pair steps, per base-pair step |
| step24_intrabpcorr | [biobb_dna/intrabpcorr](modules/bioexcel/biobb_dna/intrabpcorr/README.md) | Neighboring steps Correlations: Intra-base pair |
| step25_interbpcorr | [biobb_dna/interbpcorr](modules/bioexcel/biobb_dna/interbpcorr/README.md) | Neighboring steps Correlations: Inter-base pair steps |
