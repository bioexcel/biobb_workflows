#!/usr/bin/env cwl-runner

cwlVersion: v1.2
class: Workflow
label: GROMACS Protein MD Setup with mutations
doc: |-
  This workflow performs the process of setting up a simulation system containing a protein, step by step, using the GROMACS tools of the BioExcel Building Blocks library (biobb). Additionally, users can add mutations to the process.

requirements:
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  mutations_list:  
    type:
      type: array
      items: string
  step0_reduce_remove_hydrogens_input_path: File
  step0_reduce_remove_hydrogens_output_path: string
  step1_extract_molecule_output_molecule_path: string
  step00_cat_pdb_input_structure2: File
  step00_cat_pdb_output_structure_path: string
  step2_fix_side_chain_output_pdb_path: string
  step3_mutate_output_pdb_path: string
  step4_pdb2gmx_config: string
  step4_pdb2gmx_output_gro_path: string
  step4_pdb2gmx_output_top_zip_path: string
  step5_editconf_config: string
  step5_editconf_output_gro_path: string
  step6_solvate_output_gro_path: string
  step6_solvate_output_top_zip_path: string
  step7_grompp_genion_config: string
  step7_grompp_genion_output_tpr_path: string
  step8_genion_config: string
  step8_genion_output_gro_path: string
  step8_genion_output_top_zip_path: string
  step9_grompp_min_config: string
  step9_grompp_min_output_tpr_path: string
  step10_mdrun_min_output_trr_path: string
  step10_mdrun_min_output_gro_path: string
  step10_mdrun_min_output_edr_path: string
  step10_mdrun_min_output_log_path: string
  step100_make_ndx_config: string
  step100_make_ndx_output_ndx_path: string
  step11_grompp_nvt_config: string
  step11_grompp_nvt_output_tpr_path: string
  step12_mdrun_nvt_output_trr_path: string
  step12_mdrun_nvt_output_gro_path: string
  step12_mdrun_nvt_output_edr_path: string
  step12_mdrun_nvt_output_log_path: string
  step12_mdrun_nvt_output_cpt_path: string
  step13_grompp_npt_config: string
  step13_grompp_npt_output_tpr_path: string
  step14_mdrun_npt_output_trr_path: string
  step14_mdrun_npt_output_gro_path: string
  step14_mdrun_npt_output_edr_path: string
  step14_mdrun_npt_output_log_path: string
  step14_mdrun_npt_output_cpt_path: string
  step15_grompp_md_config: string
  step15_grompp_md_output_tpr_path: string
  step16_mdrun_md_output_trr_path: string
  step16_mdrun_md_output_gro_path: string
  step16_mdrun_md_output_edr_path: string
  step16_mdrun_md_output_log_path: string
  step16_mdrun_md_output_cpt_path: string
  step17_gmx_image1_config: string
  step17_gmx_image1_output_traj_path: string
  step18_gmx_image2_config: string
  step18_gmx_image2_output_traj_path: string
  step19_gmx_trjconv_str_config: string
  step19_gmx_trjconv_str_output_str_path: string
  step20_gmx_energy_config: string
  step20_gmx_energy_output_xvg_path: string
  step21_gmx_rgyr_config: string
  step21_gmx_rgyr_output_xvg_path: string
  step22_rmsd_first_config: string
  step22_rmsd_first_output_xvg_path: string
  step23_rmsd_exp_config: string
  step23_rmsd_exp_output_xvg_path: string
  step24_grompp_md_config: string
  step24_grompp_md_output_tpr_path: string
  
outputs:
  top_dir:
    label: Collected Simulation Data
    doc: |
      Assorted data files output by the workflow
    type:
      type: array
      items: Directory
    outputSource: subworkflow_mutate/outdir

