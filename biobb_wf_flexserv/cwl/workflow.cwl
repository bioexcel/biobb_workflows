#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
label: Macromolecular Flexibility
doc: This tutorial aims to illustrate the process of generating protein conformational ensembles from 3D structures and analysing its molecular flexibility, step by step.
inputs:
  step0_extract_atoms_input_structure_path:
    label: Input file
    doc: Input structure file path.
    type: File
  step0_extract_atoms_output_structure_path:
    label: Output file
    doc: Output structure file path.
    type: string
  step0_extract_atoms_config:
    label: Config file
    doc: Configuration file for biobb_structure_utils.extract_atoms tool.
    type: string
  step1_bd_run_output_crd_path:
    label: Output file
    doc: Output ensemble.
    type: string
  step1_bd_run_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step1_bd_run_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.bd_run tool.
    type: string
  step2_cpptraj_rms_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed analysis.
    type: string
  step2_cpptraj_rms_output_traj_path:
    label: Output file
    doc: Path to the output processed trajectory.
    type: string
  step2_cpptraj_rms_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_rms tool.
    type: string
  step3_dmd_run_output_crd_path:
    label: Output file
    doc: Output ensemble.
    type: string
  step3_dmd_run_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step4_cpptraj_rms_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed analysis.
    type: string
  step4_cpptraj_rms_output_traj_path:
    label: Output file
    doc: Path to the output processed trajectory.
    type: string
  step4_cpptraj_rms_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_rms tool.
    type: string
  step5_nma_run_output_crd_path:
    label: Output file
    doc: Output ensemble.
    type: string
  step5_nma_run_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step5_nma_run_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.nma_run tool.
    type: string
  step6_cpptraj_rms_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed analysis.
    type: string
  step6_cpptraj_rms_output_traj_path:
    label: Output file
    doc: Path to the output processed trajectory.
    type: string
  step6_cpptraj_rms_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_rms tool.
    type: string
  step7_pcz_zip_output_pcz_path:
    label: Output file
    doc: Output compressed trajectory.
    type: string
  step7_pcz_zip_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.pcz_zip tool.
    type: string
  step8_pcz_zip_output_pcz_path:
    label: Output file
    doc: Output compressed trajectory.
    type: string
  step8_pcz_zip_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.pcz_zip tool.
    type: string
  step9_pcz_zip_output_pcz_path:
    label: Output file
    doc: Output compressed trajectory.
    type: string
  step9_pcz_zip_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.pcz_zip tool.
    type: string
  step10_pcz_unzip_output_crd_path:
    label: Output file
    doc: Output uncompressed trajectory.
    type: string
  step11_pcz_unzip_output_crd_path:
    label: Output file
    doc: Output uncompressed trajectory.
    type: string
  step12_pcz_unzip_output_crd_path:
    label: Output file
    doc: Output uncompressed trajectory.
    type: string
  step13_cpptraj_rms_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed analysis.
    type: string
  step13_cpptraj_rms_output_traj_path:
    label: Output file
    doc: Path to the output processed trajectory.
    type: string
  step13_cpptraj_rms_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_rms tool.
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
  step15_cpptraj_rms_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed analysis.
    type: string
  step15_cpptraj_rms_output_traj_path:
    label: Output file
    doc: Path to the output processed trajectory.
    type: string
  step15_cpptraj_rms_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_rms tool.
    type: string
  step16_pcz_info_output_json_path:
    label: Output file
    doc: Output json file with PCA info such as number of components, variance and dimensionality.
    type: string
  step17_pcz_evecs_output_json_path:
    label: Output file
    doc: Output json file with PCA Eigen Vectors.
    type: string
  step17_pcz_evecs_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.pcz_evecs tool.
    type: string
  step18_pcz_animate_output_crd_path:
    label: Output file
    doc: Output PCA animated trajectory file.
    type: string
  step18_pcz_animate_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.pcz_animate tool.
    type: string
  step19_cpptraj_convert_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed trajectory.
    type: string
  step19_cpptraj_convert_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_convert tool.
    type: string
  step20_pcz_bfactor_output_dat_path:
    label: Output file
    doc: Output Bfactor x residue x PCA mode file.
    type: string
  step20_pcz_bfactor_output_pdb_path:
    label: Output file
    doc: Output PDB with Bfactor x residue x PCA mode file.
    type: string
  step20_pcz_bfactor_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.pcz_bfactor tool.
    type: string
  step21_pcz_hinges_output_json_path:
    label: Output file
    doc: Output hinge regions x PCA mode file.
    type: string
  step21_pcz_hinges_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.pcz_hinges tool.
    type: string
  step22_pcz_hinges_output_json_path:
    label: Output file
    doc: Output hinge regions x PCA mode file.
    type: string
  step22_pcz_hinges_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.pcz_hinges tool.
    type: string
  step23_pcz_hinges_output_json_path:
    label: Output file
    doc: Output hinge regions x PCA mode file.
    type: string
  step23_pcz_hinges_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.pcz_hinges tool.
    type: string
  step24_pcz_stiffness_output_json_path:
    label: Output file
    doc: Output json file with PCA Stiffness.
    type: string
  step24_pcz_stiffness_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.pcz_stiffness tool.
    type: string
  step25_pcz_collectivity_output_json_path:
    label: Output file
    doc: Output json file with PCA Collectivity indexes per mode.
    type: string
  step25_pcz_collectivity_config:
    label: Config file
    doc: Configuration file for biobb_flexserv.pcz_collectivity tool.
    type: string
  step26_pcz_similarity_input_pcz_path2:
    label: Input file
    doc: Input compressed trajectory file 2.
    type: File
  step26_pcz_similarity_output_json_path:
    label: Output file
    doc: Output json file with PCA Similarity results.
    type: string
  step27_pcz_similarity_input_pcz_path2:
    label: Input file
    doc: Input compressed trajectory file 2.
    type: File
  step27_pcz_similarity_output_json_path:
    label: Output file
    doc: Output json file with PCA Similarity results.
    type: string
  step28_pcz_similarity_input_pcz_path2:
    label: Input file
    doc: Input compressed trajectory file 2.
    type: File
  step28_pcz_similarity_output_json_path:
    label: Output file
    doc: Output json file with PCA Similarity results.
    type: string
