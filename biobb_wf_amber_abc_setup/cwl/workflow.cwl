#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
label: ABC MD Setup pipeline
doc: |-
  This workflow provides a pipeline to setup DNA structures following the recommended guidelines by the Ascona B-DNA Consortium (ABC) members. It follows the work started with the NAFlex tool to offer a single, reproducible pipeline for structure preparation, ensuring reproducibility and coherence between all the members of the consortium.
inputs:
  step1_leap_gen_top_input_pdb_path:
    label: Input file
    doc: Input 3D structure PDB file.
    type: File
  step1_leap_gen_top_output_pdb_path:
    label: Output file
    doc: Output 3D structure PDB file matching the topology file.
    type: string
  step1_leap_gen_top_output_top_path:
    label: Output file
    doc: Output topology file (AMBER ParmTop).
    type: string
  step1_leap_gen_top_output_crd_path:
    label: Output file
    doc: Output coordinates file (AMBER crd).
    type: string
  step1_leap_gen_top_config:
    label: Config file
    doc: Configuration file for biobb_amber.leap_gen_top tool.
    type: string
  step2_leap_solvate_output_pdb_path:
    label: Output file
    doc: Output 3D structure PDB file matching the topology file.
    type: string
  step2_leap_solvate_output_top_path:
    label: Output file
    doc: Output topology file (AMBER ParmTop).
    type: string
  step2_leap_solvate_output_crd_path:
    label: Output file
    doc: Output coordinates file (AMBER crd).
    type: string
  step2_leap_solvate_config:
    label: Config file
    doc: Configuration file for biobb_amber.leap_solvate tool.
    type: string
  step3_leap_add_ions_output_pdb_path:
    label: Output file
    doc: Output 3D structure PDB file matching the topology file.
    type: string
  step3_leap_add_ions_output_top_path:
    label: Output file
    doc: Output topology file (AMBER ParmTop).
    type: string
  step3_leap_add_ions_output_crd_path:
    label: Output file
    doc: Output coordinates file (AMBER crd).
    type: string
  step3_leap_add_ions_config:
    label: Config file
    doc: Configuration file for biobb_amber.leap_add_ions tool.
    type: string
  step4_cpptraj_randomize_ions_output_pdb_path:
    label: Output file
    doc: Structure PDB file with randomized ions.
    type: string
  step4_cpptraj_randomize_ions_output_crd_path:
    label: Output file
    doc: Structure CRD file with coordinates including randomized ions.
    type: string
  step4_cpptraj_randomize_ions_config:
    label: Config file
    doc: Configuration file for biobb_amber.cpptraj_randomize_ions tool.
    type: string
  step5_parmed_hmassrepartition_output_top_path:
    label: Output file
    doc: Output topology file (AMBER ParmTop).
    type: string
  step6_sander_mdrun_eq1_input_mdin_path:
    label: Input file
    doc: Input configuration file (MD run options) (AMBER mdin).
    type: File
  step6_sander_mdrun_eq1_output_traj_path:
    label: Output file
    doc: Output trajectory file.
    type: string
  step6_sander_mdrun_eq1_output_rst_path:
    label: Output file
    doc: Output restart file.
    type: string
  step6_sander_mdrun_eq1_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step6_sander_mdrun_eq1_output_mdinfo_path:
    label: Output file
    doc: Output MD info.
    type: string
  step6_sander_mdrun_eq1_config:
    label: Config file
    doc: Configuration file for biobb_amber.sander_mdrun tool.
    type: string
  step7_process_minout_eq1_output_dat_path:
    label: Output file
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: string
  step7_process_minout_eq1_config:
    label: Config file
    doc: Configuration file for biobb_amber.process_minout tool.
    type: string
  step8_sander_mdrun_eq2_input_mdin_path:
    label: Input file
    doc: Input configuration file (MD run options) (AMBER mdin).
    type: File
  step8_sander_mdrun_eq2_output_traj_path:
    label: Output file
    doc: Output trajectory file.
    type: string
  step8_sander_mdrun_eq2_output_rst_path:
    label: Output file
    doc: Output restart file.
    type: string
  step8_sander_mdrun_eq2_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step8_sander_mdrun_eq2_output_mdinfo_path:
    label: Output file
    doc: Output MD info.
    type: string
  step8_sander_mdrun_eq2_config:
    label: Config file
    doc: Configuration file for biobb_amber.sander_mdrun tool.
    type: string
  step9_process_mdout_eq2_output_dat_path:
    label: Output file
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: string
  step9_process_mdout_eq2_config:
    label: Config file
    doc: Configuration file for biobb_amber.process_mdout tool.
    type: string
  step10_sander_mdrun_eq3_input_mdin_path:
    label: Input file
    doc: Input configuration file (MD run options) (AMBER mdin).
    type: File
  step10_sander_mdrun_eq3_output_traj_path:
    label: Output file
    doc: Output trajectory file.
    type: string
  step10_sander_mdrun_eq3_output_rst_path:
    label: Output file
    doc: Output restart file.
    type: string
  step10_sander_mdrun_eq3_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step10_sander_mdrun_eq3_output_mdinfo_path:
    label: Output file
    doc: Output MD info.
    type: string
  step10_sander_mdrun_eq3_config:
    label: Config file
    doc: Configuration file for biobb_amber.sander_mdrun tool.
    type: string
  step11_process_minout_eq3_output_dat_path:
    label: Output file
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: string
  step11_process_minout_eq3_config:
    label: Config file
    doc: Configuration file for biobb_amber.process_minout tool.
    type: string
  step12_sander_mdrun_eq4_input_mdin_path:
    label: Input file
    doc: Input configuration file (MD run options) (AMBER mdin).
    type: File
  step12_sander_mdrun_eq4_output_traj_path:
    label: Output file
    doc: Output trajectory file.
    type: string
  step12_sander_mdrun_eq4_output_rst_path:
    label: Output file
    doc: Output restart file.
    type: string
  step12_sander_mdrun_eq4_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step12_sander_mdrun_eq4_output_mdinfo_path:
    label: Output file
    doc: Output MD info.
    type: string
  step12_sander_mdrun_eq4_config:
    label: Config file
    doc: Configuration file for biobb_amber.sander_mdrun tool.
    type: string
  step13_process_minout_eq4_output_dat_path:
    label: Output file
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: string
  step13_process_minout_eq4_config:
    label: Config file
    doc: Configuration file for biobb_amber.process_minout tool.
    type: string
  step14_sander_mdrun_eq5_input_mdin_path:
    label: Input file
    doc: Input configuration file (MD run options) (AMBER mdin).
    type: File
  step14_sander_mdrun_eq5_output_traj_path:
    label: Output file
    doc: Output trajectory file.
    type: string
  step14_sander_mdrun_eq5_output_rst_path:
    label: Output file
    doc: Output restart file.
    type: string
  step14_sander_mdrun_eq5_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step14_sander_mdrun_eq5_output_mdinfo_path:
    label: Output file
    doc: Output MD info.
    type: string
  step14_sander_mdrun_eq5_config:
    label: Config file
    doc: Configuration file for biobb_amber.sander_mdrun tool.
    type: string
  step15_process_minout_eq5_output_dat_path:
    label: Output file
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: string
  step15_process_minout_eq5_config:
    label: Config file
    doc: Configuration file for biobb_amber.process_minout tool.
    type: string
  step16_sander_mdrun_eq6_input_mdin_path:
    label: Input file
    doc: Input configuration file (MD run options) (AMBER mdin).
    type: File
  step16_sander_mdrun_eq6_output_traj_path:
    label: Output file
    doc: Output trajectory file.
    type: string
  step16_sander_mdrun_eq6_output_rst_path:
    label: Output file
    doc: Output restart file.
    type: string
  step16_sander_mdrun_eq6_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step16_sander_mdrun_eq6_output_mdinfo_path:
    label: Output file
    doc: Output MD info.
    type: string
  step16_sander_mdrun_eq6_config:
    label: Config file
    doc: Configuration file for biobb_amber.sander_mdrun tool.
    type: string
  step17_process_mdout_eq6_output_dat_path:
    label: Output file
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: string
  step17_process_mdout_eq6_config:
    label: Config file
    doc: Configuration file for biobb_amber.process_mdout tool.
    type: string
  step18_sander_mdrun_eq7_input_mdin_path:
    label: Input file
    doc: Input configuration file (MD run options) (AMBER mdin).
    type: File
  step18_sander_mdrun_eq7_output_traj_path:
    label: Output file
    doc: Output trajectory file.
    type: string
  step18_sander_mdrun_eq7_output_rst_path:
    label: Output file
    doc: Output restart file.
    type: string
  step18_sander_mdrun_eq7_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step18_sander_mdrun_eq7_output_mdinfo_path:
    label: Output file
    doc: Output MD info.
    type: string
  step18_sander_mdrun_eq7_config:
    label: Config file
    doc: Configuration file for biobb_amber.sander_mdrun tool.
    type: string
  step19_process_mdout_eq7_output_dat_path:
    label: Output file
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: string
  step19_process_mdout_eq7_config:
    label: Config file
    doc: Configuration file for biobb_amber.process_mdout tool.
    type: string
  step20_sander_mdrun_eq8_input_mdin_path:
    label: Input file
    doc: Input configuration file (MD run options) (AMBER mdin).
    type: File
  step20_sander_mdrun_eq8_output_traj_path:
    label: Output file
    doc: Output trajectory file.
    type: string
  step20_sander_mdrun_eq8_output_rst_path:
    label: Output file
    doc: Output restart file.
    type: string
  step20_sander_mdrun_eq8_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step20_sander_mdrun_eq8_output_mdinfo_path:
    label: Output file
    doc: Output MD info.
    type: string
  step20_sander_mdrun_eq8_config:
    label: Config file
    doc: Configuration file for biobb_amber.sander_mdrun tool.
    type: string
  step21_process_mdout_eq8_output_dat_path:
    label: Output file
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: string
  step21_process_mdout_eq8_config:
    label: Config file
    doc: Configuration file for biobb_amber.process_mdout tool.
    type: string
  step22_sander_mdrun_eq9_input_mdin_path:
    label: Input file
    doc: Input configuration file (MD run options) (AMBER mdin).
    type: File
  step22_sander_mdrun_eq9_output_traj_path:
    label: Output file
    doc: Output trajectory file.
    type: string
  step22_sander_mdrun_eq9_output_rst_path:
    label: Output file
    doc: Output restart file.
    type: string
  step22_sander_mdrun_eq9_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step22_sander_mdrun_eq9_output_mdinfo_path:
    label: Output file
    doc: Output MD info.
    type: string
  step22_sander_mdrun_eq9_config:
    label: Config file
    doc: Configuration file for biobb_amber.sander_mdrun tool.
    type: string
  step23_process_mdout_eq9_output_dat_path:
    label: Output file
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: string
  step23_process_mdout_eq9_config:
    label: Config file
    doc: Configuration file for biobb_amber.process_mdout tool.
    type: string
  step24_sander_mdrun_eq10_input_mdin_path:
    label: Input file
    doc: Input configuration file (MD run options) (AMBER mdin).
    type: File
  step24_sander_mdrun_eq10_output_traj_path:
    label: Output file
    doc: Output trajectory file.
    type: string
  step24_sander_mdrun_eq10_output_rst_path:
    label: Output file
    doc: Output restart file.
    type: string
  step24_sander_mdrun_eq10_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step24_sander_mdrun_eq10_output_mdinfo_path:
    label: Output file
    doc: Output MD info.
    type: string
  step24_sander_mdrun_eq10_config:
    label: Config file
    doc: Configuration file for biobb_amber.sander_mdrun tool.
    type: string
  step25_process_mdout_eq10_output_dat_path:
    label: Output file
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: string
  step25_process_mdout_eq10_config:
    label: Config file
    doc: Configuration file for biobb_amber.process_mdout tool.
    type: string
  step26_sander_mdrun_md_input_mdin_path:
    label: Input file
    doc: Input configuration file (MD run options) (AMBER mdin).
    type: File
  step26_sander_mdrun_md_output_traj_path:
    label: Output file
    doc: Output trajectory file.
    type: string
  step26_sander_mdrun_md_output_rst_path:
    label: Output file
    doc: Output restart file.
    type: string
  step26_sander_mdrun_md_output_mdinfo_path:
    label: Output file
    doc: Output MD info.
    type: string
  step26_sander_mdrun_md_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step26_sander_mdrun_md_config:
    label: Config file
    doc: Configuration file for biobb_amber.sander_mdrun tool.
    type: string
  step27_rmsd_first_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed analysis.
    type: string
  step27_rmsd_first_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_rms tool.
    type: string
  step28_rmsd_exp_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed analysis.
    type: string
  step28_rmsd_exp_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_rms tool.
    type: string
  step29_cpptraj_rgyr_output_cpptraj_path:
    label: Output file
    doc: Path to the output analysis.
    type: string
  step29_cpptraj_rgyr_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_rgyr tool.
    type: string
  step30_cpptraj_image_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed trajectory.
    type: string
  step30_cpptraj_image_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_image tool.
    type: string