steps:

  step0_reduce_remove_hydrogens:
    label: ReduceRemoveHydrogens
    doc: |-
      Removes hydrogen atoms to small molecules.
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_chemistry/reduce_remove_hydrogens.cwl
    in:
      input_path: step0_reduce_remove_hydrogens_input_path
      output_path: step0_reduce_remove_hydrogens_output_path
    out:
    - output_path

  step1_extract_molecule:
    label: ExtractMolecule
    doc: |-
      This class is a wrapper of the Structure Checking tool to extract a molecule from a 3D structure.
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_structure_utils/extract_molecule.cwl
    in:
      input_structure_path: step0_reduce_remove_hydrogens/output_path
      output_molecule_path: step1_extract_molecule_output_molecule_path
    out:
      - output_molecule_path

  step00_cat_pdb:
    label: CatPDB
    doc: |-
      Class to concat two PDB structures in a single PDB file.
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_structure_utils/cat_pdb.cwl
    in:
      input_structure1: step1_extract_molecule/output_molecule_path
      input_structure2: step00_cat_pdb_input_structure2
      output_structure_path: step00_cat_pdb_output_structure_path
    out:
    - output_structure_path

  step2_fix_side_chain:
    label: FixSideChain
    doc: |-
      Reconstructs the missing side chains and heavy atoms of the given PDB file.
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_model/fix_side_chain.cwl
    in:
      input_pdb_path: step00_cat_pdb/output_structure_path
      output_pdb_path: step2_fix_side_chain_output_pdb_path
    out:
      - output_pdb_path

  subworkflow_mutate:
    in:
      step2_output_pdb_path: step2_fix_side_chain/output_pdb_path
      mutation: mutations_list
      step3_mutate_output_pdb_path: step3_mutate_output_pdb_path
      step4_pdb2gmx_config: step4_pdb2gmx_config
      step4_pdb2gmx_output_gro_path: step4_pdb2gmx_output_gro_path
      step4_pdb2gmx_output_top_zip_path: step4_pdb2gmx_output_top_zip_path
      step5_editconf_config: step5_editconf_config
      step5_editconf_output_gro_path: step5_editconf_output_gro_path
      step6_solvate_output_gro_path: step6_solvate_output_gro_path
      step6_solvate_output_top_zip_path: step6_solvate_output_top_zip_path
      step7_grompp_genion_config: step7_grompp_genion_config
      step7_grompp_genion_output_tpr_path: step7_grompp_genion_output_tpr_path
      step8_genion_config: step8_genion_config
      step8_genion_output_gro_path: step8_genion_output_gro_path
      step8_genion_output_top_zip_path: step8_genion_output_top_zip_path
      step9_grompp_min_config: step9_grompp_min_config
      step9_grompp_min_output_tpr_path: step9_grompp_min_output_tpr_path
      step10_mdrun_min_output_trr_path: step10_mdrun_min_output_trr_path
      step10_mdrun_min_output_gro_path: step10_mdrun_min_output_gro_path
      step10_mdrun_min_output_edr_path: step10_mdrun_min_output_edr_path
      step10_mdrun_min_output_log_path: step10_mdrun_min_output_log_path
      step100_make_ndx_config: step100_make_ndx_config
      step100_make_ndx_output_ndx_path: step100_make_ndx_output_ndx_path
      step11_grompp_nvt_config: step11_grompp_nvt_config
      step11_grompp_nvt_output_tpr_path: step11_grompp_nvt_output_tpr_path
      step12_mdrun_nvt_output_trr_path: step12_mdrun_nvt_output_trr_path
      step12_mdrun_nvt_output_gro_path: step12_mdrun_nvt_output_gro_path
      step12_mdrun_nvt_output_edr_path: step12_mdrun_nvt_output_edr_path
      step12_mdrun_nvt_output_log_path: step12_mdrun_nvt_output_log_path
      step12_mdrun_nvt_output_cpt_path: step12_mdrun_nvt_output_cpt_path
      step13_grompp_npt_config: step13_grompp_npt_config
      step13_grompp_npt_output_tpr_path: step13_grompp_npt_output_tpr_path
      step14_mdrun_npt_output_trr_path: step14_mdrun_npt_output_trr_path
      step14_mdrun_npt_output_gro_path: step14_mdrun_npt_output_gro_path
      step14_mdrun_npt_output_edr_path: step14_mdrun_npt_output_edr_path
      step14_mdrun_npt_output_log_path: step14_mdrun_npt_output_log_path
      step14_mdrun_npt_output_cpt_path: step14_mdrun_npt_output_cpt_path
      step15_grompp_md_config: step15_grompp_md_config
      step15_grompp_md_output_tpr_path: step15_grompp_md_output_tpr_path
      step16_mdrun_md_output_trr_path: step16_mdrun_md_output_trr_path
      step16_mdrun_md_output_gro_path: step16_mdrun_md_output_gro_path
      step16_mdrun_md_output_edr_path: step16_mdrun_md_output_edr_path
      step16_mdrun_md_output_log_path: step16_mdrun_md_output_log_path
      step16_mdrun_md_output_cpt_path: step16_mdrun_md_output_cpt_path
      step17_gmx_image1_config: step17_gmx_image1_config
      step17_gmx_image1_output_traj_path: step17_gmx_image1_output_traj_path
      step18_gmx_image2_config: step18_gmx_image2_config
      step18_gmx_image2_output_traj_path: step18_gmx_image2_output_traj_path
      step19_gmx_trjconv_str_config: step19_gmx_trjconv_str_config
      step19_gmx_trjconv_str_output_str_path: step19_gmx_trjconv_str_output_str_path
      step20_gmx_energy_config: step20_gmx_energy_config
      step20_gmx_energy_output_xvg_path: step20_gmx_energy_output_xvg_path
      step21_gmx_rgyr_config: step21_gmx_rgyr_config
      step21_gmx_rgyr_output_xvg_path: step21_gmx_rgyr_output_xvg_path
      step22_rmsd_first_config: step22_rmsd_first_config
      step22_rmsd_first_output_xvg_path: step22_rmsd_first_output_xvg_path
      step23_rmsd_exp_config: step23_rmsd_exp_config
      step23_rmsd_exp_output_xvg_path: step23_rmsd_exp_output_xvg_path
      step24_grompp_md_config: step24_grompp_md_config
      step24_grompp_md_output_tpr_path: step24_grompp_md_output_tpr_path

    out: [outdir]

    scatter: mutation
    run:
      class: Workflow
      inputs:
        step2_output_pdb_path: File
        mutation: string
        step3_mutate_output_pdb_path: string
        step4_pdb2gmx_config: string
        step4_pdb2gmx_output_gro_path: string
        step4_pdb2gmx_output_top_zip_path: string
        step5_editconf_config: string
        step5_editconf_output_gro_path: string
        step6_solvate_output_gro_path: string  
        step6_solvate_output_top_zip_path: string
        step7_grompp_genion_config: string
        step7_grompp_genion_output_tpr_path: string
        step8_genion_config: string
        step8_genion_output_gro_path: string
        step8_genion_output_top_zip_path: string
        step9_grompp_min_config: string
        step9_grompp_min_output_tpr_path: string
        step10_mdrun_min_output_trr_path: string
        step10_mdrun_min_output_gro_path: string
        step10_mdrun_min_output_edr_path: string
        step10_mdrun_min_output_log_path: string
        step100_make_ndx_config: string
        step100_make_ndx_output_ndx_path: string
        step11_grompp_nvt_config: string
        step11_grompp_nvt_output_tpr_path: string
        step12_mdrun_nvt_output_trr_path: string
        step12_mdrun_nvt_output_gro_path: string
        step12_mdrun_nvt_output_edr_path: string
        step12_mdrun_nvt_output_log_path: string
        step12_mdrun_nvt_output_cpt_path: string
        step13_grompp_npt_config: string
        step13_grompp_npt_output_tpr_path: string
        step14_mdrun_npt_output_trr_path: string
        step14_mdrun_npt_output_gro_path: string
        step14_mdrun_npt_output_edr_path: string
        step14_mdrun_npt_output_log_path: string
        step14_mdrun_npt_output_cpt_path: string
        step15_grompp_md_config: string
        step15_grompp_md_output_tpr_path: string
        step16_mdrun_md_output_trr_path: string
        step16_mdrun_md_output_gro_path: string
        step16_mdrun_md_output_edr_path: string
        step16_mdrun_md_output_log_path: string
        step16_mdrun_md_output_cpt_path: string
        step17_gmx_image1_config: string
        step17_gmx_image1_output_traj_path: string
        step18_gmx_image2_config: string
        step18_gmx_image2_output_traj_path: string
        step19_gmx_trjconv_str_config: string
        step19_gmx_trjconv_str_output_str_path: string
        step20_gmx_energy_config: string
        step20_gmx_energy_output_xvg_path: string
        step21_gmx_rgyr_config: string
        step21_gmx_rgyr_output_xvg_path: string
        step22_rmsd_first_config: string
        step22_rmsd_first_output_xvg_path: string
        step23_rmsd_exp_config: string
        step23_rmsd_exp_output_xvg_path: string
        step24_grompp_md_config: string
        step24_grompp_md_output_tpr_path: string

      outputs:
        outdir:
          label: Simulation Data
          type: Directory
          outputSource: launch_workflow/dir

      steps:

        step3_mutate:
          label: Mutate
          doc: |-
            Creates a compressed (ZIP) GROMACS topology (TOP and ITP files) from a given PDB file.
          run:   /path/to/biobb_adapters/biobb_adapters/cwl/biobb_model/mutate.cwl
          in:
            config: mutation
            input_pdb_path: step2_output_pdb_path
            output_pdb_path: step3_mutate_output_pdb_path
          out: 
            - output_pdb_path

        launch_workflow:
          run: workflow_list.cwl
          in:
            mut: mutation
            step3_mutate_output_pdb_path:
              source:
                - step3_mutate/output_pdb_path
              pickValue: first_non_null
            step4_pdb2gmx_config: step4_pdb2gmx_config
            step4_pdb2gmx_output_gro_path: step4_pdb2gmx_output_gro_path
            step4_pdb2gmx_output_top_zip_path: step4_pdb2gmx_output_top_zip_path
            step5_editconf_config: step5_editconf_config
            step5_editconf_output_gro_path: step5_editconf_output_gro_path
            step6_solvate_output_gro_path: step6_solvate_output_gro_path
            step6_solvate_output_top_zip_path: step6_solvate_output_top_zip_path
            step7_grompp_genion_config: step7_grompp_genion_config
            step7_grompp_genion_output_tpr_path: step7_grompp_genion_output_tpr_path
            step8_genion_config: step8_genion_config
            step8_genion_output_gro_path: step8_genion_output_gro_path
            step8_genion_output_top_zip_path: step8_genion_output_top_zip_path
            step9_grompp_min_config: step9_grompp_min_config
            step9_grompp_min_output_tpr_path: step9_grompp_min_output_tpr_path
            step10_mdrun_min_output_trr_path: step10_mdrun_min_output_trr_path
            step10_mdrun_min_output_gro_path: step10_mdrun_min_output_gro_path
            step10_mdrun_min_output_edr_path: step10_mdrun_min_output_edr_path
            step10_mdrun_min_output_log_path: step10_mdrun_min_output_log_path
            step100_make_ndx_config: step100_make_ndx_config
            step100_make_ndx_output_ndx_path: step100_make_ndx_output_ndx_path
            step11_grompp_nvt_config: step11_grompp_nvt_config
            step11_grompp_nvt_output_tpr_path: step11_grompp_nvt_output_tpr_path
            step12_mdrun_nvt_output_trr_path: step12_mdrun_nvt_output_trr_path
            step12_mdrun_nvt_output_gro_path: step12_mdrun_nvt_output_gro_path
            step12_mdrun_nvt_output_edr_path: step12_mdrun_nvt_output_edr_path
            step12_mdrun_nvt_output_log_path: step12_mdrun_nvt_output_log_path
            step12_mdrun_nvt_output_cpt_path: step12_mdrun_nvt_output_cpt_path
            step13_grompp_npt_config: step13_grompp_npt_config
            step13_grompp_npt_output_tpr_path: step13_grompp_npt_output_tpr_path
            step14_mdrun_npt_output_trr_path: step14_mdrun_npt_output_trr_path
            step14_mdrun_npt_output_gro_path: step14_mdrun_npt_output_gro_path
            step14_mdrun_npt_output_edr_path: step14_mdrun_npt_output_edr_path
            step14_mdrun_npt_output_log_path: step14_mdrun_npt_output_log_path
            step14_mdrun_npt_output_cpt_path: step14_mdrun_npt_output_cpt_path
            step15_grompp_md_config: step15_grompp_md_config
            step15_grompp_md_output_tpr_path: step15_grompp_md_output_tpr_path
            step16_mdrun_md_output_trr_path: step16_mdrun_md_output_trr_path
            step16_mdrun_md_output_gro_path: step16_mdrun_md_output_gro_path
            step16_mdrun_md_output_edr_path: step16_mdrun_md_output_edr_path
            step16_mdrun_md_output_log_path: step16_mdrun_md_output_log_path
            step16_mdrun_md_output_cpt_path: step16_mdrun_md_output_cpt_path
            step17_gmx_image1_config: step17_gmx_image1_config
            step17_gmx_image1_output_traj_path: step17_gmx_image1_output_traj_path
            step18_gmx_image2_config: step18_gmx_image2_config
            step18_gmx_image2_output_traj_path: step18_gmx_image2_output_traj_path
            step19_gmx_trjconv_str_config: step19_gmx_trjconv_str_config
            step19_gmx_trjconv_str_output_str_path: step19_gmx_trjconv_str_output_str_path
            step20_gmx_energy_config: step20_gmx_energy_config
            step20_gmx_energy_output_xvg_path: step20_gmx_energy_output_xvg_path
            step21_gmx_rgyr_config: step21_gmx_rgyr_config
            step21_gmx_rgyr_output_xvg_path: step21_gmx_rgyr_output_xvg_path
            step22_rmsd_first_config: step22_rmsd_first_config
            step22_rmsd_first_output_xvg_path: step22_rmsd_first_output_xvg_path
            step23_rmsd_exp_config: step23_rmsd_exp_config
            step23_rmsd_exp_output_xvg_path: step23_rmsd_exp_output_xvg_path
            step24_grompp_md_config: step24_grompp_md_config
            step24_grompp_md_output_tpr_path: step24_grompp_md_output_tpr_path

          out: [dir]