outputs:
  step0_extract_atoms_out1:
    label: output_structure_path
    doc: Output structure file path.
    type: File
    outputSource: step0_extract_atoms/output_structure_path
  step1_bd_run_out1:
    label: output_crd_path
    doc: Output ensemble.
    type: File
    outputSource: step1_bd_run/output_crd_path
  step1_bd_run_out2:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step1_bd_run/output_log_path
  step2_cpptraj_rms_out1:
    label: output_cpptraj_path
    doc: Path to the output processed analysis.
    type: File
    outputSource: step2_cpptraj_rms/output_cpptraj_path
  step2_cpptraj_rms_out2:
    label: output_traj_path
    doc: Path to the output processed trajectory.
    type: File
    outputSource: step2_cpptraj_rms/output_traj_path
  step3_dmd_run_out1:
    label: output_crd_path
    doc: Output ensemble.
    type: File
    outputSource: step3_dmd_run/output_crd_path
  step3_dmd_run_out2:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step3_dmd_run/output_log_path
  step4_cpptraj_rms_out1:
    label: output_cpptraj_path
    doc: Path to the output processed analysis.
    type: File
    outputSource: step4_cpptraj_rms/output_cpptraj_path
  step4_cpptraj_rms_out2:
    label: output_traj_path
    doc: Path to the output processed trajectory.
    type: File
    outputSource: step4_cpptraj_rms/output_traj_path
  step5_nma_run_out1:
    label: output_crd_path
    doc: Output ensemble.
    type: File
    outputSource: step5_nma_run/output_crd_path
  step5_nma_run_out2:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step5_nma_run/output_log_path
  step6_cpptraj_rms_out1:
    label: output_cpptraj_path
    doc: Path to the output processed analysis.
    type: File
    outputSource: step6_cpptraj_rms/output_cpptraj_path
  step6_cpptraj_rms_out2:
    label: output_traj_path
    doc: Path to the output processed trajectory.
    type: File
    outputSource: step6_cpptraj_rms/output_traj_path
  step7_pcz_zip_out1:
    label: output_pcz_path
    doc: Output compressed trajectory.
    type: File
    outputSource: step7_pcz_zip/output_pcz_path
  step8_pcz_zip_out1:
    label: output_pcz_path
    doc: Output compressed trajectory.
    type: File
    outputSource: step8_pcz_zip/output_pcz_path
  step9_pcz_zip_out1:
    label: output_pcz_path
    doc: Output compressed trajectory.
    type: File
    outputSource: step9_pcz_zip/output_pcz_path
  step10_pcz_unzip_out1:
    label: output_crd_path
    doc: Output uncompressed trajectory.
    type: File
    outputSource: step10_pcz_unzip/output_crd_path
  step11_pcz_unzip_out1:
    label: output_crd_path
    doc: Output uncompressed trajectory.
    type: File
    outputSource: step11_pcz_unzip/output_crd_path
  step12_pcz_unzip_out1:
    label: output_crd_path
    doc: Output uncompressed trajectory.
    type: File
    outputSource: step12_pcz_unzip/output_crd_path
  step13_cpptraj_rms_out1:
    label: output_cpptraj_path
    doc: Path to the output processed analysis.
    type: File
    outputSource: step13_cpptraj_rms/output_cpptraj_path
  step13_cpptraj_rms_out2:
    label: output_traj_path
    doc: Path to the output processed trajectory.
    type: File
    outputSource: step13_cpptraj_rms/output_traj_path
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
  step15_cpptraj_rms_out1:
    label: output_cpptraj_path
    doc: Path to the output processed analysis.
    type: File
    outputSource: step15_cpptraj_rms/output_cpptraj_path
  step15_cpptraj_rms_out2:
    label: output_traj_path
    doc: Path to the output processed trajectory.
    type: File
    outputSource: step15_cpptraj_rms/output_traj_path
  step16_pcz_info_out1:
    label: output_json_path
    doc: Output json file with PCA info such as number of components, variance and dimensionality.
    type: File
    outputSource: step16_pcz_info/output_json_path
  step17_pcz_evecs_out1:
    label: output_json_path
    doc: Output json file with PCA Eigen Vectors.
    type: File
    outputSource: step17_pcz_evecs/output_json_path
  step18_pcz_animate_out1:
    label: output_crd_path
    doc: Output PCA animated trajectory file.
    type: File
    outputSource: step18_pcz_animate/output_crd_path
  step19_cpptraj_convert_out1:
    label: output_cpptraj_path
    doc: Path to the output processed trajectory.
    type: File
    outputSource: step19_cpptraj_convert/output_cpptraj_path
  step20_pcz_bfactor_out1:
    label: output_dat_path
    doc: Output Bfactor x residue x PCA mode file.
    type: File
    outputSource: step20_pcz_bfactor/output_dat_path
  step20_pcz_bfactor_out2:
    label: output_pdb_path
    doc: Output PDB with Bfactor x residue x PCA mode file.
    type: File
    outputSource: step20_pcz_bfactor/output_pdb_path
  step21_pcz_hinges_out1:
    label: output_json_path
    doc: Output hinge regions x PCA mode file.
    type: File
    outputSource: step21_pcz_hinges/output_json_path
  step22_pcz_hinges_out1:
    label: output_json_path
    doc: Output hinge regions x PCA mode file.
    type: File
    outputSource: step22_pcz_hinges/output_json_path
  step23_pcz_hinges_out1:
    label: output_json_path
    doc: Output hinge regions x PCA mode file.
    type: File
    outputSource: step23_pcz_hinges/output_json_path
  step24_pcz_stiffness_out1:
    label: output_json_path
    doc: Output json file with PCA Stiffness.
    type: File
    outputSource: step24_pcz_stiffness/output_json_path
  step25_pcz_collectivity_out1:
    label: output_json_path
    doc: Output json file with PCA Collectivity indexes per mode.
    type: File
    outputSource: step25_pcz_collectivity/output_json_path
  step26_pcz_similarity_out1:
    label: output_json_path
    doc: Output json file with PCA Similarity results.
    type: File
    outputSource: step26_pcz_similarity/output_json_path
  step27_pcz_similarity_out1:
    label: output_json_path
    doc: Output json file with PCA Similarity results.
    type: File
    outputSource: step27_pcz_similarity/output_json_path
  step28_pcz_similarity_out1:
    label: output_json_path
    doc: Output json file with PCA Similarity results.
    type: File
    outputSource: step28_pcz_similarity/output_json_path
