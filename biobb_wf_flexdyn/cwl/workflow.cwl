#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
label: Conformational ensembles generation
doc: |-
  This tutorial aims to illustrate the process of generating protein conformational ensembles from 3D structures and analysing its molecular flexibility
inputs:
  step0_extract_model_input_structure_path: File
  step0_extract_model_output_structure_path: string
  step0_extract_model_config: string
  step1_extract_chain_output_structure_path: string
  step1_extract_chain_config: string
  step2_cpptraj_mask_output_cpptraj_path: string
  step2_cpptraj_mask_config: string
  step3_cpptraj_mask_output_cpptraj_path: string
  step3_cpptraj_mask_config: string
  # step4_concoord_dist_output_pdb_path: string
  # step4_concoord_dist_output_gro_path: string
  # step4_concoord_dist_output_dat_path: string
  # step4_concoord_dist_config: string
  # step5_concoord_disco_output_traj_path: string
  # step5_concoord_disco_output_rmsd_path: string
  # step5_concoord_disco_output_bfactor_path: string
  # step4_concoord_disco_config: string
  # step6_cpptraj_rms_output_cpptraj_path: string
  # step6_cpptraj_rms_config: string
  # step7_cpptraj_convert_output_cpptraj_path: string
  # step7_cpptraj_convert_config: string

  # PRODY WORKS
  step8_prody_anm_output_pdb_path: string
  step8_prody_anm_config: string
  step9_cpptraj_rms_output_cpptraj_path: string
  step9_cpptraj_rms_config: string
  step10_cpptraj_convert_output_cpptraj_path: string
  step10_cpptraj_convert_config: string
  # PRODY WORKS

  # BD WORKS
  step11_bd_run_output_crd_path: string
  step11_bd_run_output_log_path: string
  step11_bd_run_config: string
  step12_cpptraj_rms_output_cpptraj_path: string
  step12_cpptraj_rms_output_traj_path: string
  step12_cpptraj_rms_config: string
  # BD WORKS
  
  step13_dmd_run_output_crd_path: string
  step13_dmd_run_output_log_path: string
  step13_dmd_run_config: string
  step14_cpptraj_rms_output_cpptraj_path: string
  step14_cpptraj_rms_output_traj_path: string
  step14_cpptraj_rms_config: string

  # PERL ERROR (/usr/local/bin/perl)
  # step15_nma_run_output_crd_path: string
  # step15_nma_run_output_log_path: string
  # step15_nma_run_config: string
  # step16_cpptraj_rms_output_cpptraj_path: string
  # step16_cpptraj_rms_config: string
  # step17_cpptraj_convert_output_cpptraj_path: string
  # step17_cpptraj_convert_config: string
  # PERL ERROR

  # NOLB & IMODS WORK
  step18_nolb_nma_output_pdb_path: string
  step18_nolb_nma_config: string
  step19_cpptraj_rms_output_cpptraj_path: string
  step19_cpptraj_rms_config: string
  step20_cpptraj_convert_output_cpptraj_path: string
  step20_cpptraj_convert_config: string
  step21_imod_imode_output_dat_path: string
  step21_imod_imode_config: string
  step22_imod_imc_output_traj_path: string
  step22_imod_imc_config: string
  step23_cpptraj_rms_output_cpptraj_path: string
  step23_cpptraj_rms_config: string
  step24_cpptraj_convert_output_cpptraj_path: string
  step24_cpptraj_convert_config: string
  # NOLB & IMODS WORK

  step26_make_ndx_output_ndx_path: string
  step26_make_ndx_config: string
  step27_gmx_cluster_output_pdb_path: string
  step27_gmx_cluster_config: string
  step28_cpptraj_rms_output_cpptraj_path: string
  step28_cpptraj_rms_output_traj_path: string
  step28_cpptraj_rms_config: string
  step29_pcz_zip_output_pcz_path: string
  step29_pcz_zip_config: string
  step30_pcz_zip_output_pcz_path: string
  step30_pcz_zip_config: string
  step31_pcz_info_output_json_path: string
  step32_pcz_evecs_output_json_path: string
  step32_pcz_evecs_config: string
  step33_pcz_animate_output_crd_path: string
  step33_pcz_animate_config: string
  step34_cpptraj_convert_output_cpptraj_path: string
  step34_cpptraj_convert_config: string
  step35_pcz_bfactor_output_dat_path: string
  step35_pcz_bfactor_output_pdb_path: string
  step35_pcz_bfactor_config: string
  step36_pcz_hinges_output_json_path: string
  step36_pcz_hinges_config: string
  step37_pcz_hinges_output_json_path: string
  step37_pcz_hinges_config: string
  step38_pcz_hinges_output_json_path: string
  step38_pcz_hinges_config: string
  step39_pcz_stiffness_output_json_path: string
  step39_pcz_stiffness_config: string
  step40_pcz_collectivity_output_json_path: string
  step40_pcz_collectivity_config: string

