#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
label: AMBER Protein Ligand Complex MD Setup
doc: |-
  This workflow performs a simulation setup of a protein-ligand(s) complex system, compatible with the AMBER MD package.
inputs:
  step000_reduce_remove_hydrogens_input_path:
    label: Input file
    doc: Path to the input file.
    type: File
  step000_reduce_remove_hydrogens_output_path:
    label: Output file
    doc: Path to the output file.
    type: string
  step00_extract_molecule_output_molecule_path:
    label: Output file
    doc: Output molecule file path.
    type: string
  step0000_cat_pdb_input_structure2:
    label: Input file
    doc: Input structure 2 file path.
    type: File
  step0000_cat_pdb_output_structure_path:
    label: Output file
    doc: Output protein file path.
    type: string
  step0_cat_pdb_input_structure2:
    label: Input file
    doc: Input structure 2 file path.
    type: File
  step0_cat_pdb_output_structure_path:
    label: Output file
    doc: Output protein file path.
    type: string
  step1_pdb4amber_run_output_pdb_path:
    label: Output file
    doc: Output 3D structure PDB file.
    type: string
  step2_leap_gen_top_input_lib_path:
    label: Input file
    doc: Input ligand library parameters file.
    type: File
  step2_leap_gen_top_input_frcmod_path:
    label: Input file
    doc: Input ligand frcmod parameters file.
    type: File
  step2_leap_gen_top_output_pdb_path:
    label: Output file
    doc: Output 3D structure PDB file matching the topology file.
    type: string
  step2_leap_gen_top_output_top_path:
    label: Output file
    doc: Output topology file (AMBER ParmTop).
    type: string
  step2_leap_gen_top_output_crd_path:
    label: Output file
    doc: Output coordinates file (AMBER crd).
    type: string
  step2_leap_gen_top_config:
    label: Config file
    doc: Configuration file for biobb_amber.leap_gen_top tool.
    type: string
  step3_sander_mdrun_minH_output_traj_path:
    label: Output file
    doc: Output trajectory file.
    type: string
  step3_sander_mdrun_minH_output_rst_path:
    label: Output file
    doc: Output restart file.
    type: string
  step3_sander_mdrun_minH_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step3_sander_mdrun_minH_config:
    label: Config file
    doc: Configuration file for biobb_amber.sander_mdrun tool.
    type: string
  step4_process_minout_minH_output_dat_path:
    label: Output file
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: string
  step4_process_minout_minH_config:
    label: Config file
    doc: Configuration file for biobb_amber.process_minout tool.
    type: string
  step5_sander_mdrun_min_output_traj_path:
    label: Output file
    doc: Output trajectory file.
    type: string
  step5_sander_mdrun_min_output_rst_path:
    label: Output file
    doc: Output restart file.
    type: string
  step5_sander_mdrun_min_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step5_sander_mdrun_min_config:
    label: Config file
    doc: Configuration file for biobb_amber.sander_mdrun tool.
    type: string
  step6_process_minout_min_output_dat_path:
    label: Output file
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: string
  step6_process_minout_min_config:
    label: Config file
    doc: Configuration file for biobb_amber.process_minout tool.
    type: string
  step7_amber_to_pdb_output_pdb_path:
    label: Output file
    doc: Structure PDB file.
    type: string
  step8_leap_solvate_input_lib_path:
    label: Input file
    doc: Input ligand library parameters file.
    type: File
  step8_leap_solvate_input_frcmod_path:
    label: Input file
    doc: Input ligand frcmod parameters file.
    type: File
  step8_leap_solvate_output_pdb_path:
    label: Output file
    doc: Output 3D structure PDB file matching the topology file.
    type: string
  step8_leap_solvate_output_top_path:
    label: Output file
    doc: Output topology file (AMBER ParmTop).
    type: string
  step8_leap_solvate_output_crd_path:
    label: Output file
    doc: Output coordinates file (AMBER crd).
    type: string
  step8_leap_solvate_config:
    label: Config file
    doc: Configuration file for biobb_amber.leap_solvate tool.
    type: string
  step9_leap_add_ions_input_lib_path:
    label: Input file
    doc: Input ligand library parameters file.
    type: File
  step9_leap_add_ions_input_frcmod_path:
    label: Input file
    doc: Input ligand frcmod parameters file.
    type: File
  step9_leap_add_ions_output_pdb_path:
    label: Output file
    doc: Output 3D structure PDB file matching the topology file.
    type: string
  step9_leap_add_ions_output_top_path:
    label: Output file
    doc: Output topology file (AMBER ParmTop).
    type: string
  step9_leap_add_ions_output_crd_path:
    label: Output file
    doc: Output coordinates file (AMBER crd).
    type: string
  step9_leap_add_ions_config:
    label: Config file
    doc: Configuration file for biobb_amber.leap_add_ions tool.
    type: string
  step10_sander_mdrun_energy_output_traj_path:
    label: Output file
    doc: Output trajectory file.
    type: string
  step10_sander_mdrun_energy_output_rst_path:
    label: Output file
    doc: Output restart file.
    type: string
  step10_sander_mdrun_energy_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step10_sander_mdrun_energy_config:
    label: Config file
    doc: Configuration file for biobb_amber.sander_mdrun tool.
    type: string
  step11_process_minout_energy_output_dat_path:
    label: Output file
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: string
  step11_process_minout_energy_config:
    label: Config file
    doc: Configuration file for biobb_amber.process_minout tool.
    type: string
  step12_sander_mdrun_warm_output_traj_path:
    label: Output file
    doc: Output trajectory file.
    type: string
  step12_sander_mdrun_warm_output_rst_path:
    label: Output file
    doc: Output restart file.
    type: string
  step12_sander_mdrun_warm_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step12_sander_mdrun_warm_config:
    label: Config file
    doc: Configuration file for biobb_amber.sander_mdrun tool.
    type: string
  step13_process_mdout_warm_output_dat_path:
    label: Output file
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: string
  step13_process_mdout_warm_config:
    label: Config file
    doc: Configuration file for biobb_amber.process_mdout tool.
    type: string
  step14_sander_mdrun_nvt_output_traj_path:
    label: Output file
    doc: Output trajectory file.
    type: string
  step14_sander_mdrun_nvt_output_rst_path:
    label: Output file
    doc: Output restart file.
    type: string
  step14_sander_mdrun_nvt_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step14_sander_mdrun_nvt_config:
    label: Config file
    doc: Configuration file for biobb_amber.sander_mdrun tool.
    type: string
  step15_process_mdout_nvt_output_dat_path:
    label: Output file
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: string
  step15_process_mdout_nvt_config:
    label: Config file
    doc: Configuration file for biobb_amber.process_mdout tool.
    type: string
  step16_sander_mdrun_npt_output_traj_path:
    label: Output file
    doc: Output trajectory file.
    type: string
  step16_sander_mdrun_npt_output_rst_path:
    label: Output file
    doc: Output restart file.
    type: string
  step16_sander_mdrun_npt_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step16_sander_mdrun_npt_config:
    label: Config file
    doc: Configuration file for biobb_amber.sander_mdrun tool.
    type: string
  step17_process_mdout_npt_output_dat_path:
    label: Output file
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: string
  step17_process_mdout_npt_config:
    label: Config file
    doc: Configuration file for biobb_amber.process_mdout tool.
    type: string
  step18_sander_mdrun_md_output_traj_path:
    label: Output file
    doc: Output trajectory file.
    type: string
  step18_sander_mdrun_md_output_rst_path:
    label: Output file
    doc: Output restart file.
    type: string
  step18_sander_mdrun_md_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step18_sander_mdrun_md_config:
    label: Config file
    doc: Configuration file for biobb_amber.sander_mdrun tool.
    type: string
  step19_rmsd_first_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed analysis.
    type: string
  step19_rmsd_first_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_rms tool.
    type: string
  step20_rmsd_exp_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed analysis.
    type: string
  step20_rmsd_exp_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_rms tool.
    type: string
  step21_cpptraj_rgyr_output_cpptraj_path:
    label: Output file
    doc: Path to the output analysis.
    type: string
  step21_cpptraj_rgyr_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_rgyr tool.
    type: string
  step22_cpptraj_image_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed trajectory.
    type: string
  step22_cpptraj_image_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_image tool.
    type: string