steps:
  step0_extract_atoms:
    label: extract_atoms
    doc: Class to extract atoms from a 3D structure.
    run: biobb_adapters/extract_atoms.cwl
    in:
      config: step0_extract_atoms_config
      input_structure_path: step0_extract_atoms_input_structure_path
      output_structure_path: step0_extract_atoms_output_structure_path
    out:
    - output_structure_path
  step1_bd_run:
    label: bd_run
    doc: Run Brownian Dynamics from FlexServ
    run: biobb_adapters/bd_run.cwl
    in:
      config: step1_bd_run_config
      input_pdb_path: step0_extract_atoms/output_structure_path
      output_crd_path: step1_bd_run_output_crd_path
      output_log_path: step1_bd_run_output_log_path
    out:
    - output_crd_path
    - output_log_path
  step2_cpptraj_rms:
    label: cpptraj_rms
    doc: Wrapper of the Ambertools Cpptraj module for calculating the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
    run: biobb_adapters/cpptraj_rms.cwl
    in:
      config: step2_cpptraj_rms_config
      input_top_path: step0_extract_atoms/output_structure_path
      input_traj_path: step1_bd_run/output_crd_path
      output_cpptraj_path: step2_cpptraj_rms_output_cpptraj_path
      output_traj_path: step2_cpptraj_rms_output_traj_path
      input_exp_path: step0_extract_atoms/output_structure_path
    out:
    - output_cpptraj_path
    - output_traj_path
  step3_dmd_run:
    label: dmd_run
    doc: Run Discrete Molecular Dynamics from FlexServ
    run: biobb_adapters/dmd_run.cwl
    in:
      input_pdb_path: step0_extract_atoms/output_structure_path
      output_crd_path: step3_dmd_run_output_crd_path
      output_log_path: step3_dmd_run_output_log_path
    out:
    - output_crd_path
    - output_log_path
  step4_cpptraj_rms:
    label: cpptraj_rms
    doc: Wrapper of the Ambertools Cpptraj module for calculating the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
    run: biobb_adapters/cpptraj_rms.cwl
    in:
      config: step4_cpptraj_rms_config
      input_top_path: step0_extract_atoms/output_structure_path
      input_traj_path: step3_dmd_run/output_crd_path
      output_cpptraj_path: step4_cpptraj_rms_output_cpptraj_path
      output_traj_path: step4_cpptraj_rms_output_traj_path
      input_exp_path: step0_extract_atoms/output_structure_path
    out:
    - output_cpptraj_path
    - output_traj_path
  step5_nma_run:
    label: nma_run
    doc: Run Normal Mode Analysis from FlexServ
    run: biobb_adapters/nma_run.cwl
    in:
      config: step5_nma_run_config
      input_pdb_path: step0_extract_atoms/output_structure_path
      output_crd_path: step5_nma_run_output_crd_path
      output_log_path: step5_nma_run_output_log_path
    out:
    - output_crd_path
    - output_log_path
  step6_cpptraj_rms:
    label: cpptraj_rms
    doc: Wrapper of the Ambertools Cpptraj module for calculating the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
    run: biobb_adapters/cpptraj_rms.cwl
    in:
      config: step6_cpptraj_rms_config
      input_top_path: step0_extract_atoms/output_structure_path
      input_traj_path: step5_nma_run/output_crd_path
      output_cpptraj_path: step6_cpptraj_rms_output_cpptraj_path
      output_traj_path: step6_cpptraj_rms_output_traj_path
      input_exp_path: step0_extract_atoms/output_structure_path
    out:
    - output_cpptraj_path
    - output_traj_path
  step7_pcz_zip:
    label: pcz_zip
    doc: Compress MD simulation trajectories with PCA suite
    run: biobb_adapters/pcz_zip.cwl
    in:
      config: step7_pcz_zip_config
      input_pdb_path: step0_extract_atoms/output_structure_path
      input_crd_path: step1_bd_run/output_crd_path
      output_pcz_path: step7_pcz_zip_output_pcz_path
    out:
    - output_pcz_path
  step8_pcz_zip:
    label: pcz_zip
    doc: Compress MD simulation trajectories with PCA suite
    run: biobb_adapters/pcz_zip.cwl
    in:
      config: step8_pcz_zip_config
      input_pdb_path: step0_extract_atoms/output_structure_path
      input_crd_path: step3_dmd_run/output_crd_path
      output_pcz_path: step8_pcz_zip_output_pcz_path
    out:
    - output_pcz_path
  step9_pcz_zip:
    label: pcz_zip
    doc: Compress MD simulation trajectories with PCA suite
    run: biobb_adapters/pcz_zip.cwl
    in:
      config: step9_pcz_zip_config
      input_pdb_path: step0_extract_atoms/output_structure_path
      input_crd_path: step5_nma_run/output_crd_path
      output_pcz_path: step9_pcz_zip_output_pcz_path
    out:
    - output_pcz_path
  step10_pcz_unzip:
    label: pcz_unzip
    doc: Uncompress MD simulation trajectories with PCA suite
    run: biobb_adapters/pcz_unzip.cwl
    in:
      input_pcz_path: step7_pcz_zip/output_pcz_path
      output_crd_path: step10_pcz_unzip_output_crd_path
    out:
    - output_crd_path
  step11_pcz_unzip:
    label: pcz_unzip
    doc: Uncompress MD simulation trajectories with PCA suite
    run: biobb_adapters/pcz_unzip.cwl
    in:
      input_pcz_path: step8_pcz_zip/output_pcz_path
      output_crd_path: step11_pcz_unzip_output_crd_path
    out:
    - output_crd_path
  step12_pcz_unzip:
    label: pcz_unzip
    doc: Uncompress MD simulation trajectories with PCA suite
    run: biobb_adapters/pcz_unzip.cwl
    in:
      input_pcz_path: step9_pcz_zip/output_pcz_path
      output_crd_path: step12_pcz_unzip_output_crd_path
    out:
    - output_crd_path
  step13_cpptraj_rms:
    label: cpptraj_rms
    doc: Wrapper of the Ambertools Cpptraj module for calculating the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
    run: biobb_adapters/cpptraj_rms.cwl
    in:
      config: step13_cpptraj_rms_config
      input_top_path: step0_extract_atoms/output_structure_path
      input_traj_path: step10_pcz_unzip/output_crd_path
      output_cpptraj_path: step13_cpptraj_rms_output_cpptraj_path
      output_traj_path: step13_cpptraj_rms_output_traj_path
      input_exp_path: step0_extract_atoms/output_structure_path
    out:
    - output_cpptraj_path
    - output_traj_path
  step14_cpptraj_rms:
    label: cpptraj_rms
    doc: Wrapper of the Ambertools Cpptraj module for calculating the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
    run: biobb_adapters/cpptraj_rms.cwl
    in:
      config: step14_cpptraj_rms_config
      input_top_path: step0_extract_atoms/output_structure_path
      input_traj_path: step11_pcz_unzip/output_crd_path
      output_cpptraj_path: step14_cpptraj_rms_output_cpptraj_path
      output_traj_path: step14_cpptraj_rms_output_traj_path
      input_exp_path: step0_extract_atoms/output_structure_path
    out:
    - output_cpptraj_path
    - output_traj_path
  step15_cpptraj_rms:
    label: cpptraj_rms
    doc: Wrapper of the Ambertools Cpptraj module for calculating the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
    run: biobb_adapters/cpptraj_rms.cwl
    in:
      config: step15_cpptraj_rms_config
      input_top_path: step0_extract_atoms/output_structure_path
      input_traj_path: step12_pcz_unzip/output_crd_path
      output_cpptraj_path: step15_cpptraj_rms_output_cpptraj_path
      output_traj_path: step15_cpptraj_rms_output_traj_path
      input_exp_path: step0_extract_atoms/output_structure_path
    out:
    - output_cpptraj_path
    - output_traj_path
  step16_pcz_info:
    label: pcz_info
    doc: Extract PCA info (variance, Dimensionality) from a compressed PCZ file
    run: biobb_adapters/pcz_info.cwl
    in:
      input_pcz_path: step9_pcz_zip/output_pcz_path
      output_json_path: step16_pcz_info_output_json_path
    out:
    - output_json_path
  step17_pcz_evecs:
    label: pcz_evecs
    doc: Extract PCA Eigen Vectors from a compressed PCZ file
    run: biobb_adapters/pcz_evecs.cwl
    in:
      config: step17_pcz_evecs_config
      input_pcz_path: step9_pcz_zip/output_pcz_path
      output_json_path: step17_pcz_evecs_output_json_path
    out:
    - output_json_path
  step18_pcz_animate:
    label: pcz_animate
    doc: Extract PCA animations from a compressed PCZ file
    run: biobb_adapters/pcz_animate.cwl
    in:
      config: step18_pcz_animate_config
      input_pcz_path: step9_pcz_zip/output_pcz_path
      output_crd_path: step18_pcz_animate_output_crd_path
    out:
    - output_crd_path
  step19_cpptraj_convert:
    label: cpptraj_convert
    doc: Wrapper of the Ambertools Cpptraj module for converting between cpptraj compatible trajectory file formats and/or extracting a selection of atoms or frames.
    run: biobb_adapters/cpptraj_convert.cwl
    in:
      config: step19_cpptraj_convert_config
      input_top_path: step0_extract_atoms/output_structure_path
      input_traj_path: step18_pcz_animate/output_crd_path
      output_cpptraj_path: step19_cpptraj_convert_output_cpptraj_path
    out:
    - output_cpptraj_path
  step20_pcz_bfactor:
    label: pcz_bfactor
    doc: Extract residue bfactors x PCA mode from a compressed PCZ file
    run: biobb_adapters/pcz_bfactor.cwl
    in:
      config: step20_pcz_bfactor_config
      input_pcz_path: step9_pcz_zip/output_pcz_path
      output_dat_path: step20_pcz_bfactor_output_dat_path
      output_pdb_path: step20_pcz_bfactor_output_pdb_path
    out:
    - output_dat_path
    - output_pdb_path
  step21_pcz_hinges:
    label: pcz_hinges
    doc: Compute possible hinge regions (residues around which large protein movements are organized) of a molecule from a compressed PCZ file
    run: biobb_adapters/pcz_hinges.cwl
    in:
      config: step21_pcz_hinges_config
      input_pcz_path: step7_pcz_zip/output_pcz_path
      output_json_path: step21_pcz_hinges_output_json_path
    out:
    - output_json_path
  step22_pcz_hinges:
    label: pcz_hinges
    doc: Compute possible hinge regions (residues around which large protein movements are organized) of a molecule from a compressed PCZ file
    run: biobb_adapters/pcz_hinges.cwl
    in:
      config: step22_pcz_hinges_config
      input_pcz_path: step7_pcz_zip/output_pcz_path
      output_json_path: step22_pcz_hinges_output_json_path
    out:
    - output_json_path
  step23_pcz_hinges:
    label: pcz_hinges
    doc: Compute possible hinge regions (residues around which large protein movements are organized) of a molecule from a compressed PCZ file
    run: biobb_adapters/pcz_hinges.cwl
    in:
      config: step23_pcz_hinges_config
      input_pcz_path: step7_pcz_zip/output_pcz_path
      output_json_path: step23_pcz_hinges_output_json_path
    out:
    - output_json_path
  step24_pcz_stiffness:
    label: pcz_stiffness
    doc: Extract PCA stiffness from a compressed PCZ file
    run: biobb_adapters/pcz_stiffness.cwl
    in:
      config: step24_pcz_stiffness_config
      input_pcz_path: step9_pcz_zip/output_pcz_path
      output_json_path: step24_pcz_stiffness_output_json_path
    out:
    - output_json_path
  step25_pcz_collectivity:
    label: pcz_collectivity
    doc: Extract PCA collectivity (numerical measure of how many atoms are affected by a given mode) from a compressed PCZ file
    run: biobb_adapters/pcz_collectivity.cwl
    in:
      config: step25_pcz_collectivity_config
      input_pcz_path: step9_pcz_zip/output_pcz_path
      output_json_path: step25_pcz_collectivity_output_json_path
    out:
    - output_json_path
  step26_pcz_similarity:
    label: pcz_similarity
    doc: Compute PCA similarity between two given compressed PCZ files
    run: biobb_adapters/pcz_similarity.cwl
    in:
      input_pcz_path1: step7_pcz_zip/output_pcz_path
      input_pcz_path2: step26_pcz_similarity_input_pcz_path2
      output_json_path: step26_pcz_similarity_output_json_path
    out:
    - output_json_path
  step27_pcz_similarity:
    label: pcz_similarity
    doc: Compute PCA similarity between two given compressed PCZ files
    run: biobb_adapters/pcz_similarity.cwl
    in:
      input_pcz_path1: step8_pcz_zip/output_pcz_path
      input_pcz_path2: step27_pcz_similarity_input_pcz_path2
      output_json_path: step27_pcz_similarity_output_json_path
    out:
    - output_json_path
  step28_pcz_similarity:
    label: pcz_similarity
    doc: Compute PCA similarity between two given compressed PCZ files
    run: biobb_adapters/pcz_similarity.cwl
    in:
      input_pcz_path1: step9_pcz_zip/output_pcz_path
      input_pcz_path2: step28_pcz_similarity_input_pcz_path2
      output_json_path: step28_pcz_similarity_output_json_path
    out:
    - output_json_path