outputs:
  step0_extract_model_out1:
    label: output_structure_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step0_extract_model/output_structure_path
  step1_extract_chain_out1:
    label: output_structure_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step1_extract_chain/output_structure_path
  step2_cpptraj_mask_out1:
    label: output_structure_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step2_cpptraj_mask/output_cpptraj_path
  step3_cpptraj_mask_out1:
    label: output_structure_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step3_cpptraj_mask/output_cpptraj_path
  # step4_concoord_dist_out1:
  #   label: output_pdb_path
  #   doc: |-
  #     Path to the output file
  #   type: File
  #   outputSource: step4_concoord_dist/output_pdb_path
  # step4_concoord_dist_out2:
  #   label: output_gro_path
  #   doc: |-
  #     Path to the output file
  #   type: File
  #   outputSource: step4_concoord_dist/output_gro_path
  # step4_concoord_dist_out3:
  #   label: output_dat_path
  #   doc: |-
  #     Path to the output file
  #   type: File
  #   outputSource: step4_concoord_dist/output_dat_path
  # step5_concoord_disco_out1:
  #   label: output_traj_path
  #   doc: |-
  #     Path to the output file
  #   type: File
  #   outputSource: step5_concoord_disco/output_pdb_path
  # step5_concoord_disco_out2:
  #   label: output_rmsd_path
  #   doc: |-
  #     Path to the output file
  #   type: File
  #   outputSource: step5_concoord_disco/output_pdb_path
  # step5_concoord_disco_out3:
  #   label: output_bfactor_path
  #   doc: |-
  #     Path to the output file
  #   type: File
  #   outputSource: step5_concoord_disco/output_pdb_path
  # step6_cpptraj_rms_out1:
  #   label: output_cpptraj_path
  #   doc: |-
  #     Path to the output file
  #   type: File
  #   outputSource: step6_cpptraj_rms/output_cpptraj_path
  # step7_cpptraj_convert_out1:
  #   label: output_cpptraj_path
  #   doc: |-
  #     Path to the output file
  #   type: File
  #   outputSource: step7_cpptraj_convert/output_cpptraj_path

  # PRODY WORKS
  step8_prody_anm_out1:
    label: output_pdb_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step8_prody_anm/output_pdb_path
  step9_cpptraj_rms_out1:
    label: output_cpptraj_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step9_cpptraj_rms/output_cpptraj_path
  step10_cpptraj_convert_out1:
    label: output_cpptraj_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step10_cpptraj_convert/output_cpptraj_path
  # PRODY WORKS

  # BD WORKS
  step11_bd_run_out1:
    label: output_crd_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step11_bd_run/output_crd_path
  step11_bd_run_out2:
    label: output_log_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step11_bd_run/output_log_path
  step12_cpptraj_rms_out1:
    label: output_cpptraj_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step12_cpptraj_rms/output_cpptraj_path
  step12_cpptraj_rms_out2:
    label: output_traj_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step12_cpptraj_rms/output_traj_path
  # BD WORKS

  step13_dmd_run_out1:
    label: output_crd_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step13_dmd_run/output_crd_path
  step13_dmd_run_out2:
    label: output_log_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step13_dmd_run/output_log_path
  step14_cpptraj_rms_out1:
    label: output_cpptraj_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step14_cpptraj_rms/output_cpptraj_path
  step14_cpptraj_rms_out2:
    label: output_traj_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step14_cpptraj_rms/output_traj_path

  # PERL ERROR (/usr/local/bin/perl)
  # step15_nma_run_out1:
  #   label: output_crd_path
  #   doc: |-
  #     Path to the output file
  #   type: File
  #   outputSource: step15_nma_run/output_crd_path
  # step15_nma_run_out2:
  #   label: output_log_path
  #   doc: |-
  #     Path to the output file
  #   type: File
  #   outputSource: step15_nma_run/output_log_path
  # step16_cpptraj_rms_out1:
  #   label: output_cpptraj_path
  #   doc: |-
  #     Path to the output file
  #   type: File
  #   outputSource: step16_cpptraj_rms/output_cpptraj_path
  # step17_cpptraj_convert_out1:
  #   label: output_cpptraj_path
  #   doc: |-
  #     Path to the output file
  #   type: File
  #   outputSource: step17_cpptraj_convert/output_cpptraj_path
  # PERL ERROR

  # NOLB & IMODS WORK
  step18_nolb_nma_out1:
    label: output_pdb_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step18_nolb_nma/output_pdb_path
  step19_cpptraj_rms_out1:
    label: output_cpptraj_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step19_cpptraj_rms/output_cpptraj_path
  step20_cpptraj_convert_out1:
    label: output_cpptraj_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step20_cpptraj_convert/output_cpptraj_path
  step21_imod_imode_out1:
    label: output_dat_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step21_imod_imode/output_dat_path
  step22_imod_imc_out1:
    label: output_traj_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step22_imod_imc/output_traj_path
  step23_cpptraj_rms_out1:
    label: output_cpptraj_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step23_cpptraj_rms/output_cpptraj_path
  step24_cpptraj_convert_out1:
    label: output_cpptraj_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step24_cpptraj_convert/output_cpptraj_path
  # NOLB & IMODS WORK

  step26_make_ndx_out1:
    label: output_ndx_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step26_make_ndx/output_ndx_path
  step27_gmx_cluster_out1:
    label: output_pdb_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step27_gmx_cluster/output_pdb_path
  step28_cpptraj_rms_out1:
    label: output_cpptraj_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step28_cpptraj_rms/output_cpptraj_path
  step28_cpptraj_rms_out2:
    label: output_traj_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step28_cpptraj_rms/output_traj_path
  step29_pcz_zip_out1:
    label: output_pcz_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step29_pcz_zip/output_pcz_path
  step30_pcz_zip_out1:
    label: output_pcz_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step30_pcz_zip/output_pcz_path
  step31_pcz_info_out1:
    label: output_json_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step31_pcz_info/output_json_path
  step32_pcz_evecs_out1:
    label: output_json_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step32_pcz_evecs/output_json_path
  step33_pcz_animate_out1:
    label: output_crd_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step33_pcz_animate/output_crd_path
  step34_cpptraj_convert_out1:
    label: output_cpptraj_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step34_cpptraj_convert/output_cpptraj_path
  step35_pcz_bfactor_out1:
    label: output_dat_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step35_pcz_bfactor/output_dat_path
  step35_pcz_bfactor_out2:
    label: output_pdb_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step35_pcz_bfactor/output_pdb_path
  step36_pcz_hinges_out1:
    label: output_json_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step36_pcz_hinges/output_json_path
  step37_pcz_hinges_out1:
    label: output_json_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step37_pcz_hinges/output_json_path
  step38_pcz_hinges_out1:
    label: output_json_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step38_pcz_hinges/output_json_path
  step39_pcz_stiffness_out1:
    label: output_json_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step39_pcz_stiffness/output_json_path
  step40_pcz_collectivity_out1:
    label: output_json_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step40_pcz_collectivity/output_json_path

