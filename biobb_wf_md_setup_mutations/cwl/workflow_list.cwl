#!/usr/bin/env cwl-runner

cwlVersion: v1.2
class: Workflow

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  mut: string
  step3_mutate_output_pdb_path:
    type: File
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
  dir:
    label: Whole workflow output
    type: Directory
    outputSource: step25_gather_outputs/project_work_dir

steps:
  step4_pdb2gmx:
    label: Pdb2gmx
    doc: |-
      Creates a compressed (ZIP) GROMACS topology (TOP and ITP files) from a given PDB file.
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_md/pdb2gmx.cwl
    in:
      config: step4_pdb2gmx_config
      input_pdb_path: step3_mutate_output_pdb_path
      output_gro_path: step4_pdb2gmx_output_gro_path
      output_top_zip_path: step4_pdb2gmx_output_top_zip_path
    out:
    - output_gro_path
    - output_top_zip_path

  step5_editconf:
    label: Editconf
    doc: |-
      Creates a GROMACS structure file (GRO) adding the information of the solvent box to the input structure file.
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_md/editconf.cwl
    in:
      config: step5_editconf_config
      input_gro_path: step4_pdb2gmx/output_gro_path
      output_gro_path: step5_editconf_output_gro_path
    out:
    - output_gro_path

  step6_solvate:
    label: Solvate
    doc: |-
      Creates a new compressed GROMACS topology file adding solvent molecules to a given input compressed GROMACS topology file.
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_md/solvate.cwl
    in:
      input_solute_gro_path: step5_editconf/output_gro_path
      output_gro_path: step6_solvate_output_gro_path
      input_top_zip_path: step4_pdb2gmx/output_top_zip_path
      output_top_zip_path: step6_solvate_output_top_zip_path
    out:
    - output_gro_path
    - output_top_zip_path

  step7_grompp_genion:
    label: Grompp
    doc: |-
      Creates a GROMACS portable binary run input file (TPR) applying the desired properties from the input compressed GROMACS topology.
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_md/grompp.cwl
    in:
      config: step7_grompp_genion_config
      input_gro_path: step6_solvate/output_gro_path
      input_top_zip_path: step6_solvate/output_top_zip_path
      output_tpr_path: step7_grompp_genion_output_tpr_path
    out:
    - output_tpr_path

  step8_genion:
    label: Genion
    doc: |-
      Creates a new compressed GROMACS topology adding ions until reaching the desired concentration to the input compressed GROMACS topology. 
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_md/genion.cwl
    in:
      config: step8_genion_config
      input_tpr_path: step7_grompp_genion/output_tpr_path
      output_gro_path: step8_genion_output_gro_path
      input_top_zip_path: step6_solvate/output_top_zip_path
      output_top_zip_path: step8_genion_output_top_zip_path
    out:
    - output_gro_path
    - output_top_zip_path

  step9_grompp_min:
    label: Grompp
    doc: |-
      Creates a GROMACS portable binary run input file (TPR) applying the desired properties from the input compressed GROMACS topology.
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_md/grompp.cwl
    in:
      config: step9_grompp_min_config
      input_gro_path: step8_genion/output_gro_path
      input_top_zip_path: step8_genion/output_top_zip_path
      output_tpr_path: step9_grompp_min_output_tpr_path
    out:
    - output_tpr_path

  step10_mdrun_min:
    label: Mdrun
    doc: |-
      Performs molecular dynamics simulations from an input GROMACS TPR file.
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_md/mdrun.cwl
    in:
      input_tpr_path: step9_grompp_min/output_tpr_path
      output_trr_path: step10_mdrun_min_output_trr_path
      output_gro_path: step10_mdrun_min_output_gro_path
      output_edr_path: step10_mdrun_min_output_edr_path
      output_log_path: step10_mdrun_min_output_log_path
    out:
    - output_trr_path
    - output_gro_path
    - output_edr_path
    - output_log_path

  step100_make_ndx:
    label: MakeNdx
    doc: |-
      Creates a GROMACS index file (NDX) from an input selection and an input GROMACS structure file.
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_md/make_ndx.cwl
    in:
      config: step100_make_ndx_config
      input_structure_path: step10_mdrun_min/output_gro_path
      output_ndx_path: step100_make_ndx_output_ndx_path
    out:
    - output_ndx_path

  step11_grompp_nvt:
    label: Grompp
    doc: |-
      Creates a GROMACS portable binary run input file (TPR) applying the desired properties from the input compressed GROMACS topology.
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_md/grompp.cwl
    in:
      config: step11_grompp_nvt_config
      input_gro_path: step10_mdrun_min/output_gro_path
      input_ndx_path: step100_make_ndx/output_ndx_path
      input_top_zip_path: step8_genion/output_top_zip_path
      output_tpr_path: step11_grompp_nvt_output_tpr_path
    out:
    - output_tpr_path

  step12_mdrun_nvt:
    label: Mdrun
    doc: |-
      Performs molecular dynamics simulations from an input GROMACS TPR file.
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_md/mdrun.cwl
    in:
      input_tpr_path: step11_grompp_nvt/output_tpr_path
      output_trr_path: step12_mdrun_nvt_output_trr_path
      output_gro_path: step12_mdrun_nvt_output_gro_path
      output_edr_path: step12_mdrun_nvt_output_edr_path
      output_log_path: step12_mdrun_nvt_output_log_path
      output_cpt_path: step12_mdrun_nvt_output_cpt_path
    out:
    - output_trr_path
    - output_gro_path
    - output_edr_path
    - output_log_path
    - output_cpt_path

  step13_grompp_npt:
    label: Grompp
    doc: |-
      Creates a GROMACS portable binary run input file (TPR) applying the desired properties from the input compressed GROMACS topology.
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_md/grompp.cwl
    in:
      config: step13_grompp_npt_config
      input_gro_path: step12_mdrun_nvt/output_gro_path
      input_ndx_path: step100_make_ndx/output_ndx_path
      input_top_zip_path: step8_genion/output_top_zip_path
      output_tpr_path: step13_grompp_npt_output_tpr_path
      input_cpt_path: step12_mdrun_nvt/output_cpt_path
    out:
    - output_tpr_path

  step14_mdrun_npt:
    label: Mdrun
    doc: |-
      Performs molecular dynamics simulations from an input GROMACS TPR file.
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_md/mdrun.cwl
    in:
      input_tpr_path: step13_grompp_npt/output_tpr_path
      output_trr_path: step14_mdrun_npt_output_trr_path
      output_gro_path: step14_mdrun_npt_output_gro_path
      output_edr_path: step14_mdrun_npt_output_edr_path
      output_log_path: step14_mdrun_npt_output_log_path
      output_cpt_path: step14_mdrun_npt_output_cpt_path
    out:
    - output_trr_path
    - output_gro_path
    - output_edr_path
    - output_log_path
    - output_cpt_path

  step15_grompp_md:
    label: Grompp
    doc: |-
      Creates a GROMACS portable binary run input file (TPR) applying the desired properties from the input compressed GROMACS topology.
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_md/grompp.cwl
    in:
      config: step15_grompp_md_config
      input_gro_path: step14_mdrun_npt/output_gro_path
      input_ndx_path: step100_make_ndx/output_ndx_path
      input_top_zip_path: step8_genion/output_top_zip_path
      output_tpr_path: step15_grompp_md_output_tpr_path
      input_cpt_path: step14_mdrun_npt/output_cpt_path
    out:
    - output_tpr_path

  step16_mdrun_md:
    label: Mdrun
    doc: |-
      Performs molecular dynamics simulations from an input GROMACS TPR file.
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_md/mdrun.cwl
    in:
      input_tpr_path: step15_grompp_md/output_tpr_path
      output_trr_path: step16_mdrun_md_output_trr_path
      output_gro_path: step16_mdrun_md_output_gro_path
      output_edr_path: step16_mdrun_md_output_edr_path
      output_log_path: step16_mdrun_md_output_log_path
      output_cpt_path: step16_mdrun_md_output_cpt_path
    out:
    - output_trr_path
    - output_gro_path
    - output_edr_path
    - output_log_path
    - output_cpt_path
    
  step17_gmx_image1:
    label: GMXImage
    doc: |-
      Wrapper of the GROMACS trjconv module for correcting periodicity (image) from a given GROMACS compatible trajectory file.
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_analysis/gmx_image.cwl
    in:
      config: step17_gmx_image1_config
      input_traj_path: step16_mdrun_md/output_trr_path
      input_top_path: step9_grompp_min/output_tpr_path
      input_index_path: step100_make_ndx/output_ndx_path
      output_traj_path: step17_gmx_image1_output_traj_path
    out:
    - output_traj_path

  step18_gmx_image2:
    label: GMXImage
    doc: |-
      Wrapper of the GROMACS trjconv module for correcting periodicity (image) from a given GROMACS compatible trajectory file.
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_analysis/gmx_image.cwl
    in:
      config: step18_gmx_image2_config
      input_traj_path: step17_gmx_image1/output_traj_path
      input_top_path: step9_grompp_min/output_tpr_path
      input_index_path: step100_make_ndx/output_ndx_path
      output_traj_path: step18_gmx_image2_output_traj_path
    out:
    - output_traj_path

  step19_gmx_trjconv_str:
    label: GMXTrjconvStr
    doc: |-
      Wrapper of the GROMACS trjconv module for converting between GROMACS compatible structure file formats and/or extracting a selection of atoms.
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_analysis/gmx_trjconv_str.cwl
    in:
      config: step19_gmx_trjconv_str_config
      input_structure_path: step16_mdrun_md/output_gro_path
      input_top_path: step9_grompp_min/output_tpr_path
      input_index_path: step100_make_ndx/output_ndx_path
      output_str_path: step19_gmx_trjconv_str_output_str_path
    out:
    - output_str_path

  step20_gmx_energy:
    label: GMXEnergy
    doc: |-
      Wrapper of the GROMACS energy module for extracting energy components from a given GROMACS energy file.
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_analysis/gmx_energy.cwl
    in:
      config: step20_gmx_energy_config
      input_energy_path: step16_mdrun_md/output_edr_path
      output_xvg_path: step20_gmx_energy_output_xvg_path
    out:
    - output_xvg_path

  step21_gmx_rgyr:
    label: GMXRgyr
    doc: |-
      Wrapper of the GROMACS gyrate module for computing the radius of gyration (Rgyr) of a molecule about the x-, y- and z-axes, as a function of time, from a given GROMACS compatible trajectory.
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_analysis/gmx_rgyr.cwl
    in:
      config: step21_gmx_rgyr_config
      input_structure_path: step15_grompp_md/output_tpr_path
      input_traj_path: step18_gmx_image2/output_traj_path
      input_index_path: step100_make_ndx/output_ndx_path
      output_xvg_path: step21_gmx_rgyr_output_xvg_path
    out:
    - output_xvg_path

  step22_rmsd_first:
    label: GMXRms
    doc: |-
      Wrapper of the Ambertools GROMACS module for calculating the Root Mean Square deviation (RMSd) of a given GROMACS compatible trajectory.
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_analysis/gmx_rms.cwl
    in:
      config: step22_rmsd_first_config
      input_structure_path: step15_grompp_md/output_tpr_path
      input_traj_path: step18_gmx_image2/output_traj_path
      input_index_path: step100_make_ndx/output_ndx_path
      output_xvg_path: step22_rmsd_first_output_xvg_path
    out:
    - output_xvg_path

  step23_rmsd_exp:
    label: GMXRms
    doc: |-
      Wrapper of the Ambertools GROMACS module for calculating the Root Mean Square deviation (RMSd) of a given GROMACS compatible trajectory.
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_analysis/gmx_rms.cwl
    in:
      config: step23_rmsd_exp_config
      input_structure_path: step9_grompp_min/output_tpr_path
      input_traj_path: step18_gmx_image2/output_traj_path
      input_index_path: step100_make_ndx/output_ndx_path
      output_xvg_path: step23_rmsd_exp_output_xvg_path
    out:
    - output_xvg_path

  step24_grompp_md:
    label: Grompp
    doc: |-
      Creates a GROMACS portable binary run input file (TPR) applying the desired properties from the input compressed GROMACS topology.
    run:  /path/to/biobb_adapters/biobb_adapters/cwl/biobb_md/grompp.cwl
    in:
      config: step24_grompp_md_config
      input_gro_path: step16_mdrun_md/output_gro_path
      input_top_zip_path: step8_genion/output_top_zip_path
      output_tpr_path: step24_grompp_md_output_tpr_path
      input_cpt_path: step16_mdrun_md/output_cpt_path
    out:
    - output_tpr_path

  step25_gather_outputs:
    label: Archiving outputs to be returned to user
    doc: >
      This uses the local workflow_gather.cwl workflow to gather all desired output files.
      A filter for missing files is applied (pickValue: all_non_null), which requires
      using a runner which is compliant with v1.2.0, or later, CWL standards.
    in:
      output_folder: mut
      external_files: 
        source:
          - step8_genion/output_top_zip_path
          - step15_grompp_md/output_tpr_path
          - step16_mdrun_md/output_gro_path
          - step16_mdrun_md/output_cpt_path
          - step18_gmx_image2/output_traj_path
          - step19_gmx_trjconv_str/output_str_path
          - step20_gmx_energy/output_xvg_path
          - step21_gmx_rgyr/output_xvg_path
          - step22_rmsd_first/output_xvg_path
          - step23_rmsd_exp/output_xvg_path
          - step24_grompp_md/output_tpr_path
        linkMerge: merge_flattened
        pickValue: all_non_null
    run: workflow_gather.cwl
    out: [project_work_dir]

  
    