outputs:
  step000_reduce_remove_hydrogens_out1:
    label: output_path
    doc: Path to the output file.
    type: File
    outputSource: step000_reduce_remove_hydrogens/output_path
  step00_extract_molecule_out1:
    label: output_molecule_path
    doc: Output molecule file path.
    type: File
    outputSource: step00_extract_molecule/output_molecule_path
  step0000_cat_pdb_out1:
    label: output_structure_path
    doc: Output protein file path.
    type: File
    outputSource: step0000_cat_pdb/output_structure_path
  step0_cat_pdb_out1:
    label: output_structure_path
    doc: Output protein file path.
    type: File
    outputSource: step0_cat_pdb/output_structure_path
  step1_pdb4amber_run_out1:
    label: output_pdb_path
    doc: Output 3D structure PDB file.
    type: File
    outputSource: step1_pdb4amber_run/output_pdb_path
  step2_leap_gen_top_out1:
    label: output_pdb_path
    doc: Output 3D structure PDB file matching the topology file.
    type: File
    outputSource: step2_leap_gen_top/output_pdb_path
  step2_leap_gen_top_out2:
    label: output_top_path
    doc: Output topology file (AMBER ParmTop).
    type: File
    outputSource: step2_leap_gen_top/output_top_path
  step2_leap_gen_top_out3:
    label: output_crd_path
    doc: Output coordinates file (AMBER crd).
    type: File
    outputSource: step2_leap_gen_top/output_crd_path
  step3_sander_mdrun_minH_out1:
    label: output_traj_path
    doc: Output trajectory file.
    type: File
    outputSource: step3_sander_mdrun_minH/output_traj_path
  step3_sander_mdrun_minH_out2:
    label: output_rst_path
    doc: Output restart file.
    type: File
    outputSource: step3_sander_mdrun_minH/output_rst_path
  step3_sander_mdrun_minH_out3:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step3_sander_mdrun_minH/output_log_path
  step4_process_minout_minH_out1:
    label: output_dat_path
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: File
    outputSource: step4_process_minout_minH/output_dat_path
  step5_sander_mdrun_min_out1:
    label: output_traj_path
    doc: Output trajectory file.
    type: File
    outputSource: step5_sander_mdrun_min/output_traj_path
  step5_sander_mdrun_min_out2:
    label: output_rst_path
    doc: Output restart file.
    type: File
    outputSource: step5_sander_mdrun_min/output_rst_path
  step5_sander_mdrun_min_out3:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step5_sander_mdrun_min/output_log_path
  step6_process_minout_min_out1:
    label: output_dat_path
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: File
    outputSource: step6_process_minout_min/output_dat_path
  step7_amber_to_pdb_out1:
    label: output_pdb_path
    doc: Structure PDB file.
    type: File
    outputSource: step7_amber_to_pdb/output_pdb_path
  step8_leap_solvate_out1:
    label: output_pdb_path
    doc: Output 3D structure PDB file matching the topology file.
    type: File
    outputSource: step8_leap_solvate/output_pdb_path
  step8_leap_solvate_out2:
    label: output_top_path
    doc: Output topology file (AMBER ParmTop).
    type: File
    outputSource: step8_leap_solvate/output_top_path
  step8_leap_solvate_out3:
    label: output_crd_path
    doc: Output coordinates file (AMBER crd).
    type: File
    outputSource: step8_leap_solvate/output_crd_path
  step9_leap_add_ions_out1:
    label: output_pdb_path
    doc: Output 3D structure PDB file matching the topology file.
    type: File
    outputSource: step9_leap_add_ions/output_pdb_path
  step9_leap_add_ions_out2:
    label: output_top_path
    doc: Output topology file (AMBER ParmTop).
    type: File
    outputSource: step9_leap_add_ions/output_top_path
  step9_leap_add_ions_out3:
    label: output_crd_path
    doc: Output coordinates file (AMBER crd).
    type: File
    outputSource: step9_leap_add_ions/output_crd_path
  step10_sander_mdrun_energy_out1:
    label: output_traj_path
    doc: Output trajectory file.
    type: File
    outputSource: step10_sander_mdrun_energy/output_traj_path
  step10_sander_mdrun_energy_out2:
    label: output_rst_path
    doc: Output restart file.
    type: File
    outputSource: step10_sander_mdrun_energy/output_rst_path
  step10_sander_mdrun_energy_out3:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step10_sander_mdrun_energy/output_log_path
  step11_process_minout_energy_out1:
    label: output_dat_path
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: File
    outputSource: step11_process_minout_energy/output_dat_path
  step12_sander_mdrun_warm_out1:
    label: output_traj_path
    doc: Output trajectory file.
    type: File
    outputSource: step12_sander_mdrun_warm/output_traj_path
  step12_sander_mdrun_warm_out2:
    label: output_rst_path
    doc: Output restart file.
    type: File
    outputSource: step12_sander_mdrun_warm/output_rst_path
  step12_sander_mdrun_warm_out3:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step12_sander_mdrun_warm/output_log_path
  step13_process_mdout_warm_out1:
    label: output_dat_path
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: File
    outputSource: step13_process_mdout_warm/output_dat_path
  step14_sander_mdrun_nvt_out1:
    label: output_traj_path
    doc: Output trajectory file.
    type: File
    outputSource: step14_sander_mdrun_nvt/output_traj_path
  step14_sander_mdrun_nvt_out2:
    label: output_rst_path
    doc: Output restart file.
    type: File
    outputSource: step14_sander_mdrun_nvt/output_rst_path
  step14_sander_mdrun_nvt_out3:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step14_sander_mdrun_nvt/output_log_path
  step15_process_mdout_nvt_out1:
    label: output_dat_path
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: File
    outputSource: step15_process_mdout_nvt/output_dat_path
  step16_sander_mdrun_npt_out1:
    label: output_traj_path
    doc: Output trajectory file.
    type: File
    outputSource: step16_sander_mdrun_npt/output_traj_path
  step16_sander_mdrun_npt_out2:
    label: output_rst_path
    doc: Output restart file.
    type: File
    outputSource: step16_sander_mdrun_npt/output_rst_path
  step16_sander_mdrun_npt_out3:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step16_sander_mdrun_npt/output_log_path
  step17_process_mdout_npt_out1:
    label: output_dat_path
    doc: Dat output file containing data from the specified terms along the minimization process.
    type: File
    outputSource: step17_process_mdout_npt/output_dat_path
  step18_sander_mdrun_md_out1:
    label: output_traj_path
    doc: Output trajectory file.
    type: File
    outputSource: step18_sander_mdrun_md/output_traj_path
  step18_sander_mdrun_md_out2:
    label: output_rst_path
    doc: Output restart file.
    type: File
    outputSource: step18_sander_mdrun_md/output_rst_path
  step18_sander_mdrun_md_out3:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step18_sander_mdrun_md/output_log_path
  step19_rmsd_first_out1:
    label: output_cpptraj_path
    doc: Path to the output processed analysis.
    type: File
    outputSource: step19_rmsd_first/output_cpptraj_path
  step20_rmsd_exp_out1:
    label: output_cpptraj_path
    doc: Path to the output processed analysis.
    type: File
    outputSource: step20_rmsd_exp/output_cpptraj_path
  step21_cpptraj_rgyr_out1:
    label: output_cpptraj_path
    doc: Path to the output analysis.
    type: File
    outputSource: step21_cpptraj_rgyr/output_cpptraj_path
  step22_cpptraj_image_out1:
    label: output_cpptraj_path
    doc: Path to the output processed trajectory.
    type: File
    outputSource: step22_cpptraj_image/output_cpptraj_path
