#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
label: Conformational ensembles generation
doc: |-
  This tutorial aims to illustrate the process of generating protein conformational ensembles from 3D structures and analysing its molecular flexibility
inputs:
  step0_extract_model_input_structure_path:
    label: Input file
    doc: Input structure file path.
    type: File
  step0_extract_model_output_structure_path:
    label: Output file
    doc: Output structure file path.
    type: string
  step0_extract_model_config:
    label: Config file
    doc: Configuration file for biobb_structure_utils.extract_model tool.
    type: string
  step1_extract_chain_output_structure_path:
    label: Output file
    doc: Output structure file path.
    type: string
  step1_extract_chain_config:
    label: Config file
    doc: Configuration file for biobb_structure_utils.extract_chain tool.
    type: string
  step2_cpptraj_mask_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed trajectory.
    type: string
  step2_cpptraj_mask_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_mask tool.
    type: string
  step3_cpptraj_mask_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed trajectory.
    type: string
  step3_cpptraj_mask_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_mask tool.
    type: string
  
  # INIT COMMENT IN CASE OF EXECUTION WITH MAC ARM
  step4_concoord_dist_output_pdb_path:
    label: Output file
    doc: Output pdb file.
    type: string
  step4_concoord_dist_output_gro_path:
    label: Output file
    doc: Output gro file.
    type: string
  step4_concoord_dist_output_dat_path:
    label: Output file
    doc: Output dat with structure interpretation and bond definitions.
    type: string
  step4_concoord_dist_config:
    label: Config file
    doc: Configuration file for biobb_flexdyn.concoord_dist tool.
    type: string
  step5_concoord_disco_output_traj_path:
    label: Output file
    doc: Output trajectory file.
    type: string
  step5_concoord_disco_output_rmsd_path:
    label: Output file
    doc: Output rmsd file.
    type: string
  step5_concoord_disco_output_bfactor_path:
    label: Output file
    doc: Output B-factor file.
    type: string
  step5_concoord_disco_config:
    label: Config file
    doc: Configuration file for biobb_flexdyn.concoord_disco tool.
    type: string
  step6_cpptraj_rms_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed analysis.
    type: string
  step6_cpptraj_rms_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_rms tool.
    type: string
  step7_cpptraj_convert_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed trajectory.
    type: string
  step7_cpptraj_convert_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_convert tool.
    type: string
  # END COMMENT IN CASE OF EXECUTION WITH MAC ARM

  step8_prody_anm_output_pdb_path:
    label: Output file
    doc: Output multi-model PDB file with the generated ensemble.
    type: string
  step8_prody_anm_config:
    label: Config file
    doc: Configuration file for biobb_flexdyn.prody_anm tool.
    type: string
  step9_cpptraj_rms_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed analysis.
    type: string
  step9_cpptraj_rms_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_rms tool.
    type: string
  step10_cpptraj_convert_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed trajectory.
    type: string
  step10_cpptraj_convert_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_convert tool.
    type: string
  step11_bd_run_output_crd_path:
    label: Output file
    doc: Output ensemble.
    type: string
  step11_bd_run_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step11_bd_run_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.bd_run tool.
    type: string
  step12_cpptraj_rms_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed analysis.
    type: string
  step12_cpptraj_rms_output_traj_path:
    label: Output file
    doc: Path to the output processed trajectory.
    type: string
  step12_cpptraj_rms_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_rms tool.
    type: string
  step13_dmd_run_output_crd_path:
    label: Output file
    doc: Output ensemble.
    type: string
  step13_dmd_run_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step13_dmd_run_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.dmd_run tool.
    type: string
  step14_cpptraj_rms_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed analysis.
    type: string
  step14_cpptraj_rms_output_traj_path:
    label: Output file
    doc: Path to the output processed trajectory.
    type: string
  step14_cpptraj_rms_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_rms tool.
    type: string
  step15_nma_run_output_crd_path:
    label: Output file
    doc: Output ensemble.
    type: string
  step15_nma_run_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step15_nma_run_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.nma_run tool.
    type: string
  step16_cpptraj_rms_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed analysis.
    type: string
  step16_cpptraj_rms_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_rms tool.
    type: string
  step17_cpptraj_convert_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed trajectory.
    type: string
  step17_cpptraj_convert_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_convert tool.
    type: string
  step18_nolb_nma_output_pdb_path:
    label: Output file
    doc: Output multi-model PDB file with the generated ensemble.
    type: string
  step18_nolb_nma_config:
    label: Config file
    doc: Configuration file for biobb_flexdyn.nolb_nma tool.
    type: string
  step19_cpptraj_rms_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed analysis.
    type: string
  step19_cpptraj_rms_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_rms tool.
    type: string
  step20_cpptraj_convert_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed trajectory.
    type: string
  step20_cpptraj_convert_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_convert tool.
    type: string
  step21_imod_imode_output_dat_path:
    label: Output file
    doc: Output dat with normal modes.
    type: string
  step21_imod_imode_config:
    label: Config file
    doc: Configuration file for biobb_flexdyn.imod_imode tool.
    type: string
  step22_imod_imc_output_traj_path:
    label: Output file
    doc: Output multi-model PDB file with the generated ensemble.
    type: string
  step22_imod_imc_config:
    label: Config file
    doc: Configuration file for biobb_flexdyn.imod_imc tool.
    type: string
  step23_cpptraj_rms_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed analysis.
    type: string
  step23_cpptraj_rms_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_rms tool.
    type: string
  step24_cpptraj_convert_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed trajectory.
    type: string
  step24_cpptraj_convert_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_convert tool.
    type: string
  step26_make_ndx_output_ndx_path:
    label: Output file
    doc: Path to the output index NDX file.
    type: string
  step26_make_ndx_config:
    label: Config file
    doc: Configuration file for biobb_gromacs.make_ndx tool.
    type: string
  step27_gmx_cluster_output_pdb_path:
    label: Output file
    doc: Path to the output cluster file.
    type: string
  step27_gmx_cluster_config:
    label: Config file
    doc: Configuration file for biobb_analysis.gmx_cluster tool.
    type: string
  step28_cpptraj_rms_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed analysis.
    type: string
  step28_cpptraj_rms_output_traj_path:
    label: Output file
    doc: Path to the output processed trajectory.
    type: string
  step28_cpptraj_rms_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_rms tool.
    type: string
  step29_pcz_zip_output_pcz_path:
    label: Output file
    doc: Output compressed trajectory.
    type: string
  step29_pcz_zip_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.pcz_zip tool.
    type: string
  step30_pcz_zip_output_pcz_path:
    label: Output file
    doc: Output compressed trajectory.
    type: string
  step30_pcz_zip_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.pcz_zip tool.
    type: string
  step31_pcz_info_output_json_path:
    label: Output file
    doc: Output json file with PCA info such as number of components, variance and dimensionality.
    type: string
  step32_pcz_evecs_output_json_path:
    label: Output file
    doc: Output json file with PCA Eigen Vectors.
    type: string
  step32_pcz_evecs_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.pcz_evecs tool.
    type: string
  step33_pcz_animate_output_crd_path:
    label: Output file
    doc: Output PCA animated trajectory file.
    type: string
  step33_pcz_animate_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.pcz_animate tool.
    type: string
  step34_cpptraj_convert_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed trajectory.
    type: string
  step34_cpptraj_convert_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_convert tool.
    type: string
  step35_pcz_bfactor_output_dat_path:
    label: Output file
    doc: Output Bfactor x residue x PCA mode file.
    type: string
  step35_pcz_bfactor_output_pdb_path:
    label: Output file
    doc: Output PDB with Bfactor x residue x PCA mode file.
    type: string
  step35_pcz_bfactor_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.pcz_bfactor tool.
    type: string
  step36_pcz_hinges_output_json_path:
    label: Output file
    doc: Output hinge regions x PCA mode file.
    type: string
  step36_pcz_hinges_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.pcz_hinges tool.
    type: string
  step37_pcz_hinges_output_json_path:
    label: Output file
    doc: Output hinge regions x PCA mode file.
    type: string
  step37_pcz_hinges_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.pcz_hinges tool.
    type: string
  step38_pcz_hinges_output_json_path:
    label: Output file
    doc: Output hinge regions x PCA mode file.
    type: string
  step38_pcz_hinges_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.pcz_hinges tool.
    type: string
  step39_pcz_stiffness_output_json_path:
    label: Output file
    doc: Output json file with PCA Stiffness.
    type: string
  step39_pcz_stiffness_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.pcz_stiffness tool.
    type: string
  step40_pcz_collectivity_output_json_path:
    label: Output file
    doc: Output json file with PCA Collectivity indexes per mode.
    type: string
  step40_pcz_collectivity_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.pcz_collectivity tool.
    type: string