outputs:
  step1_leap_gen_top_out1:
    label: output_pdb_path
    doc: Output 3D structure PDB file matching the topology file.
    type: File
    outputSource: step1_leap_gen_top/output_pdb_path
  step1_leap_gen_top_out2:
    label: output_top_path
    doc: Output topology file (AMBER ParmTop).
    type: File
    outputSource: step1_leap_gen_top/output_top_path
  step1_leap_gen_top_out3:
    label: output_crd_path
    doc: Output coordinates file (AMBER crd).
    type: File
    outputSource: step1_leap_gen_top/output_crd_path
  step2_leap_solvate_out1:
    label: output_pdb_path
    doc: Output 3D structure PDB file matching the topology file.
    type: File
    outputSource: step2_leap_solvate/output_pdb_path
  step2_leap_solvate_out2:
    label: output_top_path
    doc: Output topology file (AMBER ParmTop).
    type: File
    outputSource: step2_leap_solvate/output_top_path
  step2_leap_solvate_out3:
    label: output_crd_path
    doc: Output coordinates file (AMBER crd).
    type: File
    outputSource: step2_leap_solvate/output_crd_path
  step3_leap_add_ions_out1:
    label: output_pdb_path
    doc: Output 3D structure PDB file matching the topology file.
    type: File
    outputSource: step3_leap_add_ions/output_pdb_path
  step3_leap_add_ions_out2:
    label: output_top_path
    doc: Output topology file (AMBER ParmTop).
    type: File
    outputSource: step3_leap_add_ions/output_top_path
  step3_leap_add_ions_out3:
    label: output_crd_path
    doc: Output coordinates file (AMBER crd).
    type: File
    outputSource: step3_leap_add_ions/output_crd_path
  step4_cpptraj_randomize_ions_out1:
    label: output_pdb_path
    doc: Structure PDB file with randomized ions.
    type: File
    outputSource: step4_cpptraj_randomize_ions/output_pdb_path
  step4_cpptraj_randomize_ions_out2:
    label: output_crd_path
    doc: Structure CRD file with coordinates including randomized ions.
    type: File
    outputSource: step4_cpptraj_randomize_ions/output_crd_path
  step5_parmed_hmassrepartition_out1:
    label: output_top_path
    doc: Output topology file (AMBER ParmTop).
    type: File
    outputSource: step5_parmed_hmassrepartition/output_top_path
  step6_sander_mdrun_eq1_out1:
    label: output_traj_path
    doc: Output trajectory file.
    type: File
    outputSource: step6_sander_mdrun_eq1/output_traj_path
  step6_sander_mdrun_eq1_out2:
    label: output_rst_path
    doc: Output restart file.
    type: File
    outputSource: step6_sander_mdrun_eq1/output_rst_path
  step6_sander_mdrun_eq1_out3:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step6_sander_mdrun_eq1/output_log_path
  step6_sander_mdrun_eq1_out4:
    label: output_mdinfo_path
    doc: Output MD info.
    type: File
    outputSource: step6_sander_mdrun_eq1/output_mdinfo_path
  step7_process_minout_eq1_out1:
    label: output_dat_path
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: File
    outputSource: step7_process_minout_eq1/output_dat_path
  step8_sander_mdrun_eq2_out1:
    label: output_traj_path
    doc: Output trajectory file.
    type: File
    outputSource: step8_sander_mdrun_eq2/output_traj_path
  step8_sander_mdrun_eq2_out2:
    label: output_rst_path
    doc: Output restart file.
    type: File
    outputSource: step8_sander_mdrun_eq2/output_rst_path
  step8_sander_mdrun_eq2_out3:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step8_sander_mdrun_eq2/output_log_path
  step8_sander_mdrun_eq2_out4:
    label: output_mdinfo_path
    doc: Output MD info.
    type: File
    outputSource: step8_sander_mdrun_eq2/output_mdinfo_path
  step9_process_mdout_eq2_out1:
    label: output_dat_path
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: File
    outputSource: step9_process_mdout_eq2/output_dat_path
  step10_sander_mdrun_eq3_out1:
    label: output_traj_path
    doc: Output trajectory file.
    type: File
    outputSource: step10_sander_mdrun_eq3/output_traj_path
  step10_sander_mdrun_eq3_out2:
    label: output_rst_path
    doc: Output restart file.
    type: File
    outputSource: step10_sander_mdrun_eq3/output_rst_path
  step10_sander_mdrun_eq3_out3:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step10_sander_mdrun_eq3/output_log_path
  step10_sander_mdrun_eq3_out4:
    label: output_mdinfo_path
    doc: Output MD info.
    type: File
    outputSource: step10_sander_mdrun_eq3/output_mdinfo_path
  step11_process_minout_eq3_out1:
    label: output_dat_path
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: File
    outputSource: step11_process_minout_eq3/output_dat_path
  step12_sander_mdrun_eq4_out1:
    label: output_traj_path
    doc: Output trajectory file.
    type: File
    outputSource: step12_sander_mdrun_eq4/output_traj_path
  step12_sander_mdrun_eq4_out2:
    label: output_rst_path
    doc: Output restart file.
    type: File
    outputSource: step12_sander_mdrun_eq4/output_rst_path
  step12_sander_mdrun_eq4_out3:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step12_sander_mdrun_eq4/output_log_path
  step12_sander_mdrun_eq4_out4:
    label: output_mdinfo_path
    doc: Output MD info.
    type: File
    outputSource: step12_sander_mdrun_eq4/output_mdinfo_path
  step13_process_minout_eq4_out1:
    label: output_dat_path
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: File
    outputSource: step13_process_minout_eq4/output_dat_path
  step14_sander_mdrun_eq5_out1:
    label: output_traj_path
    doc: Output trajectory file.
    type: File
    outputSource: step14_sander_mdrun_eq5/output_traj_path
  step14_sander_mdrun_eq5_out2:
    label: output_rst_path
    doc: Output restart file.
    type: File
    outputSource: step14_sander_mdrun_eq5/output_rst_path
  step14_sander_mdrun_eq5_out3:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step14_sander_mdrun_eq5/output_log_path
  step14_sander_mdrun_eq5_out4:
    label: output_mdinfo_path
    doc: Output MD info.
    type: File
    outputSource: step14_sander_mdrun_eq5/output_mdinfo_path
  step15_process_minout_eq5_out1:
    label: output_dat_path
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: File
    outputSource: step15_process_minout_eq5/output_dat_path
  step16_sander_mdrun_eq6_out1:
    label: output_traj_path
    doc: Output trajectory file.
    type: File
    outputSource: step16_sander_mdrun_eq6/output_traj_path
  step16_sander_mdrun_eq6_out2:
    label: output_rst_path
    doc: Output restart file.
    type: File
    outputSource: step16_sander_mdrun_eq6/output_rst_path
  step16_sander_mdrun_eq6_out3:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step16_sander_mdrun_eq6/output_log_path
  step16_sander_mdrun_eq6_out4:
    label: output_mdinfo_path
    doc: Output MD info.
    type: File
    outputSource: step16_sander_mdrun_eq6/output_mdinfo_path
  step17_process_mdout_eq6_out1:
    label: output_dat_path
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: File
    outputSource: step17_process_mdout_eq6/output_dat_path
  step18_sander_mdrun_eq7_out1:
    label: output_traj_path
    doc: Output trajectory file.
    type: File
    outputSource: step18_sander_mdrun_eq7/output_traj_path
  step18_sander_mdrun_eq7_out2:
    label: output_rst_path
    doc: Output restart file.
    type: File
    outputSource: step18_sander_mdrun_eq7/output_rst_path
  step18_sander_mdrun_eq7_out3:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step18_sander_mdrun_eq7/output_log_path
  step18_sander_mdrun_eq7_out4:
    label: output_mdinfo_path
    doc: Output MD info.
    type: File
    outputSource: step18_sander_mdrun_eq7/output_mdinfo_path
  step19_process_mdout_eq7_out1:
    label: output_dat_path
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: File
    outputSource: step19_process_mdout_eq7/output_dat_path
  step20_sander_mdrun_eq8_out1:
    label: output_traj_path
    doc: Output trajectory file.
    type: File
    outputSource: step20_sander_mdrun_eq8/output_traj_path
  step20_sander_mdrun_eq8_out2:
    label: output_rst_path
    doc: Output restart file.
    type: File
    outputSource: step20_sander_mdrun_eq8/output_rst_path
  step20_sander_mdrun_eq8_out3:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step20_sander_mdrun_eq8/output_log_path
  step20_sander_mdrun_eq8_out4:
    label: output_mdinfo_path
    doc: Output MD info.
    type: File
    outputSource: step20_sander_mdrun_eq8/output_mdinfo_path
  step21_process_mdout_eq8_out1:
    label: output_dat_path
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: File
    outputSource: step21_process_mdout_eq8/output_dat_path
  step22_sander_mdrun_eq9_out1:
    label: output_traj_path
    doc: Output trajectory file.
    type: File
    outputSource: step22_sander_mdrun_eq9/output_traj_path
  step22_sander_mdrun_eq9_out2:
    label: output_rst_path
    doc: Output restart file.
    type: File
    outputSource: step22_sander_mdrun_eq9/output_rst_path
  step22_sander_mdrun_eq9_out3:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step22_sander_mdrun_eq9/output_log_path
  step22_sander_mdrun_eq9_out4:
    label: output_mdinfo_path
    doc: Output MD info.
    type: File
    outputSource: step22_sander_mdrun_eq9/output_mdinfo_path
  step23_process_mdout_eq9_out1:
    label: output_dat_path
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: File
    outputSource: step23_process_mdout_eq9/output_dat_path
  step24_sander_mdrun_eq10_out1:
    label: output_traj_path
    doc: Output trajectory file.
    type: File
    outputSource: step24_sander_mdrun_eq10/output_traj_path
  step24_sander_mdrun_eq10_out2:
    label: output_rst_path
    doc: Output restart file.
    type: File
    outputSource: step24_sander_mdrun_eq10/output_rst_path
  step24_sander_mdrun_eq10_out3:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step24_sander_mdrun_eq10/output_log_path
  step24_sander_mdrun_eq10_out4:
    label: output_mdinfo_path
    doc: Output MD info.
    type: File
    outputSource: step24_sander_mdrun_eq10/output_mdinfo_path
  step25_process_mdout_eq10_out1:
    label: output_dat_path
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: File
    outputSource: step25_process_mdout_eq10/output_dat_path
  step26_sander_mdrun_md_out1:
    label: output_traj_path
    doc: Output trajectory file.
    type: File
    outputSource: step26_sander_mdrun_md/output_traj_path
  step26_sander_mdrun_md_out2:
    label: output_rst_path
    doc: Output restart file.
    type: File
    outputSource: step26_sander_mdrun_md/output_rst_path
  step26_sander_mdrun_md_out3:
    label: output_mdinfo_path
    doc: Output MD info.
    type: File
    outputSource: step26_sander_mdrun_md/output_mdinfo_path
  step26_sander_mdrun_md_out4:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step26_sander_mdrun_md/output_log_path
  step27_rmsd_first_out1:
    label: output_cpptraj_path
    doc: Path to the output processed analysis.
    type: File
    outputSource: step27_rmsd_first/output_cpptraj_path
  step28_rmsd_exp_out1:
    label: output_cpptraj_path
    doc: Path to the output processed analysis.
    type: File
    outputSource: step28_rmsd_exp/output_cpptraj_path
  step29_cpptraj_rgyr_out1:
    label: output_cpptraj_path
    doc: Path to the output analysis.
    type: File
    outputSource: step29_cpptraj_rgyr/output_cpptraj_path
  step30_cpptraj_image_out1:
    label: output_cpptraj_path
    doc: Path to the output processed trajectory.
    type: File
    outputSource: step30_cpptraj_image/output_cpptraj_path