steps:
  step0_extract_model:
    label: extract_model
    doc: |-
      Extracts a model from a 3D structure.
    #run: /path/to/biobb_adapters/extract_model.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/extract_model.cwl
    in:
      config: step0_extract_model_config
      input_structure_path: step0_extract_model_input_structure_path
      output_structure_path: step0_extract_model_output_structure_path
    out:
    - output_structure_path
  step1_extract_chain:
    label: extract_chain
    doc: |-
      Extracts a chain from a 3D structure.
    #run: /path/to/biobb_adapters/extract_chain.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/extract_chain.cwl
    in:
      config: step1_extract_chain_config
      input_structure_path: step0_extract_model/output_structure_path
      output_structure_path: step1_extract_chain_output_structure_path
    out:
    - output_structure_path
  step2_cpptraj_mask:
    label: cpptraj_mask
    doc: |-
      Extracts a selection of atoms from a given cpptraj compatible trajectory.
    #run: /path/to/biobb_adapters/cpptraj_mask.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/cpptraj_mask.cwl
    in:
      config: step2_cpptraj_mask_config
      input_top_path: step1_extract_chain/output_structure_path
      input_traj_path: step1_extract_chain/output_structure_path
      output_cpptraj_path: step2_cpptraj_mask_output_cpptraj_path
    out:
    - output_cpptraj_path
  step3_cpptraj_mask:
    label: cpptraj_mask
    doc: |-
      Extracts a selection of atoms from a given cpptraj compatible trajectory.
    #run: /path/to/biobb_adapters/cpptraj_mask.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/cpptraj_mask.cwl
    in:
      config: step3_cpptraj_mask_config
      input_top_path: step1_extract_chain/output_structure_path
      input_traj_path: step1_extract_chain/output_structure_path
      output_cpptraj_path: step3_cpptraj_mask_output_cpptraj_path
    out:
    - output_cpptraj_path
  # step4_concoord_dist:
  #   label: concoord_dist
  #   doc: |-
  #     Wrapper of the Concoord_dist software.
  #   #run: /path/to/biobb_adapters/concoord_dist.cwl
  #   run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/concoord_dist.cwl
  #   in:
  #     config: step4_concoord_dist_config
  #     input_structure_path: step1_extract_chain/output_structure_path
  #     output_pdb_path: step4_concoord_dist_output_pdb_path
  #     output_gro_path: step4_concoord_dist_output_gro_path
  #     output_dat_path: step4_concoord_dist_output_dat_path
  #   out:
  #   - output_pdb_path
  #   - output_gro_path
  #   - output_dat_path
  # step5_concoord_disco:
  #   label: concoord_disco
  #   doc: |-
  #     Wrapper of the Concoord_disco software.
  #   #run: /path/to/biobb_adapters/concoord_disco.cwl
  #   run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/concoord_disco.cwl
  #   in:
  #     config: step5_concoord_disco_config
  #     input_pdb_path: step4_concoord_dist/output_pdb_path
  #     input_dat_path: step4_concoord_dist/output_dat_path
  #     output_traj_path: step5_concoord_disco_output_traj_path
  #     output_rmsd_path: step5_concoord_disco_output_rmsd_path
  #     output_bfactor_path: step5_concoord_disco_output_bfactor_path
  #   out:
  #   - output_traj_path
  #   - output_rmsd_path
  #   - output_bfactor_path
  # step6_cpptraj_rms:
  #   label: cpptraj_rms
  #   doc: |-
  #     Calculates the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
  #   #run: /path/to/biobb_adapters/cpptraj_rms.cwl
  #   run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/cpptraj_rms.cwl
  #   in:
  #     config: step6_cpptraj_rms_config
  #     input_top_path: step4_concoord_dist/output_pdb_path
  #     input_traj_path: step5_concoord_disco/output_traj_path
  #     input_exp_path: step1_extract_chain/output_structure_path
  #     output_cpptraj_path: step6_cpptraj_rms_output_cpptraj_path
  #   out:
  #   - output_cpptraj_path
  # step7_cpptraj_convert:
  #   label: cpptraj_convert
  #   doc: |-
  #     Converts between cpptraj compatible trajectory file formats and/or extracting a selection of atoms or frames.
  #   #run: /path/to/biobb_adapters/cpptraj_convert.cwl
  #   run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/cpptraj_convert.cwl
  #   in:
  #     config: step7_cpptraj_convert_config
  #     input_top_path: step4_concoord_dist/output_pdb_path
  #     input_traj_path: step5_concoord_disco/output_traj_path
  #     output_cpptraj_path: step7_cpptraj_convert_output_cpptraj_path
  #   out:
  #   - output_cpptraj_path

  # PRODY & BD WORK
  step8_prody_anm:
    label: prody_anm
    doc: |-
      Wrapper of the Prody software.
    #run: /path/to/biobb_adapters/prody_anm.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/prody_anm.cwl
    in:
      config: step8_prody_anm_config
      input_pdb_path: step1_extract_chain/output_structure_path
      output_pdb_path: step8_prody_anm_output_pdb_path
    out:
    - output_pdb_path
  step9_cpptraj_rms:
    label: cpptraj_rms
    doc: |-
      Calculates the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
    #run: /path/to/biobb_adapters/cpptraj_rms.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/cpptraj_rms.cwl
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
    doc: |-
      Converts between cpptraj compatible trajectory file formats and/or extracting a selection of atoms or frames.
    #run: /path/to/biobb_adapters/cpptraj_convert.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/cpptraj_convert.cwl
    in:
      config: step10_cpptraj_convert_config
      input_top_path: step2_cpptraj_mask/output_cpptraj_path
      input_traj_path: step8_prody_anm/output_pdb_path
      output_cpptraj_path: step10_cpptraj_convert_output_cpptraj_path
    out:
    - output_cpptraj_path
  step11_bd_run:
    label: bd_run
    doc: |-
      Run Brownian Dynamics from FlexServ.
    #run: /path/to/biobb_adapters/bd_run.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/bd_run.cwl
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
    doc: |-
      Calculates the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
    #run: /path/to/biobb_adapters/cpptraj_rms.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/cpptraj_rms.cwl
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
  # PRODY & BD WORK

  step13_dmd_run:
    label: dmd_run
    doc: |-
      Run Discrete Molecular Dynamics from FlexServ.
    #run: /path/to/biobb_adapters/dmd_run.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/dmd_run.cwl
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
    doc: |-
      Calculates the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
    #run: /path/to/biobb_adapters/cpptraj_rms.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/cpptraj_rms.cwl
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

  # PERL ERROR (/usr/local/bin/perl)
  # step15_nma_run:
  #   label: nma_run
  #   doc: |-
  #     Run Normal Mode Analysis from FlexServ.
  #   #run: /path/to/biobb_adapters/nma_run.cwl
  #   run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/nma_run.cwl
  #   in:
  #     config: step15_nma_run_config
  #     input_pdb_path: step3_cpptraj_mask/output_cpptraj_path
  #     output_crd_path: step15_nma_run_output_crd_path
  #     output_log_path: step15_nma_run_output_log_path
  #   out:
  #   - output_crd_path
  #   - output_log_path
  # step16_cpptraj_rms:
  #   label: cpptraj_rms
  #   doc: |-
  #     Calculates the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
  #   #run: /path/to/biobb_adapters/cpptraj_rms.cwl
  #   run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/cpptraj_rms.cwl
  #   in:
  #     config: step16_cpptraj_rms_config
  #     input_top_path: step3_cpptraj_mask/output_cpptraj_path
  #     input_traj_path: step15_nma_run/output_crd_path
  #     input_exp_path: step1_extract_chain/output_structure_path
  #     output_cpptraj_path: step16_cpptraj_rms_output_cpptraj_path
  #   out:
  #   - output_cpptraj_path
  # step17_cpptraj_convert:
  #   label: cpptraj_convert
  #   doc: |-
  #     Converts between cpptraj compatible trajectory file formats and/or extracting a selection of atoms or frames.
  #   #run: /path/to/biobb_adapters/cpptraj_convert.cwl
  #   run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/cpptraj_convert.cwl
  #   in:
  #     config: step17_cpptraj_convert_config
  #     input_top_path: step3_cpptraj_mask/output_cpptraj_path
  #     input_traj_path: step15_nma_run/output_crd_path
  #     output_cpptraj_path: step17_cpptraj_convert_output_cpptraj_path
  #   out:
  #   - output_cpptraj_path
  # PERL ERROR

  # NOLB & IMODS WORK
  step18_nolb_nma:
    label: nolb_nma
    doc: |-
      Wrapper of the Nolb software.
    #run: /path/to/biobb_adapters/nolb_nma.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/nolb_nma.cwl
    in:
      config: step18_nolb_nma_config
      input_pdb_path: step3_cpptraj_mask/output_cpptraj_path
      output_pdb_path: step18_nolb_nma_output_pdb_path
    out:
    - output_pdb_path
  step19_cpptraj_rms:
    label: cpptraj_rms
    doc: |-
      Calculates the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
    #run: /path/to/biobb_adapters/cpptraj_rms.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/cpptraj_rms.cwl
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
    doc: |-
      Converts between cpptraj compatible trajectory file formats and/or extracting a selection of atoms or frames.
    #run: /path/to/biobb_adapters/cpptraj_convert.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/cpptraj_convert.cwl
    in:
      config: step20_cpptraj_convert_config
      input_top_path: step3_cpptraj_mask/output_cpptraj_path
      input_traj_path: step18_nolb_nma/output_pdb_path
      output_cpptraj_path: step20_cpptraj_convert_output_cpptraj_path
    out:
    - output_cpptraj_path
  step21_imod_imode:
    label: imod_imode
    doc: |-
      Wrapper of the imods_imode software.
    #run: /path/to/biobb_adapters/imod_imode.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/imod_imode.cwl
    in:
      config: step21_imod_imode_config
      input_pdb_path: step1_extract_chain/output_structure_path
      output_dat_path: step21_imod_imode_output_dat_path
    out:
    - output_dat_path
  step22_imod_imc:
    label: imod_imc
    doc: |-
      Wrapper of the imods_imc software.
    #run: /path/to/biobb_adapters/imod_imc.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/imod_imc.cwl
    in:
      config: step22_imod_imc_config
      input_pdb_path: step1_extract_chain/output_structure_path
      input_dat_path: step21_imod_imode/output_dat_path
      output_traj_path: step22_imod_imc_output_traj_path
    out:
    - output_traj_path
  step23_cpptraj_rms:
    label: cpptraj_rms
    doc: |-
      Calculates the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
    #run: /path/to/biobb_adapters/cpptraj_rms.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/cpptraj_rms.cwl
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
    doc: |-
      Converts between cpptraj compatible trajectory file formats and/or extracting a selection of atoms or frames.
    #run: /path/to/biobb_adapters/cpptraj_convert.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/cpptraj_convert.cwl
    in:
      config: step24_cpptraj_convert_config
      input_top_path: step22_imod_imc/output_traj_path
      input_traj_path: step22_imod_imc/output_traj_path
      output_cpptraj_path: step24_cpptraj_convert_output_cpptraj_path
    out:
    - output_cpptraj_path
  # NOLB & IMODS WORK

  step26_make_ndx:
    label: make_ndx
    doc: |-
      Creates a GROMACS index file (NDX) from an input selection and an input GROMACS structure file.
    #run: /path/to/biobb_adapters/biobb_adapters/cwl/biobb_gromacs/make_ndx.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/make_ndx.cwl
    in:
      config: step26_make_ndx_config
      input_structure_path: step3_cpptraj_mask/output_cpptraj_path
      output_ndx_path: step26_make_ndx_output_ndx_path
    out:
    - output_ndx_path
  step27_gmx_cluster:
    label: gmx_cluster
    doc: |-
      Clusters structures from a given GROMACS compatible trajectory.
    #run: /path/to/biobb_adapters/gmx_cluster.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/gmx_cluster.cwl
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
    doc: |-
      Calculates the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
    #run: /path/to/biobb_adapters/cpptraj_rms.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/cpptraj_rms.cwl
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
    doc: |-
      Compress MD simulation trajectories with PCA suite.
    #run: /path/to/biobb_adapters/pcz_zip.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/pcz_zip.cwl
    in:
      config: step29_pcz_zip_config
      input_pdb_path: step3_cpptraj_mask/output_cpptraj_path
      input_crd_path: step28_cpptraj_rms/output_traj_path
      output_pcz_path: step29_pcz_zip_output_pcz_path
    out:
    - output_pcz_path
  step30_pcz_zip:
    label: pcz_zip
    doc: |-
      Compress MD simulation trajectories with PCA suite.
    #run: /path/to/biobb_adapters/pcz_zip.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/pcz_zip.cwl
    in:
      config: step30_pcz_zip_config
      input_pdb_path: step3_cpptraj_mask/output_cpptraj_path
      input_crd_path: step28_cpptraj_rms/output_traj_path
      output_pcz_path: step30_pcz_zip_output_pcz_path
    out:
    - output_pcz_path
  step31_pcz_info:
    label: pcz_info
    doc: |-
      Extract PCA info (variance, Dimensionality) from a compressed PCZ file.
    #run: /path/to/biobb_adapters/pcz_info.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/pcz_info.cwl
    in:
      input_pcz_path: step29_pcz_zip/output_pcz_path
      output_json_path: step31_pcz_info_output_json_path
    out:
    - output_json_path
  step32_pcz_evecs:
    label: pcz_evecs
    doc: |-
      Extract PCA Eigen Vectors from a compressed PCZ file.
    #run: /path/to/biobb_adapters/pcz_evecs.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/pcz_evecs.cwl
    in:
      config: step32_pcz_evecs_config
      input_pcz_path: step29_pcz_zip/output_pcz_path
      output_json_path: step32_pcz_evecs_output_json_path
    out:
    - output_json_path
  step33_pcz_animate:
    label: pcz_animate
    doc: |-
      Extract PCA animations from a compressed PCZ file.
    #run: /path/to/biobb_adapters/pcz_animate.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/pcz_animate.cwl
    in:
      config: step33_pcz_animate_config
      input_pcz_path: step29_pcz_zip/output_pcz_path
      output_crd_path: step33_pcz_animate_output_crd_path
    out:
    - output_crd_path
  step34_cpptraj_convert:
    label: cpptraj_convert
    doc: |-
      Converts between cpptraj compatible trajectory file formats and/or extracting a selection of atoms or frames.
    #run: /path/to/biobb_adapters/cpptraj_convert.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/cpptraj_convert.cwl
    in:
      config: step34_cpptraj_convert_config
      input_top_path: step3_cpptraj_mask/output_cpptraj_path
      input_traj_path: step33_pcz_animate/output_crd_path
      output_cpptraj_path: step34_cpptraj_convert_output_cpptraj_path
    out:
    - output_cpptraj_path
  step35_pcz_bfactor:
    label: pcz_bfactor
    doc: |-
      Extract residue bfactors x PCA mode from a compressed PCZ file.
    #run: /path/to/biobb_adapters/pcz_bfactor.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/pcz_bfactor.cwl
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
    doc: |-
      Compute possible hinge regions (residues around which large protein movements are organized) of a molecule from a compressed PCZ file.
    #run: /path/to/biobb_adapters/pcz_hinges.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/pcz_hinges.cwl
    in:
      config: step36_pcz_hinges_config
      input_pcz_path: step30_pcz_zip/output_pcz_path
      output_json_path: step36_pcz_hinges_output_json_path
    out:
    - output_json_path
  step37_pcz_hinges:
    label: pcz_hinges
    doc: |-
      Compute possible hinge regions (residues around which large protein movements are organized) of a molecule from a compressed PCZ file.
    #run: /path/to/biobb_adapters/pcz_hinges.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/pcz_hinges.cwl
    in:
      config: step37_pcz_hinges_config
      input_pcz_path: step30_pcz_zip/output_pcz_path
      output_json_path: step37_pcz_hinges_output_json_path
    out:
    - output_json_path
  step38_pcz_hinges:
    label: pcz_hinges
    doc: |-
      Compute possible hinge regions (residues around which large protein movements are organized) of a molecule from a compressed PCZ file.
    #run: /path/to/biobb_adapters/pcz_hinges.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/pcz_hinges.cwl
    in:
      config: step38_pcz_hinges_config
      input_pcz_path: step30_pcz_zip/output_pcz_path
      output_json_path: step38_pcz_hinges_output_json_path
    out:
    - output_json_path
  step39_pcz_stiffness:
    label: pcz_stiffness
    doc: |-
      Extract PCA stiffness from a compressed PCZ file.
    #run: /path/to/biobb_adapters/pcz_stiffness.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/pcz_stiffness.cwl
    in:
      config: step39_pcz_stiffness_config
      input_pcz_path: step29_pcz_zip/output_pcz_path
      output_json_path: step39_pcz_stiffness_output_json_path
    out:
    - output_json_path
  step40_pcz_collectivity:
    label: pcz_collectivity
    doc: |-
      Extract PCA collectivity (numerical measure of how many atoms are affected by a given mode) from a compressed PCZ file.
    #run: /path/to/biobb_adapters/pcz_collectivity.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_workflows/biobb_wf_flexdyn/cwl/biobb_adapters/pcz_collectivity.cwl
    in:
      config: step40_pcz_collectivity_config
      input_pcz_path: step29_pcz_zip/output_pcz_path
      output_json_path: step40_pcz_collectivity_output_json_path
    out:
    - output_json_path