outputs:
  step0_extract_model_out1:
    label: output_structure_path
    doc: Output structure file path.
    type: File
    outputSource: step0_extract_model/output_structure_path
  step1_extract_chain_out1:
    label: output_structure_path
    doc: Output structure file path.
    type: File
    outputSource: step1_extract_chain/output_structure_path
  step2_cpptraj_mask_out1:
    label: output_cpptraj_path
    doc: Path to the output processed trajectory.
    type: File
    outputSource: step2_cpptraj_mask/output_cpptraj_path
  step3_cpptraj_mask_out1:
    label: output_cpptraj_path
    doc: Path to the output processed trajectory.
    type: File
    outputSource: step3_cpptraj_mask/output_cpptraj_path

  # INIT COMMENT IN CASE OF EXECUTION WITH MAC ARM
  step4_concoord_dist_out1:
    label: output_pdb_path
    doc: Output pdb file.
    type: File
    outputSource: step4_concoord_dist/output_pdb_path
  step4_concoord_dist_out2:
    label: output_gro_path
    doc: Output gro file.
    type: File
    outputSource: step4_concoord_dist/output_gro_path
  step4_concoord_dist_out3:
    label: output_dat_path
    doc: Output dat with structure interpretation and bond definitions.
    type: File
    outputSource: step4_concoord_dist/output_dat_path
  step5_concoord_disco_out1:
    label: output_traj_path
    doc: Output trajectory file.
    type: File
    outputSource: step5_concoord_disco/output_traj_path
  step5_concoord_disco_out2:
    label: output_rmsd_path
    doc: Output rmsd file.
    type: File
    outputSource: step5_concoord_disco/output_rmsd_path
  step5_concoord_disco_out3:
    label: output_bfactor_path
    doc: Output B-factor file.
    type: File
    outputSource: step5_concoord_disco/output_bfactor_path
  step6_cpptraj_rms_out1:
    label: output_cpptraj_path
    doc: Path to the output processed analysis.
    type: File
    outputSource: step6_cpptraj_rms/output_cpptraj_path
  step7_cpptraj_convert_out1:
    label: output_cpptraj_path
    doc: Path to the output processed trajectory.
    type: File
    outputSource: step7_cpptraj_convert/output_cpptraj_path
  # END COMMENT IN CASE OF EXECUTION WITH MAC ARM

  step8_prody_anm_out1:
    label: output_pdb_path
    doc: Output multi-model PDB file with the generated ensemble.
    type: File
    outputSource: step8_prody_anm/output_pdb_path
  step9_cpptraj_rms_out1:
    label: output_cpptraj_path
    doc: Path to the output processed analysis.
    type: File
    outputSource: step9_cpptraj_rms/output_cpptraj_path
  step10_cpptraj_convert_out1:
    label: output_cpptraj_path
    doc: Path to the output processed trajectory.
    type: File
    outputSource: step10_cpptraj_convert/output_cpptraj_path
  step11_bd_run_out1:
    label: output_crd_path
    doc: Output ensemble.
    type: File
    outputSource: step11_bd_run/output_crd_path
  step11_bd_run_out2:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step11_bd_run/output_log_path
  step12_cpptraj_rms_out1:
    label: output_cpptraj_path
    doc: Path to the output processed analysis.
    type: File
    outputSource: step12_cpptraj_rms/output_cpptraj_path
  step12_cpptraj_rms_out2:
    label: output_traj_path
    doc: Path to the output processed trajectory.
    type: File
    outputSource: step12_cpptraj_rms/output_traj_path
  step13_dmd_run_out1:
    label: output_crd_path
    doc: Output ensemble.
    type: File
    outputSource: step13_dmd_run/output_crd_path
  step13_dmd_run_out2:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step13_dmd_run/output_log_path
  step14_cpptraj_rms_out1:
    label: output_cpptraj_path
    doc: Path to the output processed analysis.
    type: File
    outputSource: step14_cpptraj_rms/output_cpptraj_path
  step14_cpptraj_rms_out2:
    label: output_traj_path
    doc: Path to the output processed trajectory.
    type: File
    outputSource: step14_cpptraj_rms/output_traj_path
  step15_nma_run_out1:
    label: output_crd_path
    doc: Output ensemble.
    type: File
    outputSource: step15_nma_run/output_crd_path
  step15_nma_run_out2:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step15_nma_run/output_log_path
  step16_cpptraj_rms_out1:
    label: output_cpptraj_path
    doc: Path to the output processed analysis.
    type: File
    outputSource: step16_cpptraj_rms/output_cpptraj_path
  step17_cpptraj_convert_out1:
    label: output_cpptraj_path
    doc: Path to the output processed trajectory.
    type: File
    outputSource: step17_cpptraj_convert/output_cpptraj_path
  step18_nolb_nma_out1:
    label: output_pdb_path
    doc: Output multi-model PDB file with the generated ensemble.
    type: File
    outputSource: step18_nolb_nma/output_pdb_path
  step19_cpptraj_rms_out1:
    label: output_cpptraj_path
    doc: Path to the output processed analysis.
    type: File
    outputSource: step19_cpptraj_rms/output_cpptraj_path
  step20_cpptraj_convert_out1:
    label: output_cpptraj_path
    doc: Path to the output processed trajectory.
    type: File
    outputSource: step20_cpptraj_convert/output_cpptraj_path
  step21_imod_imode_out1:
    label: output_dat_path
    doc: Output dat with normal modes.
    type: File
    outputSource: step21_imod_imode/output_dat_path
  step22_imod_imc_out1:
    label: output_traj_path
    doc: Output multi-model PDB file with the generated ensemble.
    type: File
    outputSource: step22_imod_imc/output_traj_path
  step23_cpptraj_rms_out1:
    label: output_cpptraj_path
    doc: Path to the output processed analysis.
    type: File
    outputSource: step23_cpptraj_rms/output_cpptraj_path
  step24_cpptraj_convert_out1:
    label: output_cpptraj_path
    doc: Path to the output processed trajectory.
    type: File
    outputSource: step24_cpptraj_convert/output_cpptraj_path
  step26_make_ndx_out1:
    label: output_ndx_path
    doc: Path to the output index NDX file.
    type: File
    outputSource: step26_make_ndx/output_ndx_path
  step27_gmx_cluster_out1:
    label: output_pdb_path
    doc: Path to the output cluster file.
    type: File
    outputSource: step27_gmx_cluster/output_pdb_path
  step28_cpptraj_rms_out1:
    label: output_cpptraj_path
    doc: Path to the output processed analysis.
    type: File
    outputSource: step28_cpptraj_rms/output_cpptraj_path
  step28_cpptraj_rms_out2:
    label: output_traj_path
    doc: Path to the output processed trajectory.
    type: File
    outputSource: step28_cpptraj_rms/output_traj_path
  step29_pcz_zip_out1:
    label: output_pcz_path
    doc: Output compressed trajectory.
    type: File
    outputSource: step29_pcz_zip/output_pcz_path
  step30_pcz_zip_out1:
    label: output_pcz_path
    doc: Output compressed trajectory.
    type: File
    outputSource: step30_pcz_zip/output_pcz_path
  step31_pcz_info_out1:
    label: output_json_path
    doc: Output json file with PCA info such as number of components, variance and dimensionality.
    type: File
    outputSource: step31_pcz_info/output_json_path
  step32_pcz_evecs_out1:
    label: output_json_path
    doc: Output json file with PCA Eigen Vectors.
    type: File
    outputSource: step32_pcz_evecs/output_json_path
  step33_pcz_animate_out1:
    label: output_crd_path
    doc: Output PCA animated trajectory file.
    type: File
    outputSource: step33_pcz_animate/output_crd_path
  step34_cpptraj_convert_out1:
    label: output_cpptraj_path
    doc: Path to the output processed trajectory.
    type: File
    outputSource: step34_cpptraj_convert/output_cpptraj_path
  step35_pcz_bfactor_out1:
    label: output_dat_path
    doc: Output Bfactor x residue x PCA mode file.
    type: File
    outputSource: step35_pcz_bfactor/output_dat_path
  step35_pcz_bfactor_out2:
    label: output_pdb_path
    doc: Output PDB with Bfactor x residue x PCA mode file.
    type: File
    outputSource: step35_pcz_bfactor/output_pdb_path
  step36_pcz_hinges_out1:
    label: output_json_path
    doc: Output hinge regions x PCA mode file.
    type: File
    outputSource: step36_pcz_hinges/output_json_path
  step37_pcz_hinges_out1:
    label: output_json_path
    doc: Output hinge regions x PCA mode file.
    type: File
    outputSource: step37_pcz_hinges/output_json_path
  step38_pcz_hinges_out1:
    label: output_json_path
    doc: Output hinge regions x PCA mode file.
    type: File
    outputSource: step38_pcz_hinges/output_json_path
  step39_pcz_stiffness_out1:
    label: output_json_path
    doc: Output json file with PCA Stiffness.
    type: File
    outputSource: step39_pcz_stiffness/output_json_path
  step40_pcz_collectivity_out1:
    label: output_json_path
    doc: Output json file with PCA Collectivity indexes per mode.
    type: File
    outputSource: step40_pcz_collectivity/output_json_path