steps:
  step000_reduce_remove_hydrogens:
    label: reduce_remove_hydrogens
    doc: Removes hydrogen atoms to small molecules.
    run: biobb_adapters/reduce_remove_hydrogens.cwl
    in:
      input_path: step000_reduce_remove_hydrogens_input_path
      output_path: step000_reduce_remove_hydrogens_output_path
    out:
    - output_path
  step00_extract_molecule:
    label: extract_molecule
    doc: This class is a wrapper of the Structure Checking tool to extract a molecule from a 3D structure.
    run: biobb_adapters/extract_molecule.cwl
    in:
      input_structure_path: step000_reduce_remove_hydrogens/output_path
      output_molecule_path: step00_extract_molecule_output_molecule_path
    out:
    - output_molecule_path
  step0000_cat_pdb:
    label: cat_pdb
    doc: Class to concat two PDB structures in a single PDB file.
    run: biobb_adapters/cat_pdb.cwl
    in:
      input_structure1: step00_extract_molecule/output_molecule_path
      input_structure2: step0000_cat_pdb_input_structure2
      output_structure_path: step0000_cat_pdb_output_structure_path
    out:
    - output_structure_path
  step0_cat_pdb:
    label: cat_pdb
    doc: Class to concat two PDB structures in a single PDB file.
    run: biobb_adapters/cat_pdb.cwl
    in:
      input_structure1: step0000_cat_pdb/output_structure_path
      input_structure2: step0_cat_pdb_input_structure2
      output_structure_path: step0_cat_pdb_output_structure_path
    out:
    - output_structure_path
  step1_pdb4amber_run:
    label: pdb4amber_run
    doc: Analyse PDB files and clean them for further usage, especially with the LEaP programs of Amber, using pdb4amber tool from the AmberTools MD package
    run: biobb_adapters/pdb4amber_run.cwl
    in:
      input_pdb_path: step0_cat_pdb/output_structure_path
      output_pdb_path: step1_pdb4amber_run_output_pdb_path
    out:
    - output_pdb_path
  step2_leap_gen_top:
    label: leap_gen_top
    doc: Generates a MD topology from a molecule structure using tLeap tool from the AmberTools MD package
    run: biobb_adapters/leap_gen_top.cwl
    in:
      config: step2_leap_gen_top_config
      input_pdb_path: step1_pdb4amber_run/output_pdb_path
      input_lib_path: step2_leap_gen_top_input_lib_path
      input_frcmod_path: step2_leap_gen_top_input_frcmod_path
      output_pdb_path: step2_leap_gen_top_output_pdb_path
      output_top_path: step2_leap_gen_top_output_top_path
      output_crd_path: step2_leap_gen_top_output_crd_path
    out:
    - output_pdb_path
    - output_top_path
    - output_crd_path
  step3_sander_mdrun_minH:
    label: sander_mdrun
    doc: Runs energy minimization, molecular dynamics, and NMR refinements using sander tool from the AmberTools MD package
    run: biobb_adapters/sander_mdrun.cwl
    in:
      config: step3_sander_mdrun_minH_config
      input_top_path: step2_leap_gen_top/output_top_path
      input_crd_path: step2_leap_gen_top/output_crd_path
      input_ref_path: step2_leap_gen_top/output_crd_path
      output_traj_path: step3_sander_mdrun_minH_output_traj_path
      output_rst_path: step3_sander_mdrun_minH_output_rst_path
      output_log_path: step3_sander_mdrun_minH_output_log_path
    out:
    - output_traj_path
    - output_rst_path
    - output_log_path
  step4_process_minout_minH:
    label: process_minout
    doc: Parses the AMBER (sander) minimization output file (log) and dumps statistics that can then be plotted. Using the process_minout.pl tool from the AmberTools MD package
    run: biobb_adapters/process_minout.cwl
    in:
      config: step4_process_minout_minH_config
      input_log_path: step3_sander_mdrun_minH/output_log_path
      output_dat_path: step4_process_minout_minH_output_dat_path
    out:
    - output_dat_path
  step5_sander_mdrun_min:
    label: sander_mdrun
    doc: Runs energy minimization, molecular dynamics, and NMR refinements using sander tool from the AmberTools MD package
    run: biobb_adapters/sander_mdrun.cwl
    in:
      config: step5_sander_mdrun_min_config
      input_top_path: step2_leap_gen_top/output_top_path
      input_crd_path: step3_sander_mdrun_minH/output_rst_path
      input_ref_path: step3_sander_mdrun_minH/output_rst_path
      output_traj_path: step5_sander_mdrun_min_output_traj_path
      output_rst_path: step5_sander_mdrun_min_output_rst_path
      output_log_path: step5_sander_mdrun_min_output_log_path
    out:
    - output_traj_path
    - output_rst_path
    - output_log_path
  step6_process_minout_min:
    label: process_minout
    doc: Parses the AMBER (sander) minimization output file (log) and dumps statistics that can then be plotted. Using the process_minout.pl tool from the AmberTools MD package
    run: biobb_adapters/process_minout.cwl
    in:
      config: step6_process_minout_min_config
      input_log_path: step5_sander_mdrun_min/output_log_path
      output_dat_path: step6_process_minout_min_output_dat_path
    out:
    - output_dat_path
  step7_amber_to_pdb:
    label: amber_to_pdb
    doc: Generates a PDB structure from AMBER topology (parmtop) and coordinates (crd) files, using the ambpdb tool from the AmberTools MD package
    run: biobb_adapters/amber_to_pdb.cwl
    in:
      input_top_path: step2_leap_gen_top/output_top_path
      input_crd_path: step5_sander_mdrun_minH/output_rst_path
      output_pdb_path: step7_amber_to_pdb_output_pdb_path
    out:
    - output_pdb_path
  step8_leap_solvate:
    label: leap_solvate
    doc: Creates and solvates a system box for an AMBER MD system using tLeap tool from the AmberTools MD package
    run: biobb_adapters/leap_solvate.cwl
    in:
      config: step8_leap_solvate_config
      input_pdb_path: step7_amber_to_pdb/output_pdb_path
      input_lib_path: step8_leap_solvate_input_lib_path
      input_frcmod_path: step8_leap_solvate_input_frcmod_path
      output_pdb_path: step8_leap_solvate_output_pdb_path
      output_top_path: step8_leap_solvate_output_top_path
      output_crd_path: step8_leap_solvate_output_crd_path
    out:
    - output_pdb_path
    - output_top_path
    - output_crd_path
  step9_leap_add_ions:
    label: leap_add_ions
    doc: Adds counterions to a system box for an AMBER MD system using tLeap tool from the AmberTools MD package
    run: biobb_adapters/leap_add_ions.cwl
    in:
      config: step9_leap_add_ions_config
      input_pdb_path: step8_leap_solvate/output_pdb_path
      input_lib_path: step9_leap_add_ions_input_lib_path
      input_frcmod_path: step9_leap_add_ions_input_frcmod_path
      output_pdb_path: step9_leap_add_ions_output_pdb_path
      output_top_path: step9_leap_add_ions_output_top_path
      output_crd_path: step9_leap_add_ions_output_crd_path
    out:
    - output_pdb_path
    - output_top_path
    - output_crd_path
  step10_sander_mdrun_energy:
    label: sander_mdrun
    doc: Runs energy minimization, molecular dynamics, and NMR refinements using sander tool from the AmberTools MD package
    run: biobb_adapters/sander_mdrun.cwl
    in:
      config: step10_sander_mdrun_energy_config
      input_top_path: step9_leap_add_ions/output_top_path
      input_crd_path: step9_leap_add_ions/output_crd_path
      input_ref_path: step9_leap_add_ions/output_crd_path
      output_traj_path: step10_sander_mdrun_energy_output_traj_path
      output_rst_path: step10_sander_mdrun_energy_output_rst_path
      output_log_path: step10_sander_mdrun_energy_output_log_path
    out:
    - output_traj_path
    - output_rst_path
    - output_log_path
  step11_process_minout_energy:
    label: process_minout
    doc: Parses the AMBER (sander) minimization output file (log) and dumps statistics that can then be plotted. Using the process_minout.pl tool from the AmberTools MD package
    run: biobb_adapters/process_minout.cwl
    in:
      config: step11_process_minout_energy_config
      input_log_path: step10_sander_mdrun_energy/output_log_path
      output_dat_path: step11_process_minout_energy_output_dat_path
    out:
    - output_dat_path
  step12_sander_mdrun_warm:
    label: sander_mdrun
    doc: Runs energy minimization, molecular dynamics, and NMR refinements using sander tool from the AmberTools MD package
    run: biobb_adapters/sander_mdrun.cwl
    in:
      config: step12_sander_mdrun_warm_config
      input_top_path: step9_leap_add_ions/output_top_path
      input_crd_path: step10_sander_mdrun_energy/output_rst_path
      input_ref_path: step10_sander_mdrun_energy/output_rst_path
      output_traj_path: step12_sander_mdrun_warm_output_traj_path
      output_rst_path: step12_sander_mdrun_warm_output_rst_path
      output_log_path: step12_sander_mdrun_warm_output_log_path
    out:
    - output_traj_path
    - output_rst_path
    - output_log_path
  step13_process_mdout_warm:
    label: process_mdout
    doc: Parses the AMBER (sander) md output file (log) and dumps statistics that can then be plotted. Using the process_mdout.pl tool from the AmberTools MD package
    run: biobb_adapters/process_mdout.cwl
    in:
      config: step13_process_mdout_warm_config
      input_log_path: step12_sander_mdrun_warm/output_log_path
      output_dat_path: step13_process_mdout_warm_output_dat_path
    out:
    - output_dat_path
  step14_sander_mdrun_nvt:
    label: sander_mdrun
    doc: Runs energy minimization, molecular dynamics, and NMR refinements using sander tool from the AmberTools MD package
    run: biobb_adapters/sander_mdrun.cwl
    in:
      config: step14_sander_mdrun_nvt_config
      input_top_path: step9_leap_add_ions/output_top_path
      input_crd_path: step12_sander_mdrun_warm/output_rst_path
      input_ref_path: step12_sander_mdrun_warm/output_rst_path
      output_traj_path: step14_sander_mdrun_nvt_output_traj_path
      output_rst_path: step14_sander_mdrun_nvt_output_rst_path
      output_log_path: step14_sander_mdrun_nvt_output_log_path
    out:
    - output_traj_path
    - output_rst_path
    - output_log_path
  step15_process_mdout_nvt:
    label: process_mdout
    doc: Parses the AMBER (sander) md output file (log) and dumps statistics that can then be plotted. Using the process_mdout.pl tool from the AmberTools MD package
    run: biobb_adapters/process_mdout.cwl
    in:
      config: step15_process_mdout_nvt_config
      input_log_path: step14_sander_mdrun_nvt/output_log_path
      output_dat_path: step15_process_mdout_nvt_output_dat_path
    out:
    - output_dat_path
  step16_sander_mdrun_npt:
    label: sander_mdrun
    doc: Runs energy minimization, molecular dynamics, and NMR refinements using sander tool from the AmberTools MD package
    run: biobb_adapters/sander_mdrun.cwl
    in:
      config: step16_sander_mdrun_npt_config
      input_top_path: step9_leap_add_ions/output_top_path
      input_crd_path: step14_sander_mdrun_nvt/output_rst_path
      input_ref_path: step14_sander_mdrun_nvt/output_rst_path
      output_traj_path: step16_sander_mdrun_npt_output_traj_path
      output_rst_path: step16_sander_mdrun_npt_output_rst_path
      output_log_path: step16_sander_mdrun_npt_output_log_path
    out:
    - output_traj_path
    - output_rst_path
    - output_log_path
  step17_process_mdout_npt:
    label: process_mdout
    doc: Parses the AMBER (sander) md output file (log) and dumps statistics that can then be plotted. Using the process_mdout.pl tool from the AmberTools MD package
    run: biobb_adapters/process_mdout.cwl
    in:
      config: step17_process_mdout_npt_config
      input_log_path: step16_sander_mdrun_npt/output_log_path
      output_dat_path: step17_process_mdout_npt_output_dat_path
    out:
    - output_dat_path
  step18_sander_mdrun_md:
    label: sander_mdrun
    doc: Runs energy minimization, molecular dynamics, and NMR refinements using sander tool from the AmberTools MD package
    run: biobb_adapters/sander_mdrun.cwl
    in:
      config: step18_sander_mdrun_md_config
      input_top_path: step9_leap_add_ions/output_top_path
      input_crd_path: step16_sander_mdrun_npt/output_rst_path
      output_traj_path: step18_sander_mdrun_md_output_traj_path
      output_rst_path: step18_sander_mdrun_md_output_rst_path
      output_log_path: step18_sander_mdrun_md_output_log_path
    out:
    - output_traj_path
    - output_rst_path
    - output_log_path
  step19_rmsd_first:
    label: cpptraj_rms
    doc: Wrapper of the Ambertools Cpptraj module for calculating the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
    run: biobb_adapters/cpptraj_rms.cwl
    in:
      config: step19_rmsd_first_config
      input_top_path: step9_leap_add_ions/output_top_path
      input_traj_path: step18_sander_mdrun_md/output_traj_path
      output_cpptraj_path: step19_rmsd_first_output_cpptraj_path
    out:
    - output_cpptraj_path
  step20_rmsd_exp:
    label: cpptraj_rms
    doc: Wrapper of the Ambertools Cpptraj module for calculating the Root Mean Square deviation (RMSd) of a given cpptraj compatible trajectory.
    run: biobb_adapters/cpptraj_rms.cwl
    in:
      config: step20_rmsd_exp_config
      input_top_path: step9_leap_add_ions/output_top_path
      input_traj_path: step18_sander_mdrun_md/output_traj_path
      input_exp_path: step2_leap_gen_top/output_pdb_path
      output_cpptraj_path: step20_rmsd_exp_output_cpptraj_path
    out:
    - output_cpptraj_path
  step21_cpptraj_rgyr:
    label: cpptraj_rgyr
    doc: Wrapper of the Ambertools Cpptraj module for computing the radius of gyration (Rgyr) from a given cpptraj compatible trajectory.
    run: biobb_adapters/cpptraj_rgyr.cwl
    in:
      config: step21_cpptraj_rgyr_config
      input_top_path: step9_leap_add_ions/output_top_path
      input_traj_path: step18_sander_mdrun_md/output_traj_path
      output_cpptraj_path: step21_cpptraj_rgyr_output_cpptraj_path
    out:
    - output_cpptraj_path
  step22_cpptraj_image:
    label: cpptraj_image
    doc: Wrapper of the Ambertools Cpptraj module for correcting periodicity (image) from a given cpptraj trajectory file.
    run: biobb_adapters/cpptraj_image.cwl
    in:
      config: step22_cpptraj_image_config
      input_top_path: step9_leap_add_ions/output_top_path
      input_traj_path: step18_sander_mdrun_md/output_traj_path
      output_cpptraj_path: step22_cpptraj_image_output_cpptraj_path
    out:
    - output_cpptraj_path
