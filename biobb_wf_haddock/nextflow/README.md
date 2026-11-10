# Protein-protein Docking tutorial using HADDOCK with the BioExcel Building Blocks (biobb): Nextflow

Nextflow version of the [python workflow](../python/workflow.py), with the [BioBB Nextflow modules](https://github.com/bioexcel/biobb_adapters/tree/master/biobb_adapters/nextflow) it uses copied in `modules/`. Every step runs the BioBB block inside its biocontainer (or bioconda package) with the properties of [python/workflow.yml](../python/workflow.yml).

Ported by hand: utils_biobb `nextflow_wf_generator.py` can't translate the python logic of `workflow.py`. That logic is:

* the pipelines of pdb_tools blocks that prepare the structures (step0 and step2 to step8), with loops over the heavy (H) and light (L) chains;
* the zips of their outputs for `biobb_pdb_merge`;
* the inputs of the haddock3 steps made by them.

Here every block of a pipeline is a step `<step>_<n>_PDB_<BLOCK>` of `main.nf` (H and L chains in parallel), and the zips are written by the local `zip` module (`modules/local`, in the biobb_common image). Running the generator on it only refreshes the modules.

## Run

From a clone of this repository, with [Nextflow](https://www.nextflow.io/docs/latest/install.html) >=25.10.0 and Docker:

```bash
nextflow run biobb_wf_haddock/nextflow -profile docker
```

Profiles: `docker`, `apptainer`, `singularity` and `conda`. Results are written to `results/<id>/<step>/` (`-output-dir` to change it), with files named `<id>_<step>_<role>.<ext>`.

## Inputs

`samplesheet.csv` (`--input`): one row per system, all of them run in parallel. Paths are absolute or relative to the samplesheet folder. The default samplesheet runs the inputs of the python workflow.

| Column | Python workflow input | Used by |
|---|---|---|
| `id` | | Name of the run, prefix of the output files |
| `antibody` | `antibody.pdb` | step0_prepare_antibody_reduce |
| `antigen` | `antigen.pdb` | step3_prepare_antigen_clean |
| `complex` | `complex.pdb` | step4_prepare_reference_structure, step7_prepare_complex_antigen_clean |
| `antibody_actpass` | `antibody_actpass.txt` | step10_haddock3_actpass_to_ambig |

## Configuration

`nextflow.config` has the BioBB properties (`ext.properties`) and output extensions (`ext.outputs`) of every step. Change them there or in a config file given with `-c`. The pdb_tools properties of the python pipelines are set per block; `chains` and `selection` (residues 1-120 of H, 1-107 of L) come from the chain loop (`meta.chain`, `meta.residues`). step21 and step23 also write their zips (`output_selection_zip_path`, `output_contactmap_zip_path`).

## Steps

| Step | Block | Description |
|---|---|---|
| step0_prepare_antibody_reduce | [biobb_pdb_tools](modules/bioexcel/biobb_pdb_tools) tidy (strict), selchain, delhetatm, fixinsert, selaltloc, keepcoord, selres, tidy | Select and extract protein regions/chains: H and L chains of `antibody`, and their zip |
| step1_biobb_pdb_merge | [biobb_pdb_tools/biobb_pdb_merge](modules/bioexcel/biobb_pdb_tools/biobb_pdb_merge/README.md) | Merge regions into a single file |
| step2_prepare_antibody_clean | [biobb_pdb_tools](modules/bioexcel/biobb_pdb_tools) reres, chain (A), chainxseg, tidy (strict) | Prepare PDB file to meet HADDOCK3 requirements (antibody of step1) |
| step3_prepare_antigen_clean | [biobb_pdb_tools](modules/bioexcel/biobb_pdb_tools) tidy (strict), delhetatm, selaltloc, keepcoord, chain (B), chainxseg, tidy (strict) | Preparing the antigen structure |
| step4_prepare_reference_structure | [biobb_pdb_tools](modules/bioexcel/biobb_pdb_tools) selchain, delhetatm, fixinsert, selaltloc, keepcoord, selres, tidy | Select and extract protein regions/chains: H and L chains of `complex`, and their zip |
| step5_biobb_pdb_merge | [biobb_pdb_tools/biobb_pdb_merge](modules/bioexcel/biobb_pdb_tools/biobb_pdb_merge/README.md) | Merge Heavy and Light regions (from the complex) into a single file |
| step6_prepare_complex_antibody_clean | [biobb_pdb_tools](modules/bioexcel/biobb_pdb_tools) reres, chain (A), chainxseg, tidy (strict) | Prepare the Antibody PDB file (from the complex) to match HADDOCK3 requirements |
| step7_prepare_complex_antigen_clean | [biobb_pdb_tools](modules/bioexcel/biobb_pdb_tools) reres, chain (A), chainxseg, tidy (strict) | Prepare the Antigen PDB file (from the complex) to match HADDOCK3 requirements, and the zip with the step6 antibody |
| step8_merge_heavy_light_antigen | [biobb_pdb_tools](modules/bioexcel/biobb_pdb_tools) merge, tidy (strict) | Merge Heavy + Light regions and Antigen (from the complex) into a single file: reference of the CAPRI evaluations |
| step9_haddock3_passive_from_active | [biobb_haddock/haddock3_passive_from_active](modules/bioexcel/biobb_haddock/haddock3_passive_from_active/README.md) | Passive restraints |
| step10_haddock3_actpass_to_ambig | [biobb_haddock/haddock3_actpass_to_ambig](modules/bioexcel/biobb_haddock/haddock3_actpass_to_ambig/README.md) | Passive restraints |
| step11_haddock3_restrain_bodies | [biobb_haddock/haddock3_restrain_bodies](modules/bioexcel/biobb_haddock/haddock3_restrain_bodies/README.md) | Passive restraints |
| step12_topology | [biobb_haddock/topology](modules/bioexcel/biobb_haddock/topology/README.md) | Create topology |
| step13_rigid_body | [biobb_haddock/rigid_body](modules/bioexcel/biobb_haddock/rigid_body/README.md) | Rigid body sampling |
| step14_capri_eval1 | [biobb_haddock/capri_eval](modules/bioexcel/biobb_haddock/capri_eval/README.md) | 1st CAPRI evaluation |
| step15_sele_top | [biobb_haddock/sele_top](modules/bioexcel/biobb_haddock/sele_top/README.md) | Select Top structures |
| step16_flex_ref | [biobb_haddock/flex_ref](modules/bioexcel/biobb_haddock/flex_ref/README.md) | Flexible Refinement |
| step17_capri_eval2 | [biobb_haddock/capri_eval](modules/bioexcel/biobb_haddock/capri_eval/README.md) | 2nd CAPRI evaluation |
| step18_em_ref | [biobb_haddock/em_ref](modules/bioexcel/biobb_haddock/em_ref/README.md) | Energy minimization refinement |
| step19_capri_eval3 | [biobb_haddock/capri_eval](modules/bioexcel/biobb_haddock/capri_eval/README.md) | 3rd CAPRI evaluation |
| step20_clust_fcc | [biobb_haddock/clust_fcc](modules/bioexcel/biobb_haddock/clust_fcc/README.md) | Clustering |
| step21_sele_top_clusts | [biobb_haddock/sele_top_clusts](modules/bioexcel/biobb_haddock/sele_top_clusts/README.md) | Clustering |
| step22_capri_eval4 | [biobb_haddock/capri_eval](modules/bioexcel/biobb_haddock/capri_eval/README.md) | Final CAPRI evaluation |
| step23_contact_map | [biobb_haddock/contact_map](modules/bioexcel/biobb_haddock/contact_map/README.md) | Contacts analysis |