steps:
  step0_extract_model:
    label: extract_model
    doc: This class is a wrapper of the Structure Checking tool to extract a model from a 3D structure.
    run: biobb_adapters/extract_model.cwl
    in:
      config: step0_extract_model_config
      input_structure_path: step0_extract_model_input_structure_path
      output_structure_path: step0_extract_model_output_structure_path
    out:
    - output_structure_path
  step1_extract_chain:
    label: extract_chain
    doc: This class is a wrapper of the Structure Checking tool to extract a chain from a 3D structure.
    run: biobb_adapters/extract_chain.cwl
    in:
      config: step1_extract_chain_config
      input_structure_path: step0_extract_model/output_structure_path
      output_structure_path: step1_extract_chain_output_structure_path
    out:
    - output_structure_path
  step2_cpptraj_mask:
    label: cpptraj_mask
    doc: Wrapper of the Ambertools Cpptraj module for extracting a selection of atoms from a given cpptraj compatible trajectory.
    run: biobb_adapters/cpptraj_mask.cwl
    in:
      config: step2_cpptraj_mask_config
      input_top_path: step1_extract_chain/output_structure_path
      input_traj_path: step1_extract_chain/output_structure_path
      output_cpptraj_path: step2_cpptraj_mask_output_cpptraj_path
    out:
    - output_cpptraj_path
  step3_cpptraj_mask:
    label: cpptraj_mask
    doc: Wrapper of the Ambertools Cpptraj module for extracting a selection of atoms from a given cpptraj compatible trajectory.
    run: biobb_adapters/cpptraj_mask.cwl
    in:
      config: step3_cpptraj_mask_config
      input_top_path: step1_extract_chain/output_structure_path
      input_traj_path: step1_extract_chain/output_structure_path
      output_cpptraj_path: step3_cpptraj_mask_output_cpptraj_path
    out:
    - output_cpptraj_path

  # INIT COMMENT IN CASE OF EXECUTION WITH MAC ARM
  step4_concoord_dist:
    label: concoord_dist
    doc: Wrapper of the Concoord_dist software.
    run: biobb_adapters/concoord_dist.cwl
    in:
      config: step4_concoord_dist_config
      input_structure_path: step1_extract_chain/output_structure_path
      output_pdb_path: step4_concoord_dist_output_pdb_path
      output_gro_path: step4_concoord_dist_output_gro_path
      output_dat_path: step4_concoord_dist_output_dat_path
    out:
    - output_pdb_path
    - output_gro_path
    - output_dat_path
  step5_concoord_disco:
    label: concoord_disco
    doc: Wrapper of the Concoord_disco software.
    run: biobb_adapters/concoord_disco.cwl
    in:
      config: step5_concoord_disco_config
      input_pdb_path: step4_concoord_dist/output_pdb_path
      input_dat_path: step4_concoord_dist/output_dat_path
      output_traj_path: step5_concoord_disco_output_traj_path
      output_rmsd_path: step5_concoord_disco_output_rmsd_path
      output_bfactor_path: step5_concoord_disco_output_bfactor_path
    out:
    - output_traj_path
    - output_rmsd_path
    - output_bfactor_path
  step6_cpptraj_rms:
    label: cpptraj_rms
    doc: Wrapper of the Ambertools Cpptraj module for calculating the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
    run: biobb_adapters/cpptraj_rms.cwl
    in:
      config: step6_cpptraj_rms_config
      input_top_path: step4_concoord_dist/output_pdb_path
      input_traj_path: step5_concoord_disco/output_traj_path
      input_exp_path: step1_extract_chain/output_structure_path
      output_cpptraj_path: step6_cpptraj_rms_output_cpptraj_path
    out:
    - output_cpptraj_path
  step7_cpptraj_convert:
    label: cpptraj_convert
    doc: Wrapper of the Ambertools Cpptraj module for converting between cpptraj compatible trajectory file formats and/or extracting a selection of atoms or frames.
    run: biobb_adapters/cpptraj_convert.cwl
    in:
      config: step7_cpptraj_convert_config
      input_top_path: step4_concoord_dist/output_pdb_path
      input_traj_path: step5_concoord_disco/output_traj_path
      output_cpptraj_path: step7_cpptraj_convert_output_cpptraj_path
    out:
    - output_cpptraj_path
  # END COMMENT IN CASE OF EXECUTION WITH MAC ARM  

  step8_prody_anm:
    label: prody_anm
    doc: Wrapper of the Prody software.
    run: biobb_adapters/prody_anm.cwl
    in:
      config: step8_prody_anm_config
      input_pdb_path: step1_extract_chain/output_structure_path
      output_pdb_path: step8_prody_anm_output_pdb_path
    out:
    - output_pdb_path
  step9_cpptraj_rms:
    label: cpptraj_rms
    doc: Wrapper of the Ambertools Cpptraj module for calculating the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
    run: biobb_adapters/cpptraj_rms.cwl
    in:
      config: step9_cpptraj_rms_config
      input_top_path: step8_prody_anm/output_pdb_path
      input_traj_path: step8_prody_anm/output_pdb_path
      input_exp_path: step1_extract_chain/output_structure_path
      output_cpptraj_path: step9_cpptraj_rms_output_cpptraj_path
    out:
    - output_cpptraj_path
  step10_cpptraj_convert:
    label: cpptraj_convert
    doc: Wrapper of the Ambertools Cpptraj module for converting between cpptraj compatible trajectory file formats and/or extracting a selection of atoms or frames.
    run: biobb_adapters/cpptraj_convert.cwl
    in:
      config: step10_cpptraj_convert_config
      input_top_path: step2_cpptraj_mask/output_cpptraj_path
      input_traj_path: step8_prody_anm/output_pdb_path
      output_cpptraj_path: step10_cpptraj_convert_output_cpptraj_path
    out:
    - output_cpptraj_path
  step11_bd_run:
    label: bd_run
    doc: Run Brownian Dynamics from FlexServ
    run: biobb_adapters/bd_run.cwl
    in:
      config: step11_bd_run_config
      input_pdb_path: step3_cpptraj_mask/output_cpptraj_path
      output_crd_path: step11_bd_run_output_crd_path
      output_log_path: step11_bd_run_output_log_path
    out:
    - output_crd_path
    - output_log_path
  step12_cpptraj_rms:
    label: cpptraj_rms
    doc: Wrapper of the Ambertools Cpptraj module for calculating the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
    run: biobb_adapters/cpptraj_rms.cwl
    in:
      config: step12_cpptraj_rms_config
      input_top_path: step3_cpptraj_mask/output_cpptraj_path
      input_traj_path: step11_bd_run/output_crd_path
      input_exp_path: step1_extract_chain/output_structure_path
      output_cpptraj_path: step12_cpptraj_rms_output_cpptraj_path
      output_traj_path: step12_cpptraj_rms_output_traj_path
    out:
    - output_cpptraj_path
    - output_traj_path
  step13_dmd_run:
    label: dmd_run
    doc: Run Discrete Molecular Dynamics from FlexServ
    run: biobb_adapters/dmd_run.cwl
    in:
      config: step13_dmd_run_config
      input_pdb_path: step3_cpptraj_mask/output_cpptraj_path
      output_crd_path: step13_dmd_run_output_crd_path
      output_log_path: step13_dmd_run_output_log_path
    out:
    - output_crd_path
    - output_log_path
  step14_cpptraj_rms:
    label: cpptraj_rms
    doc: Wrapper of the Ambertools Cpptraj module for calculating the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
    run: biobb_adapters/cpptraj_rms.cwl
    in:
      config: step14_cpptraj_rms_config
      input_top_path: step3_cpptraj_mask/output_cpptraj_path
      input_traj_path: step13_dmd_run/output_crd_path
      input_exp_path: step1_extract_chain/output_structure_path
      output_cpptraj_path: step14_cpptraj_rms_output_cpptraj_path
      output_traj_path: step14_cpptraj_rms_output_traj_path
    out:
    - output_cpptraj_path
    - output_traj_path
  step15_nma_run:
    label: nma_run
    doc: Run Normal Mode Analysis from FlexServ
    run: biobb_adapters/nma_run.cwl
    in:
      config: step15_nma_run_config
      input_pdb_path: step3_cpptraj_mask/output_cpptraj_path
      output_crd_path: step15_nma_run_output_crd_path
      output_log_path: step15_nma_run_output_log_path
    out:
    - output_crd_path
    - output_log_path
  step16_cpptraj_rms:
    label: cpptraj_rms
    doc: Wrapper of the Ambertools Cpptraj module for calculating the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
    run: biobb_adapters/cpptraj_rms.cwl
    in:
      config: step16_cpptraj_rms_config
      input_top_path: step3_cpptraj_mask/output_cpptraj_path
      input_traj_path: step15_nma_run/output_crd_path
      input_exp_path: step1_extract_chain/output_structure_path
      output_cpptraj_path: step16_cpptraj_rms_output_cpptraj_path
    out:
    - output_cpptraj_path
  step17_cpptraj_convert:
    label: cpptraj_convert
    doc: Wrapper of the Ambertools Cpptraj module for converting between cpptraj compatible trajectory file formats and/or extracting a selection of atoms or frames.
    run: biobb_adapters/cpptraj_convert.cwl
    in:
      config: step17_cpptraj_convert_config
      input_top_path: step3_cpptraj_mask/output_cpptraj_path
      input_traj_path: step15_nma_run/output_crd_path
      output_cpptraj_path: step17_cpptraj_convert_output_cpptraj_path
    out:
    - output_cpptraj_path
  step18_nolb_nma:
    label: nolb_nma
    doc: Wrapper of the Nolb software.
    run: biobb_adapters/nolb_nma.cwl
    in:
      config: step18_nolb_nma_config
      input_pdb_path: step3_cpptraj_mask/output_cpptraj_path
      output_pdb_path: step18_nolb_nma_output_pdb_path
    out:
    - output_pdb_path
  step19_cpptraj_rms:
    label: cpptraj_rms
    doc: Wrapper of the Ambertools Cpptraj module for calculating the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
    run: biobb_adapters/cpptraj_rms.cwl
    in:
      config: step19_cpptraj_rms_config
      input_top_path: step3_cpptraj_mask/output_cpptraj_path
      input_traj_path: step18_nolb_nma/output_pdb_path
      input_exp_path: step1_extract_chain/output_structure_path
      output_cpptraj_path: step19_cpptraj_rms_output_cpptraj_path
    out:
    - output_cpptraj_path
  step20_cpptraj_convert:
    label: cpptraj_convert
    doc: Wrapper of the Ambertools Cpptraj module for converting between cpptraj compatible trajectory file formats and/or extracting a selection of atoms or frames.
    run: biobb_adapters/cpptraj_convert.cwl
    in:
      config: step20_cpptraj_convert_config
      input_top_path: step3_cpptraj_mask/output_cpptraj_path
      input_traj_path: step18_nolb_nma/output_pdb_path
      output_cpptraj_path: step20_cpptraj_convert_output_cpptraj_path
    out:
    - output_cpptraj_path
  step21_imod_imode:
    label: imod_imode
    doc: Wrapper of the imods_imode software.
    run: biobb_adapters/imod_imode.cwl
    in:
      config: step21_imod_imode_config
      input_pdb_path: step1_extract_chain/output_structure_path
      output_dat_path: step21_imod_imode_output_dat_path
    out:
    - output_dat_path
  step22_imod_imc:
    label: imod_imc
    doc: Wrapper of the imods_imc software.
    run: biobb_adapters/imod_imc.cwl
    in:
      config: step22_imod_imc_config
      input_pdb_path: step1_extract_chain/output_structure_path
      input_dat_path: step21_imod_imode/output_dat_path
      output_traj_path: step22_imod_imc_output_traj_path
    out:
    - output_traj_path
  step23_cpptraj_rms:
    label: cpptraj_rms
    doc: Wrapper of the Ambertools Cpptraj module for calculating the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
    run: biobb_adapters/cpptraj_rms.cwl
    in:
      config: step23_cpptraj_rms_config
      input_top_path: step22_imod_imc/output_traj_path
      input_traj_path: step22_imod_imc/output_traj_path
      input_exp_path: step1_extract_chain/output_structure_path
      output_cpptraj_path: step23_cpptraj_rms_output_cpptraj_path
    out:
    - output_cpptraj_path
  step24_cpptraj_convert:
    label: cpptraj_convert
    doc: Wrapper of the Ambertools Cpptraj module for converting between cpptraj compatible trajectory file formats and/or extracting a selection of atoms or frames.
    run: biobb_adapters/cpptraj_convert.cwl
    in:
      config: step24_cpptraj_convert_config
      input_top_path: step22_imod_imc/output_traj_path
      input_traj_path: step22_imod_imc/output_traj_path
      output_cpptraj_path: step24_cpptraj_convert_output_cpptraj_path
    out:
    - output_cpptraj_path
  step26_make_ndx:
    label: make_ndx
    doc: Creates a GROMACS index file (NDX) from an input selection and an input GROMACS structure file.
    run: biobb_adapters/make_ndx.cwl
    in:
      config: step26_make_ndx_config
      input_structure_path: step3_cpptraj_mask/output_cpptraj_path
      output_ndx_path: step26_make_ndx_output_ndx_path
    out:
    - output_ndx_path
  step27_gmx_cluster:
    label: gmx_cluster
    doc: Wrapper of the GROMACS cluster module for clustering structures from a given GROMACS compatible trajectory.
    run: biobb_adapters/gmx_cluster.cwl
    in:
      config: step27_gmx_cluster_config
      input_structure_path: step3_cpptraj_mask/output_cpptraj_path
      input_traj_path: step14_cpptraj_rms/output_traj_path
      input_index_path: step26_make_ndx/output_ndx_path
      output_pdb_path: step27_gmx_cluster_output_pdb_path
    out:
    - output_pdb_path
  step28_cpptraj_rms:
    label: cpptraj_rms
    doc: Wrapper of the Ambertools Cpptraj module for calculating the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
    run: biobb_adapters/cpptraj_rms.cwl
    in:
      config: step28_cpptraj_rms_config
      input_top_path: step3_cpptraj_mask/output_cpptraj_path
      input_traj_path: step27_gmx_cluster/output_pdb_path
      input_exp_path: step3_cpptraj_mask/output_cpptraj_path
      output_cpptraj_path: step28_cpptraj_rms_output_cpptraj_path
      output_traj_path: step28_cpptraj_rms_output_traj_path
    out:
    - output_cpptraj_path
    - output_traj_path
  step29_pcz_zip:
    label: pcz_zip
    doc: Compress MD simulation trajectories with PCA suite
    run: biobb_adapters/pcz_zip.cwl
    in:
      config: step29_pcz_zip_config
      input_pdb_path: step3_cpptraj_mask/output_cpptraj_path
      input_crd_path: step28_cpptraj_rms/output_traj_path
      output_pcz_path: step29_pcz_zip_output_pcz_path
    out:
    - output_pcz_path
  step30_pcz_zip:
    label: pcz_zip
    doc: Compress MD simulation trajectories with PCA suite
    run: biobb_adapters/pcz_zip.cwl
    in:
      config: step30_pcz_zip_config
      input_pdb_path: step3_cpptraj_mask/output_cpptraj_path
      input_crd_path: step28_cpptraj_rms/output_traj_path
      output_pcz_path: step30_pcz_zip_output_pcz_path
    out:
    - output_pcz_path
  step31_pcz_info:
    label: pcz_info
    doc: Extract PCA info (variance, Dimensionality) from a compressed PCZ file
    run: biobb_adapters/pcz_info.cwl
    in:
      input_pcz_path: step29_pcz_zip/output_pcz_path
      output_json_path: step31_pcz_info_output_json_path
    out:
    - output_json_path
  step32_pcz_evecs:
    label: pcz_evecs
    doc: Extract PCA Eigen Vectors from a compressed PCZ file
    run: biobb_adapters/pcz_evecs.cwl
    in:
      config: step32_pcz_evecs_config
      input_pcz_path: step29_pcz_zip/output_pcz_path
      output_json_path: step32_pcz_evecs_output_json_path
    out:
    - output_json_path
  step33_pcz_animate:
    label: pcz_animate
    doc: Extract PCA animations from a compressed PCZ file
    run: biobb_adapters/pcz_animate.cwl
    in:
      config: step33_pcz_animate_config
      input_pcz_path: step29_pcz_zip/output_pcz_path
      output_crd_path: step33_pcz_animate_output_crd_path
    out:
    - output_crd_path
  step34_cpptraj_convert:
    label: cpptraj_convert
    doc: Wrapper of the Ambertools Cpptraj module for converting between cpptraj compatible trajectory file formats and/or extracting a selection of atoms or frames.
    run: biobb_adapters/cpptraj_convert.cwl
    in:
      config: step34_cpptraj_convert_config
      input_top_path: step3_cpptraj_mask/output_cpptraj_path
      input_traj_path: step33_pcz_animate/output_crd_path
      output_cpptraj_path: step34_cpptraj_convert_output_cpptraj_path
    out:
    - output_cpptraj_path
  step35_pcz_bfactor:
    label: pcz_bfactor
    doc: Extract residue bfactors x PCA mode from a compressed PCZ file
    run: biobb_adapters/pcz_bfactor.cwl
    in:
      config: step35_pcz_bfactor_config
      input_pcz_path: step29_pcz_zip/output_pcz_path
      output_dat_path: step35_pcz_bfactor_output_dat_path
      output_pdb_path: step35_pcz_bfactor_output_pdb_path
    out:
    - output_dat_path
    - output_pdb_path
  step36_pcz_hinges:
    label: pcz_hinges
    doc: Compute possible hinge regions (residues around which large protein movements are organized) of a molecule from a compressed PCZ file
    run: biobb_adapters/pcz_hinges.cwl
    in:
      config: step36_pcz_hinges_config
      input_pcz_path: step30_pcz_zip/output_pcz_path
      output_json_path: step36_pcz_hinges_output_json_path
    out:
    - output_json_path
  step37_pcz_hinges:
    label: pcz_hinges
    doc: Compute possible hinge regions (residues around which large protein movements are organized) of a molecule from a compressed PCZ file
    run: biobb_adapters/pcz_hinges.cwl
    in:
      config: step37_pcz_hinges_config
      input_pcz_path: step30_pcz_zip/output_pcz_path
      output_json_path: step37_pcz_hinges_output_json_path
    out:
    - output_json_path
  step38_pcz_hinges:
    label: pcz_hinges
    doc: Compute possible hinge regions (residues around which large protein movements are organized) of a molecule from a compressed PCZ file
    run: biobb_adapters/pcz_hinges.cwl
    in:
      config: step38_pcz_hinges_config
      input_pcz_path: step30_pcz_zip/output_pcz_path
      output_json_path: step38_pcz_hinges_output_json_path
    out:
    - output_json_path
  step39_pcz_stiffness:
    label: pcz_stiffness
    doc: Extract PCA stiffness from a compressed PCZ file
    run: biobb_adapters/pcz_stiffness.cwl
    in:
      config: step39_pcz_stiffness_config
      input_pcz_path: step29_pcz_zip/output_pcz_path
      output_json_path: step39_pcz_stiffness_output_json_path
    out:
    - output_json_path
  step40_pcz_collectivity:
    label: pcz_collectivity
    doc: Extract PCA collectivity (numerical measure of how many atoms are affected by a given mode) from a compressed PCZ file
    run: biobb_adapters/pcz_collectivity.cwl
    in:
      config: step40_pcz_collectivity_config
      input_pcz_path: step29_pcz_zip/output_pcz_path
      output_json_path: step40_pcz_collectivity_output_json_path
    out:
    - output_json_path