steps:
  step1_leap_gen_top:
    label: leap_gen_top
    doc: Generates a MD topology from a molecule structure using tLeap tool from the AmberTools MD package
    run: biobb_adapters/leap_gen_top.cwl
    in:
      config: step1_leap_gen_top_config
      input_pdb_path: step1_leap_gen_top_input_pdb_path
      output_pdb_path: step1_leap_gen_top_output_pdb_path
      output_top_path: step1_leap_gen_top_output_top_path
      output_crd_path: step1_leap_gen_top_output_crd_path
    out:
    - output_pdb_path
    - output_top_path
    - output_crd_path
  step2_leap_solvate:
    label: leap_solvate
    doc: Creates and solvates a system box for an AMBER MD system using tLeap tool from the AmberTools MD package
    run: biobb_adapters/leap_solvate.cwl
    in:
      config: step2_leap_solvate_config
      input_pdb_path: step1_leap_gen_top/output_pdb_path
      output_pdb_path: step2_leap_solvate_output_pdb_path
      output_top_path: step2_leap_solvate_output_top_path
      output_crd_path: step2_leap_solvate_output_crd_path
    out:
    - output_pdb_path
    - output_top_path
    - output_crd_path
  step3_leap_add_ions:
    label: leap_add_ions
    doc: Adds counterions to a system box for an AMBER MD system using tLeap tool from the AmberTools MD package
    run: biobb_adapters/leap_add_ions.cwl
    in:
      config: step3_leap_add_ions_config
      input_pdb_path: step2_leap_solvate/output_pdb_path
      output_pdb_path: step3_leap_add_ions_output_pdb_path
      output_top_path: step3_leap_add_ions_output_top_path
      output_crd_path: step3_leap_add_ions_output_crd_path
    out:
    - output_pdb_path
    - output_top_path
    - output_crd_path
  step4_cpptraj_randomize_ions:
    label: cpptraj_randomize_ions
    doc: Swap specified ions with randomly selected solvent molecules using cpptraj tool from the AmberTools MD package
    run: biobb_adapters/cpptraj_randomize_ions.cwl
    in:
      config: step4_cpptraj_randomize_ions_config
      input_top_path: step3_leap_add_ions/output_top_path
      input_crd_path: step3_leap_add_ions/output_crd_path
      output_pdb_path: step4_cpptraj_randomize_ions_output_pdb_path
      output_crd_path: step4_cpptraj_randomize_ions_output_crd_path
    out:
    - output_pdb_path
    - output_crd_path
  step5_parmed_hmassrepartition:
    label: parmed_hmassrepartition
    doc: Performs a Hydrogen Mass Repartition from an AMBER topology file using parmed tool from the AmberTools MD package
    run: biobb_adapters/parmed_hmassrepartition.cwl
    in:
      input_top_path: step3_leap_add_ions/output_top_path
      output_top_path: step5_parmed_hmassrepartition_output_top_path
    out:
    - output_top_path
  step6_sander_mdrun_eq1:
    label: sander_mdrun
    doc: Runs energy minimization, molecular dynamics, and NMR refinements using sander tool from the AmberTools MD package
    run: biobb_adapters/sander_mdrun.cwl
    in:
      config: step6_sander_mdrun_eq1_config
      input_top_path: step5_parmed_hmassrepartition/output_top_path
      input_mdin_path: step6_sander_mdrun_eq1_input_mdin_path
      input_crd_path: step4_cpptraj_randomize_ions/output_crd_path
      input_ref_path: step4_cpptraj_randomize_ions/output_crd_path
      output_traj_path: step6_sander_mdrun_eq1_output_traj_path
      output_rst_path: step6_sander_mdrun_eq1_output_rst_path
      output_log_path: step6_sander_mdrun_eq1_output_log_path
      output_mdinfo_path: step6_sander_mdrun_eq1_output_mdinfo_path
    out:
    - output_traj_path
    - output_rst_path
    - output_log_path
    - output_mdinfo_path
  step7_process_minout_eq1:
    label: process_minout
    doc: Parses the AMBER (sander) minimization output file (log) and dumps statistics that can then be plotted. Using the process_minout.pl tool from the AmberTools MD package
    run: biobb_adapters/process_minout.cwl
    in:
      config: step7_process_minout_eq1_config
      input_log_path: step6_sander_mdrun_eq1/output_log_path
      output_dat_path: step7_process_minout_eq1_output_dat_path
    out:
    - output_dat_path
  step8_sander_mdrun_eq2:
    label: sander_mdrun
    doc: Runs energy minimization, molecular dynamics, and NMR refinements using sander tool from the AmberTools MD package
    run: biobb_adapters/sander_mdrun.cwl
    in:
      config: step8_sander_mdrun_eq2_config
      input_top_path: step5_parmed_hmassrepartition/output_top_path
      input_mdin_path: step8_sander_mdrun_eq2_input_mdin_path
      input_crd_path: step6_sander_mdrun_eq1/output_rst_path
      input_ref_path: step6_sander_mdrun_eq1/output_rst_path
      output_traj_path: step8_sander_mdrun_eq2_output_traj_path
      output_rst_path: step8_sander_mdrun_eq2_output_rst_path
      output_log_path: step8_sander_mdrun_eq2_output_log_path
      output_mdinfo_path: step8_sander_mdrun_eq2_output_mdinfo_path
    out:
    - output_traj_path
    - output_rst_path
    - output_log_path
    - output_mdinfo_path
  step9_process_mdout_eq2:
    label: process_mdout
    doc: Parses the AMBER (sander) md output file (log) and dumps statistics that can then be plotted. Using the process_mdout.pl tool from the AmberTools MD package
    run: biobb_adapters/process_mdout.cwl
    in:
      config: step9_process_mdout_eq2_config
      input_log_path: step8_sander_mdrun_eq2/output_log_path
      output_dat_path: step9_process_mdout_eq2_output_dat_path
    out:
    - output_dat_path
  step10_sander_mdrun_eq3:
    label: sander_mdrun
    doc: Runs energy minimization, molecular dynamics, and NMR refinements using sander tool from the AmberTools MD package
    run: biobb_adapters/sander_mdrun.cwl
    in:
      config: step10_sander_mdrun_eq3_config
      input_top_path: step5_parmed_hmassrepartition/output_top_path
      input_mdin_path: step10_sander_mdrun_eq3_input_mdin_path
      input_crd_path: step8_sander_mdrun_eq2/output_rst_path
      input_ref_path: step8_sander_mdrun_eq2/output_rst_path
      output_traj_path: step10_sander_mdrun_eq3_output_traj_path
      output_rst_path: step10_sander_mdrun_eq3_output_rst_path
      output_log_path: step10_sander_mdrun_eq3_output_log_path
      output_mdinfo_path: step10_sander_mdrun_eq3_output_mdinfo_path
    out:
    - output_traj_path
    - output_rst_path
    - output_log_path
    - output_mdinfo_path
  step11_process_minout_eq3:
    label: process_minout
    doc: Parses the AMBER (sander) minimization output file (log) and dumps statistics that can then be plotted. Using the process_minout.pl tool from the AmberTools MD package
    run: biobb_adapters/process_minout.cwl
    in:
      config: step11_process_minout_eq3_config
      input_log_path: step10_sander_mdrun_eq3/output_log_path
      output_dat_path: step11_process_minout_eq3_output_dat_path
    out:
    - output_dat_path
  step12_sander_mdrun_eq4:
    label: sander_mdrun
    doc: Runs energy minimization, molecular dynamics, and NMR refinements using sander tool from the AmberTools MD package
    run: biobb_adapters/sander_mdrun.cwl
    in:
      config: step12_sander_mdrun_eq4_config
      input_top_path: step5_parmed_hmassrepartition/output_top_path
      input_mdin_path: step12_sander_mdrun_eq4_input_mdin_path
      input_crd_path: step10_sander_mdrun_eq3/output_rst_path
      input_ref_path: step10_sander_mdrun_eq3/output_rst_path
      output_traj_path: step12_sander_mdrun_eq4_output_traj_path
      output_rst_path: step12_sander_mdrun_eq4_output_rst_path
      output_log_path: step12_sander_mdrun_eq4_output_log_path
      output_mdinfo_path: step12_sander_mdrun_eq4_output_mdinfo_path
    out:
    - output_traj_path
    - output_rst_path
    - output_log_path
    - output_mdinfo_path
  step13_process_minout_eq4:
    label: process_minout
    doc: Parses the AMBER (sander) minimization output file (log) and dumps statistics that can then be plotted. Using the process_minout.pl tool from the AmberTools MD package
    run: biobb_adapters/process_minout.cwl
    in:
      config: step13_process_minout_eq4_config
      input_log_path: step12_sander_mdrun_eq4/output_log_path
      output_dat_path: step13_process_minout_eq4_output_dat_path
    out:
    - output_dat_path
  step14_sander_mdrun_eq5:
    label: sander_mdrun
    doc: Runs energy minimization, molecular dynamics, and NMR refinements using sander tool from the AmberTools MD package
    run: biobb_adapters/sander_mdrun.cwl
    in:
      config: step14_sander_mdrun_eq5_config
      input_top_path: step5_parmed_hmassrepartition/output_top_path
      input_mdin_path: step14_sander_mdrun_eq5_input_mdin_path
      input_crd_path: step12_sander_mdrun_eq4/output_rst_path
      input_ref_path: step12_sander_mdrun_eq4/output_rst_path
      output_traj_path: step14_sander_mdrun_eq5_output_traj_path
      output_rst_path: step14_sander_mdrun_eq5_output_rst_path
      output_log_path: step14_sander_mdrun_eq5_output_log_path
      output_mdinfo_path: step14_sander_mdrun_eq5_output_mdinfo_path
    out:
    - output_traj_path
    - output_rst_path
    - output_log_path
    - output_mdinfo_path
  step15_process_minout_eq5:
    label: process_minout
    doc: Parses the AMBER (sander) minimization output file (log) and dumps statistics that can then be plotted. Using the process_minout.pl tool from the AmberTools MD package
    run: biobb_adapters/process_minout.cwl
    in:
      config: step15_process_minout_eq5_config
      input_log_path: step14_sander_mdrun_eq5/output_log_path
      output_dat_path: step15_process_minout_eq5_output_dat_path
    out:
    - output_dat_path
  step16_sander_mdrun_eq6:
    label: sander_mdrun
    doc: Runs energy minimization, molecular dynamics, and NMR refinements using sander tool from the AmberTools MD package
    run: biobb_adapters/sander_mdrun.cwl
    in:
      config: step16_sander_mdrun_eq6_config
      input_top_path: step5_parmed_hmassrepartition/output_top_path
      input_mdin_path: step16_sander_mdrun_eq6_input_mdin_path
      input_crd_path: step14_sander_mdrun_eq5/output_rst_path
      input_ref_path: step14_sander_mdrun_eq5/output_rst_path
      output_traj_path: step16_sander_mdrun_eq6_output_traj_path
      output_rst_path: step16_sander_mdrun_eq6_output_rst_path
      output_log_path: step16_sander_mdrun_eq6_output_log_path
      output_mdinfo_path: step16_sander_mdrun_eq6_output_mdinfo_path
    out:
    - output_traj_path
    - output_rst_path
    - output_log_path
    - output_mdinfo_path
  step17_process_mdout_eq6:
    label: process_mdout
    doc: Parses the AMBER (sander) md output file (log) and dumps statistics that can then be plotted. Using the process_mdout.pl tool from the AmberTools MD package
    run: biobb_adapters/process_mdout.cwl
    in:
      config: step17_process_mdout_eq6_config
      input_log_path: step16_sander_mdrun_eq6/output_log_path
      output_dat_path: step17_process_mdout_eq6_output_dat_path
    out:
    - output_dat_path
  step18_sander_mdrun_eq7:
    label: sander_mdrun
    doc: Runs energy minimization, molecular dynamics, and NMR refinements using sander tool from the AmberTools MD package
    run: biobb_adapters/sander_mdrun.cwl
    in:
      config: step18_sander_mdrun_eq7_config
      input_top_path: step5_parmed_hmassrepartition/output_top_path
      input_mdin_path: step18_sander_mdrun_eq7_input_mdin_path
      input_crd_path: step16_sander_mdrun_eq6/output_rst_path
      input_ref_path: step16_sander_mdrun_eq6/output_rst_path
      output_traj_path: step18_sander_mdrun_eq7_output_traj_path
      output_rst_path: step18_sander_mdrun_eq7_output_rst_path
      output_log_path: step18_sander_mdrun_eq7_output_log_path
      output_mdinfo_path: step18_sander_mdrun_eq7_output_mdinfo_path
    out:
    - output_traj_path
    - output_rst_path
    - output_log_path
    - output_mdinfo_path
  step19_process_mdout_eq7:
    label: process_mdout
    doc: Parses the AMBER (sander) md output file (log) and dumps statistics that can then be plotted. Using the process_mdout.pl tool from the AmberTools MD package
    run: biobb_adapters/process_mdout.cwl
    in:
      config: step19_process_mdout_eq7_config
      input_log_path: step18_sander_mdrun_eq7/output_log_path
      output_dat_path: step19_process_mdout_eq7_output_dat_path
    out:
    - output_dat_path
  step20_sander_mdrun_eq8:
    label: sander_mdrun
    doc: Runs energy minimization, molecular dynamics, and NMR refinements using sander tool from the AmberTools MD package
    run: biobb_adapters/sander_mdrun.cwl
    in:
      config: step20_sander_mdrun_eq8_config
      input_top_path: step5_parmed_hmassrepartition/output_top_path
      input_mdin_path: step20_sander_mdrun_eq8_input_mdin_path
      input_crd_path: step18_sander_mdrun_eq7/output_rst_path
      input_ref_path: step18_sander_mdrun_eq7/output_rst_path
      output_traj_path: step20_sander_mdrun_eq8_output_traj_path
      output_rst_path: step20_sander_mdrun_eq8_output_rst_path
      output_log_path: step20_sander_mdrun_eq8_output_log_path
      output_mdinfo_path: step20_sander_mdrun_eq8_output_mdinfo_path
    out:
    - output_traj_path
    - output_rst_path
    - output_log_path
    - output_mdinfo_path
  step21_process_mdout_eq8:
    label: process_mdout
    doc: Parses the AMBER (sander) md output file (log) and dumps statistics that can then be plotted. Using the process_mdout.pl tool from the AmberTools MD package
    run: biobb_adapters/process_mdout.cwl
    in:
      config: step21_process_mdout_eq8_config
      input_log_path: step20_sander_mdrun_eq8/output_log_path
      output_dat_path: step21_process_mdout_eq8_output_dat_path
    out:
    - output_dat_path
  step22_sander_mdrun_eq9:
    label: sander_mdrun
    doc: Runs energy minimization, molecular dynamics, and NMR refinements using sander tool from the AmberTools MD package
    run: biobb_adapters/sander_mdrun.cwl
    in:
      config: step22_sander_mdrun_eq9_config
      input_top_path: step5_parmed_hmassrepartition/output_top_path
      input_mdin_path: step22_sander_mdrun_eq9_input_mdin_path
      input_crd_path: step20_sander_mdrun_eq8/output_rst_path
      input_ref_path: step20_sander_mdrun_eq8/output_rst_path
      output_traj_path: step22_sander_mdrun_eq9_output_traj_path
      output_rst_path: step22_sander_mdrun_eq9_output_rst_path
      output_log_path: step22_sander_mdrun_eq9_output_log_path
      output_mdinfo_path: step22_sander_mdrun_eq9_output_mdinfo_path
    out:
    - output_traj_path
    - output_rst_path
    - output_log_path
    - output_mdinfo_path
  step23_process_mdout_eq9:
    label: process_mdout
    doc: Parses the AMBER (sander) md output file (log) and dumps statistics that can then be plotted. Using the process_mdout.pl tool from the AmberTools MD package
    run: biobb_adapters/process_mdout.cwl
    in:
      config: step23_process_mdout_eq9_config
      input_log_path: step22_sander_mdrun_eq9/output_log_path
      output_dat_path: step23_process_mdout_eq9_output_dat_path
    out:
    - output_dat_path
  step24_sander_mdrun_eq10:
    label: sander_mdrun
    doc: Runs energy minimization, molecular dynamics, and NMR refinements using sander tool from the AmberTools MD package
    run: biobb_adapters/sander_mdrun.cwl
    in:
      config: step24_sander_mdrun_eq10_config
      input_top_path: step5_parmed_hmassrepartition/output_top_path
      input_mdin_path: step24_sander_mdrun_eq10_input_mdin_path
      input_crd_path: step22_sander_mdrun_eq9/output_rst_path
      input_ref_path: step22_sander_mdrun_eq9/output_rst_path
      output_traj_path: step24_sander_mdrun_eq10_output_traj_path
      output_rst_path: step24_sander_mdrun_eq10_output_rst_path
      output_log_path: step24_sander_mdrun_eq10_output_log_path
      output_mdinfo_path: step24_sander_mdrun_eq10_output_mdinfo_path
    out:
    - output_traj_path
    - output_rst_path
    - output_log_path
    - output_mdinfo_path
  step25_process_mdout_eq10:
    label: process_mdout
    doc: Parses the AMBER (sander) md output file (log) and dumps statistics that can then be plotted. Using the process_mdout.pl tool from the AmberTools MD package
    run: biobb_adapters/process_mdout.cwl
    in:
      config: step25_process_mdout_eq10_config
      input_log_path: step24_sander_mdrun_eq10/output_log_path
      output_dat_path: step25_process_mdout_eq10_output_dat_path
    out:
    - output_dat_path
  step26_sander_mdrun_md:
    label: sander_mdrun
    doc: Runs energy minimization, molecular dynamics, and NMR refinements using sander tool from the AmberTools MD package
    run: biobb_adapters/sander_mdrun.cwl
    in:
      config: step26_sander_mdrun_md_config
      input_top_path: step5_parmed_hmassrepartition/output_top_path
      input_mdin_path: step26_sander_mdrun_md_input_mdin_path
      input_crd_path: step24_sander_mdrun_eq10/output_rst_path
      input_ref_path: step24_sander_mdrun_eq10/output_rst_path
      output_traj_path: step26_sander_mdrun_md_output_traj_path
      output_rst_path: step26_sander_mdrun_md_output_rst_path
      output_mdinfo_path: step26_sander_mdrun_md_output_mdinfo_path
      output_log_path: step26_sander_mdrun_md_output_log_path
    out:
    - output_traj_path
    - output_rst_path
    - output_mdinfo_path
    - output_log_path
  step27_rmsd_first:
    label: cpptraj_rms
    doc: Wrapper of the Ambertools Cpptraj module for calculating the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
    run: biobb_adapters/cpptraj_rms.cwl
    in:
      config: step27_rmsd_first_config
      input_top_path: step3_leap_add_ions/output_top_path
      input_traj_path: step26_sander_mdrun_md/output_traj_path
      output_cpptraj_path: step27_rmsd_first_output_cpptraj_path
    out:
    - output_cpptraj_path
  step28_rmsd_exp:
    label: cpptraj_rms
    doc: Wrapper of the Ambertools Cpptraj module for calculating the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
    run: biobb_adapters/cpptraj_rms.cwl
    in:
      config: step28_rmsd_exp_config
      input_top_path: step3_leap_add_ions/output_top_path
      input_traj_path: step26_sander_mdrun_md/output_traj_path
      input_exp_path: step1_leap_gen_top/output_pdb_path
      output_cpptraj_path: step28_rmsd_exp_output_cpptraj_path
    out:
    - output_cpptraj_path
  step29_cpptraj_rgyr:
    label: cpptraj_rgyr
    doc: Wrapper of the Ambertools Cpptraj module for computing the radius of gyration (Rgyr) from a given cpptraj compatible trajectory.
    run: biobb_adapters/cpptraj_rgyr.cwl
    in:
      config: step29_cpptraj_rgyr_config
      input_top_path: step3_leap_add_ions/output_top_path
      input_traj_path: step26_sander_mdrun_md/output_traj_path
      output_cpptraj_path: step29_cpptraj_rgyr_output_cpptraj_path
    out:
    - output_cpptraj_path
  step30_cpptraj_image:
    label: cpptraj_image
    doc: Wrapper of the Ambertools Cpptraj module for correcting periodicity (image) from a given cpptraj trajectory file.
    run: biobb_adapters/cpptraj_image.cwl
    in:
      config: step30_cpptraj_image_config
      input_top_path: step3_leap_add_ions/output_top_path
      input_traj_path: step26_sander_mdrun_md/output_traj_path
      output_cpptraj_path: step30_cpptraj_image_output_cpptraj_path
    out:
    - output_cpptraj_path
