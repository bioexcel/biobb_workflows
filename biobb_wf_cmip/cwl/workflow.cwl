#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
label: Classical Molecular Interaction Potentials
doc: |-
  This workflow aims to illustrate the process of computing classical molecular interaction potentials from protein structures.
inputs:
  step0_cmip_prepare_pdb_input_pdb_path:
    label: Input file
    doc: Input PDB file path.
    type: File
  step0_cmip_prepare_pdb_output_cmip_pdb_path:
    label: Output file
    doc: Output PDB file path.
    type: string
  step1_cmip_titration_output_pdb_path:
    label: Output file
    doc: Path to the output PDB file.
    type: string
  step1_cmip_titration_config:
    label: Config file
    doc: Configuration file for biobb_cmip.cmip_titration tool.
    type: string
  step2_cat_pdb_output_structure_path:
    label: Output file
    doc: Output protein file path.
    type: string
  step3_cmip_run_pos_output_log_path:
    label: Output file
    doc: Path to the output CMIP log file LOG.
    type: string
  step3_cmip_run_pos_output_cube_path:
    label: Output file
    doc: Path to the output grid file in cube format.
    type: string
  step3_cmip_run_pos_config:
    label: Config file
    doc: Configuration file for biobb_cmip.cmip_run tool.
    type: string
  step4_cmip_run_neg_output_log_path:
    label: Output file
    doc: Path to the output CMIP log file LOG.
    type: string
  step4_cmip_run_neg_output_cube_path:
    label: Output file
    doc: Path to the output grid file in cube format.
    type: string
  step4_cmip_run_neg_config:
    label: Config file
    doc: Configuration file for biobb_cmip.cmip_run tool.
    type: string
  step5_cmip_run_neu_output_log_path:
    label: Output file
    doc: Path to the output CMIP log file LOG.
    type: string
  step5_cmip_run_neu_output_cube_path:
    label: Output file
    doc: Path to the output grid file in cube format.
    type: string
  step5_cmip_run_neu_config:
    label: Config file
    doc: Configuration file for biobb_cmip.cmip_run tool.
    type: string
  step6_remove_pdb_water_input_pdb_path:
    label: Input file
    doc: Input PDB file path.
    type: File
  step6_remove_pdb_water_output_pdb_path:
    label: Output file
    doc: Output PDB file path.
    type: string
  step7_extract_heteroatoms_output_heteroatom_path:
    label: Output file
    doc: Output heteroatom file path.
    type: string
  step7_extract_heteroatoms_config:
    label: Config file
    doc: Configuration file for biobb_structure_utils.extract_heteroatoms tool.
    type: string
  step8_reduce_add_hydrogens_output_path:
    label: Output file
    doc: Path to the output file.
    type: string
  step9_acpype_params_ac_output_path_inpcrd:
    label: Output file
    doc: Path to the INPCRD output file.
    type: string
  step9_acpype_params_ac_output_path_frcmod:
    label: Output file
    doc: Path to the FRCMOD output file.
    type: string
  step9_acpype_params_ac_output_path_lib:
    label: Output file
    doc: Path to the LIB output file.
    type: string
  step9_acpype_params_ac_output_path_prmtop:
    label: Output file
    doc: Path to the PRMTOP output file.
    type: string
  step9_acpype_params_ac_config:
    label: Config file
    doc: Configuration file for biobb_chemistry.acpype_params_ac tool.
    type: string
  step10_leap_gen_top_output_pdb_path:
    label: Output file
    doc: Output 3D structure PDB file matching the topology file.
    type: string
  step10_leap_gen_top_output_top_path:
    label: Output file
    doc: Output topology file (AMBER ParmTop).
    type: string
  step10_leap_gen_top_output_crd_path:
    label: Output file
    doc: Output coordinates file (AMBER crd).
    type: string
  step10_leap_gen_top_config:
    label: Config file
    doc: Configuration file for biobb_amber.leap_gen_top tool.
    type: string
  step11_sander_mdrun_output_traj_path:
    label: Output file
    doc: Output trajectory file.
    type: string
  step11_sander_mdrun_output_rst_path:
    label: Output file
    doc: Output restart file.
    type: string
  step11_sander_mdrun_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step11_sander_mdrun_config:
    label: Config file
    doc: Configuration file for biobb_amber.sander_mdrun tool.
    type: string
  step12_amber_to_pdb_output_pdb_path:
    label: Output file
    doc: Structure PDB file.
    type: string
  step13_cmip_prepare_structure_output_cmip_pdb_path:
    label: Output file
    doc: Path to the output PDB file.
    type: string
  step14_remove_ligand_output_structure_path:
    label: Output file
    doc: Output structure file path.
    type: string
  step14_remove_ligand_config:
    label: Config file
    doc: Configuration file for biobb_structure_utils.remove_ligand tool.
    type: string
  step15_cmip_ignore_residues_output_cmip_pdb_path:
    label: Output file
    doc: Output PDB file path.
    type: string
  step15_cmip_ignore_residues_config:
    label: Config file
    doc: Configuration file for biobb_cmip.cmip_ignore_residues tool.
    type: string
  step16_cmip_run_int_en_output_log_path:
    label: Output file
    doc: Path to the output CMIP log file LOG.
    type: string
  step16_cmip_run_int_en_output_byat_path:
    label: Output file
    doc: Path to the output atom by atom energy file.
    type: string
  step16_cmip_run_int_en_config:
    label: Config file
    doc: Configuration file for biobb_cmip.cmip_run tool.
    type: string
  step17_cmip_prepare_structure_input_pdb_path:
    label: Input file
    doc: Path to the input PDB file.
    type: File
  step17_cmip_prepare_structure_input_topology_path:
    label: Input file
    doc: Path to the input topology path.
    type: File
  step17_cmip_prepare_structure_output_cmip_pdb_path:
    label: Output file
    doc: Path to the output PDB file.
    type: string
  step18_extract_chain_a_output_structure_path:
    label: Output file
    doc: Output structure file path.
    type: string
  step18_extract_chain_a_config:
    label: Config file
    doc: Configuration file for biobb_structure_utils.extract_chain tool.
    type: string
  step19_extract_chain_b_output_structure_path:
    label: Output file
    doc: Output structure file path.
    type: string
  step19_extract_chain_b_config:
    label: Config file
    doc: Configuration file for biobb_structure_utils.extract_chain tool.
    type: string
  step20_cmip_run_rbd_output_log_path:
    label: Output file
    doc: Path to the output CMIP log file LOG.
    type: string
  step20_cmip_run_rbd_output_json_box_path:
    label: Output file
    doc: Path to the output CMIP box in JSON format.
    type: string
  step20_cmip_run_rbd_config:
    label: Config file
    doc: Configuration file for biobb_cmip.cmip_run tool.
    type: string
  step21_cmip_run_hace2_output_log_path:
    label: Output file
    doc: Path to the output CMIP log file LOG.
    type: string
  step21_cmip_run_hace2_output_json_box_path:
    label: Output file
    doc: Path to the output CMIP box in JSON format.
    type: string
  step21_cmip_run_hace2_config:
    label: Config file
    doc: Configuration file for biobb_cmip.cmip_run tool.
    type: string
  step22_cmip_run_rbd_hace2_output_log_path:
    label: Output file
    doc: Path to the output CMIP log file LOG.
    type: string
  step22_cmip_run_rbd_hace2_output_json_box_path:
    label: Output file
    doc: Path to the output CMIP box in JSON format.
    type: string
  step22_cmip_run_rbd_hace2_config:
    label: Config file
    doc: Configuration file for biobb_cmip.cmip_run tool.
    type: string
  step23_cmip_ignore_residues_rbd_output_cmip_pdb_path:
    label: Output file
    doc: Output PDB file path.
    type: string
  step23_cmip_ignore_residues_rbd_config:
    label: Config file
    doc: Configuration file for biobb_cmip.cmip_ignore_residues tool.
    type: string
  step24_cmip_run_prot_prot_output_json_box_path:
    label: Output file
    doc: Path to the output CMIP box in JSON format.
    type: string
  step24_cmip_run_prot_prot_output_json_external_box_path:
    label: Output file
    doc: Path to the output external CMIP box in JSON format.
    type: string
  step24_cmip_run_prot_prot_output_log_path:
    label: Output file
    doc: Path to the output CMIP log file LOG.
    type: string
  step24_cmip_run_prot_prot_output_byat_path:
    label: Output file
    doc: Path to the output atom by atom energy file.
    type: string
  step24_cmip_run_prot_prot_config:
    label: Config file
    doc: Configuration file for biobb_cmip.cmip_run tool.
    type: string
  step25_cmip_ignore_residues_hace2_output_cmip_pdb_path:
    label: Output file
    doc: Output PDB file path.
    type: string
  step25_cmip_ignore_residues_hace2_config:
    label: Config file
    doc: Configuration file for biobb_cmip.cmip_ignore_residues tool.
    type: string
  step26_cmip_run_complex_output_json_box_path:
    label: Output file
    doc: Path to the output CMIP box in JSON format.
    type: string
  step26_cmip_run_complex_output_json_external_box_path:
    label: Output file
    doc: Path to the output external CMIP box in JSON format.
    type: string
  step26_cmip_run_complex_output_log_path:
    label: Output file
    doc: Path to the output CMIP log file LOG.
    type: string
  step26_cmip_run_complex_output_byat_path:
    label: Output file
    doc: Path to the output atom by atom energy file.
    type: string
  step26_cmip_run_complex_config:
    label: Config file
    doc: Configuration file for biobb_cmip.cmip_run tool.
    type: string
outputs:
  step0_cmip_prepare_pdb_out1:
    label: output_cmip_pdb_path
    doc: Output PDB file path.
    type: File
    outputSource: step0_cmip_prepare_pdb/output_cmip_pdb_path
  step1_cmip_titration_out1:
    label: output_pdb_path
    doc: Path to the output PDB file.
    type: File
    outputSource: step1_cmip_titration/output_pdb_path
  step2_cat_pdb_out1:
    label: output_structure_path
    doc: Output protein file path.
    type: File
    outputSource: step2_cat_pdb/output_structure_path
  step3_cmip_run_pos_out1:
    label: output_log_path
    doc: Path to the output CMIP log file LOG.
    type: File
    outputSource: step3_cmip_run_pos/output_log_path
  step3_cmip_run_pos_out2:
    label: output_cube_path
    doc: Path to the output grid file in cube format.
    type: File
    outputSource: step3_cmip_run_pos/output_cube_path
  step4_cmip_run_neg_out1:
    label: output_log_path
    doc: Path to the output CMIP log file LOG.
    type: File
    outputSource: step4_cmip_run_neg/output_log_path
  step4_cmip_run_neg_out2:
    label: output_cube_path
    doc: Path to the output grid file in cube format.
    type: File
    outputSource: step4_cmip_run_neg/output_cube_path
  step5_cmip_run_neu_out1:
    label: output_log_path
    doc: Path to the output CMIP log file LOG.
    type: File
    outputSource: step5_cmip_run_neu/output_log_path
  step5_cmip_run_neu_out2:
    label: output_cube_path
    doc: Path to the output grid file in cube format.
    type: File
    outputSource: step5_cmip_run_neu/output_cube_path
  step6_remove_pdb_water_out1:
    label: output_pdb_path
    doc: Output PDB file path.
    type: File
    outputSource: step6_remove_pdb_water/output_pdb_path
  step7_extract_heteroatoms_out1:
    label: output_heteroatom_path
    doc: Output heteroatom file path.
    type: File
    outputSource: step7_extract_heteroatoms/output_heteroatom_path
  step8_reduce_add_hydrogens_out1:
    label: output_path
    doc: Path to the output file.
    type: File
    outputSource: step8_reduce_add_hydrogens/output_path
  step9_acpype_params_ac_out1:
    label: output_path_inpcrd
    doc: Path to the INPCRD output file.
    type: File
    outputSource: step9_acpype_params_ac/output_path_inpcrd
  step9_acpype_params_ac_out2:
    label: output_path_frcmod
    doc: Path to the FRCMOD output file.
    type: File
    outputSource: step9_acpype_params_ac/output_path_frcmod
  step9_acpype_params_ac_out3:
    label: output_path_lib
    doc: Path to the LIB output file.
    type: File
    outputSource: step9_acpype_params_ac/output_path_lib
  step9_acpype_params_ac_out4:
    label: output_path_prmtop
    doc: Path to the PRMTOP output file.
    type: File
    outputSource: step9_acpype_params_ac/output_path_prmtop
  step10_leap_gen_top_out1:
    label: output_pdb_path
    doc: Output 3D structure PDB file matching the topology file.
    type: File
    outputSource: step10_leap_gen_top/output_pdb_path
  step10_leap_gen_top_out2:
    label: output_top_path
    doc: Output topology file (AMBER ParmTop).
    type: File
    outputSource: step10_leap_gen_top/output_top_path
  step10_leap_gen_top_out3:
    label: output_crd_path
    doc: Output coordinates file (AMBER crd).
    type: File
    outputSource: step10_leap_gen_top/output_crd_path
  step11_sander_mdrun_out1:
    label: output_traj_path
    doc: Output trajectory file.
    type: File
    outputSource: step11_sander_mdrun/output_traj_path
  step11_sander_mdrun_out2:
    label: output_rst_path
    doc: Output restart file.
    type: File
    outputSource: step11_sander_mdrun/output_rst_path
  step11_sander_mdrun_out3:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step11_sander_mdrun/output_log_path
  step12_amber_to_pdb_out1:
    label: output_pdb_path
    doc: Structure PDB file.
    type: File
    outputSource: step12_amber_to_pdb/output_pdb_path
  step13_cmip_prepare_structure_out1:
    label: output_cmip_pdb_path
    doc: Path to the output PDB file.
    type: File
    outputSource: step13_cmip_prepare_structure/output_cmip_pdb_path
  step14_remove_ligand_out1:
    label: output_structure_path
    doc: Output structure file path.
    type: File
    outputSource: step14_remove_ligand/output_structure_path
  step15_cmip_ignore_residues_out1:
    label: output_cmip_pdb_path
    doc: Output PDB file path.
    type: File
    outputSource: step15_cmip_ignore_residues/output_cmip_pdb_path
  step16_cmip_run_int_en_out1:
    label: output_log_path
    doc: Path to the output CMIP log file LOG.
    type: File
    outputSource: step16_cmip_run_int_en/output_log_path
  step16_cmip_run_int_en_out2:
    label: output_byat_path
    doc: Path to the output atom by atom energy file.
    type: File
    outputSource: step16_cmip_run_int_en/output_byat_path
  step17_cmip_prepare_structure_out1:
    label: output_cmip_pdb_path
    doc: Path to the output PDB file.
    type: File
    outputSource: step17_cmip_prepare_structure/output_cmip_pdb_path
  step18_extract_chain_a_out1:
    label: output_structure_path
    doc: Output structure file path.
    type: File
    outputSource: step18_extract_chain_a/output_structure_path
  step19_extract_chain_b_out1:
    label: output_structure_path
    doc: Output structure file path.
    type: File
    outputSource: step19_extract_chain_b/output_structure_path
  step20_cmip_run_rbd_out1:
    label: output_log_path
    doc: Path to the output CMIP log file LOG.
    type: File
    outputSource: step20_cmip_run_rbd/output_log_path
  step20_cmip_run_rbd_out2:
    label: output_json_box_path
    doc: Path to the output CMIP box in JSON format.
    type: File
    outputSource: step20_cmip_run_rbd/output_json_box_path
  step21_cmip_run_hace2_out1:
    label: output_log_path
    doc: Path to the output CMIP log file LOG.
    type: File
    outputSource: step21_cmip_run_hace2/output_log_path
  step21_cmip_run_hace2_out2:
    label: output_json_box_path
    doc: Path to the output CMIP box in JSON format.
    type: File
    outputSource: step21_cmip_run_hace2/output_json_box_path
  step22_cmip_run_rbd_hace2_out1:
    label: output_log_path
    doc: Path to the output CMIP log file LOG.
    type: File
    outputSource: step22_cmip_run_rbd_hace2/output_log_path
  step22_cmip_run_rbd_hace2_out2:
    label: output_json_box_path
    doc: Path to the output CMIP box in JSON format.
    type: File
    outputSource: step22_cmip_run_rbd_hace2/output_json_box_path
  step23_cmip_ignore_residues_rbd_out1:
    label: output_cmip_pdb_path
    doc: Output PDB file path.
    type: File
    outputSource: step23_cmip_ignore_residues_rbd/output_cmip_pdb_path
  step24_cmip_run_prot_prot_out1:
    label: output_json_box_path
    doc: Path to the output CMIP box in JSON format.
    type: File
    outputSource: step24_cmip_run_prot_prot/output_json_box_path
  step24_cmip_run_prot_prot_out2:
    label: output_json_external_box_path
    doc: Path to the output external CMIP box in JSON format.
    type: File
    outputSource: step24_cmip_run_prot_prot/output_json_external_box_path
  step24_cmip_run_prot_prot_out3:
    label: output_log_path
    doc: Path to the output CMIP log file LOG.
    type: File
    outputSource: step24_cmip_run_prot_prot/output_log_path
  step24_cmip_run_prot_prot_out4:
    label: output_byat_path
    doc: Path to the output atom by atom energy file.
    type: File
    outputSource: step24_cmip_run_prot_prot/output_byat_path
  step25_cmip_ignore_residues_hace2_out1:
    label: output_cmip_pdb_path
    doc: Output PDB file path.
    type: File
    outputSource: step25_cmip_ignore_residues_hace2/output_cmip_pdb_path
  step26_cmip_run_complex_out1:
    label: output_json_box_path
    doc: Path to the output CMIP box in JSON format.
    type: File
    outputSource: step26_cmip_run_complex/output_json_box_path
  step26_cmip_run_complex_out2:
    label: output_json_external_box_path
    doc: Path to the output external CMIP box in JSON format.
    type: File
    outputSource: step26_cmip_run_complex/output_json_external_box_path
  step26_cmip_run_complex_out3:
    label: output_log_path
    doc: Path to the output CMIP log file LOG.
    type: File
    outputSource: step26_cmip_run_complex/output_log_path
  step26_cmip_run_complex_out4:
    label: output_byat_path
    doc: Path to the output atom by atom energy file.
    type: File
    outputSource: step26_cmip_run_complex/output_byat_path
steps:
  step0_cmip_prepare_pdb:
    label: cmip_prepare_pdb
    doc: Creates a CMIP suitable PDB from an standar PDB file
    run: biobb_adapters/cmip_prepare_pdb.cwl
    in:
      input_pdb_path: step0_cmip_prepare_pdb_input_pdb_path
      output_cmip_pdb_path: step0_cmip_prepare_pdb_output_cmip_pdb_path
    out:
    - output_cmip_pdb_path
  step1_cmip_titration:
    label: cmip_titration
    doc: CMIP cmip module compute classical molecular interaction potentials.
    run: biobb_adapters/cmip_titration.cwl
    in:
      config: step1_cmip_titration_config
      input_pdb_path: step0_cmip_prepare_pdb/output_cmip_pdb_path
      output_pdb_path: step1_cmip_titration_output_pdb_path
    out:
    - output_pdb_path
  step2_cat_pdb:
    label: cat_pdb
    doc: Class to concat two PDB structures in a single PDB file.
    run: biobb_adapters/cat_pdb.cwl
    in:
      input_structure1: step0_cmip_prepare_pdb/output_cmip_pdb_path
      input_structure2: step1_cmip_titration/output_pdb_path
      output_structure_path: step2_cat_pdb_output_structure_path
    out:
    - output_structure_path
  step3_cmip_run_pos:
    label: cmip_run
    doc: CMIP cmip module compute classical molecular interaction potentials.
    run: biobb_adapters/cmip_run.cwl
    in:
      config: step3_cmip_run_pos_config
      input_pdb_path: step0_cmip_prepare_pdb/output_cmip_pdb_path
      output_log_path: step3_cmip_run_pos_output_log_path
      output_cube_path: step3_cmip_run_pos_output_cube_path
    out:
    - output_log_path
    - output_cube_path
  step4_cmip_run_neg:
    label: cmip_run
    doc: CMIP cmip module compute classical molecular interaction potentials.
    run: biobb_adapters/cmip_run.cwl
    in:
      config: step4_cmip_run_neg_config
      input_pdb_path: step0_cmip_prepare_pdb/output_cmip_pdb_path
      output_log_path: step4_cmip_run_neg_output_log_path
      output_cube_path: step4_cmip_run_neg_output_cube_path
    out:
    - output_log_path
    - output_cube_path
  step5_cmip_run_neu:
    label: cmip_run
    doc: CMIP cmip module compute classical molecular interaction potentials.
    run: biobb_adapters/cmip_run.cwl
    in:
      config: step5_cmip_run_neu_config
      input_pdb_path: step0_cmip_prepare_pdb/output_cmip_pdb_path
      output_log_path: step5_cmip_run_neu_output_log_path
      output_cube_path: step5_cmip_run_neu_output_cube_path
    out:
    - output_log_path
    - output_cube_path
  step6_remove_pdb_water:
    label: remove_pdb_water
    doc: This class is a wrapper of the Structure Checking tool to remove water molecules from PDB 3D structures.
    run: biobb_adapters/remove_pdb_water.cwl
    in:
      input_pdb_path: step6_remove_pdb_water_input_pdb_path
      output_pdb_path: step6_remove_pdb_water_output_pdb_path
    out:
    - output_pdb_path
  step7_extract_heteroatoms:
    label: extract_heteroatoms
    doc: Class to extract hetero-atoms from a 3D structure.
    run: biobb_adapters/extract_heteroatoms.cwl
    in:
      config: step7_extract_heteroatoms_config
      input_structure_path: step6_remove_pdb_water/output_pdb_path
      output_heteroatom_path: step7_extract_heteroatoms_output_heteroatom_path
    out:
    - output_heteroatom_path
  step8_reduce_add_hydrogens:
    label: reduce_add_hydrogens
    doc: Adds hydrogen atoms to small molecules.
    run: biobb_adapters/reduce_add_hydrogens.cwl
    in:
      input_path: step7_extract_heteroatoms/output_heteroatom_path
      output_path: step8_reduce_add_hydrogens_output_path
    out:
    - output_path
  step9_acpype_params_ac:
    label: acpype_params_ac
    doc: Small molecule parameterization for AMBER MD package.
    run: biobb_adapters/acpype_params_ac.cwl
    in:
      config: step9_acpype_params_ac_config
      input_path: step8_reduce_add_hydrogens/output_path
      output_path_inpcrd: step9_acpype_params_ac_output_path_inpcrd
      output_path_frcmod: step9_acpype_params_ac_output_path_frcmod
      output_path_lib: step9_acpype_params_ac_output_path_lib
      output_path_prmtop: step9_acpype_params_ac_output_path_prmtop
    out:
    - output_path_inpcrd
    - output_path_frcmod
    - output_path_lib
    - output_path_prmtop
  step10_leap_gen_top:
    label: leap_gen_top
    doc: Generates a MD topology from a molecule structure using tLeap tool from the AmberTools MD package
    run: biobb_adapters/leap_gen_top.cwl
    in:
      config: step10_leap_gen_top_config
      input_pdb_path: step6_remove_pdb_water/output_pdb_path
      input_lib_path: step9_acpype_params_ac/output_path_lib
      input_frcmod_path: step9_acpype_params_ac/output_path_frcmod
      output_pdb_path: step10_leap_gen_top_output_pdb_path
      output_top_path: step10_leap_gen_top_output_top_path
      output_crd_path: step10_leap_gen_top_output_crd_path
    out:
    - output_pdb_path
    - output_top_path
    - output_crd_path
  step11_sander_mdrun:
    label: sander_mdrun
    doc: Runs energy minimization, molecular dynamics, and NMR refinements using sander tool from the AmberTools MD package
    run: biobb_adapters/sander_mdrun.cwl
    in:
      config: step11_sander_mdrun_config
      input_top_path: step10_leap_gen_top/output_top_path
      input_crd_path: step10_leap_gen_top/output_crd_path
      output_traj_path: step11_sander_mdrun_output_traj_path
      output_rst_path: step11_sander_mdrun_output_rst_path
      output_log_path: step11_sander_mdrun_output_log_path
    out:
    - output_traj_path
    - output_rst_path
    - output_log_path
  step12_amber_to_pdb:
    label: amber_to_pdb
    doc: Generates a PDB structure from AMBER topology (parmtop) and coordinates (crd) files, using the ambpdb tool from the AmberTools MD package
    run: biobb_adapters/amber_to_pdb.cwl
    in:
      input_top_path: step10_leap_gen_top/output_top_path
      input_crd_path: step11_sander_mdrun/output_rst_path
      output_pdb_path: step12_amber_to_pdb_output_pdb_path
    out:
    - output_pdb_path
  step13_cmip_prepare_structure:
    label: cmip_prepare_structure
    doc: Creates a CMIP suitable PDB from an standar structure file
    run: biobb_adapters/cmip_prepare_structure.cwl
    in:
      input_pdb_path: step12_amber_to_pdb/output_pdb_path
      input_topology_path: step10_leap_gen_top/output_top_path
      output_cmip_pdb_path: step13_cmip_prepare_structure_output_cmip_pdb_path
    out:
    - output_cmip_pdb_path
  step14_remove_ligand:
    label: remove_ligand
    doc: Class to remove the selected ligand atoms from a 3D structure.
    run: biobb_adapters/remove_ligand.cwl
    in:
      config: step14_remove_ligand_config
      input_structure_path: step13_cmip_prepare_structure/output_cmip_pdb_path
      output_structure_path: step14_remove_ligand_output_structure_path
    out:
    - output_structure_path
  step15_cmip_ignore_residues:
    label: cmip_ignore_residues
    doc: Mark residues which charges will be ignored in the CMIP potential calculations.
    run: biobb_adapters/cmip_ignore_residues.cwl
    in:
      config: step15_cmip_ignore_residues_config
      input_cmip_pdb_path: step13_cmip_prepare_structure/output_cmip_pdb_path
      output_cmip_pdb_path: step15_cmip_ignore_residues_output_cmip_pdb_path
    out:
    - output_cmip_pdb_path
  step16_cmip_run_int_en:
    label: cmip_run
    doc: CMIP cmip module compute classical molecular interaction potentials.
    run: biobb_adapters/cmip_run.cwl
    in:
      config: step16_cmip_run_int_en_config
      input_pdb_path: step15_cmip_ignore_residues/output_cmip_pdb_path
      input_probe_pdb_path: step14_remove_ligand/output_structure_path
      output_log_path: step16_cmip_run_int_en_output_log_path
      output_byat_path: step16_cmip_run_int_en_output_byat_path
    out:
    - output_log_path
    - output_byat_path
  step17_cmip_prepare_structure:
    label: cmip_prepare_structure
    doc: Creates a CMIP suitable PDB from an standar structure file
    run: biobb_adapters/cmip_prepare_structure.cwl
    in:
      input_pdb_path: step17_cmip_prepare_structure_input_pdb_path
      input_topology_path: step17_cmip_prepare_structure_input_topology_path
      output_cmip_pdb_path: step17_cmip_prepare_structure_output_cmip_pdb_path
    out:
    - output_cmip_pdb_path
  step18_extract_chain_a:
    label: extract_chain
    doc: This class is a wrapper of the Structure Checking tool to extract a chain from a 3D structure.
    run: biobb_adapters/extract_chain.cwl
    in:
      config: step18_extract_chain_a_config
      input_structure_path: step17_cmip_prepare_structure/output_cmip_pdb_path
      output_structure_path: step18_extract_chain_a_output_structure_path
    out:
    - output_structure_path
  step19_extract_chain_b:
    label: extract_chain
    doc: This class is a wrapper of the Structure Checking tool to extract a chain from a 3D structure.
    run: biobb_adapters/extract_chain.cwl
    in:
      config: step19_extract_chain_b_config
      input_structure_path: step17_cmip_prepare_structure/output_cmip_pdb_path
      output_structure_path: step19_extract_chain_b_output_structure_path
    out:
    - output_structure_path
  step20_cmip_run_rbd:
    label: cmip_run
    doc: CMIP cmip module compute classical molecular interaction potentials.
    run: biobb_adapters/cmip_run.cwl
    in:
      config: step20_cmip_run_rbd_config
      input_pdb_path: step19_extract_chain_b/output_structure_path
      output_log_path: step20_cmip_run_rbd_output_log_path
      output_json_box_path: step20_cmip_run_rbd_output_json_box_path
    out:
    - output_log_path
    - output_json_box_path
  step21_cmip_run_hace2:
    label: cmip_run
    doc: CMIP cmip module compute classical molecular interaction potentials.
    run: biobb_adapters/cmip_run.cwl
    in:
      config: step21_cmip_run_hace2_config
      input_pdb_path: step18_extract_chain_a/output_structure_path
      output_log_path: step21_cmip_run_hace2_output_log_path
      output_json_box_path: step21_cmip_run_hace2_output_json_box_path
    out:
    - output_log_path
    - output_json_box_path
  step22_cmip_run_rbd_hace2:
    label: cmip_run
    doc: CMIP cmip module compute classical molecular interaction potentials.
    run: biobb_adapters/cmip_run.cwl
    in:
      config: step22_cmip_run_rbd_hace2_config
      input_pdb_path: step17_cmip_prepare_structure/output_cmip_pdb_path
      output_log_path: step22_cmip_run_rbd_hace2_output_log_path
      output_json_box_path: step22_cmip_run_rbd_hace2_output_json_box_path
    out:
    - output_log_path
    - output_json_box_path
  step23_cmip_ignore_residues_rbd:
    label: cmip_ignore_residues
    doc: Mark residues which charges will be ignored in the CMIP potential calculations.
    run: biobb_adapters/cmip_ignore_residues.cwl
    in:
      config: step23_cmip_ignore_residues_rbd_config
      input_cmip_pdb_path: step17_cmip_prepare_structure/output_cmip_pdb_path
      output_cmip_pdb_path: step23_cmip_ignore_residues_rbd_output_cmip_pdb_path
    out:
    - output_cmip_pdb_path
  step24_cmip_run_prot_prot:
    label: cmip_run
    doc: CMIP cmip module compute classical molecular interaction potentials.
    run: biobb_adapters/cmip_run.cwl
    in:
      config: step24_cmip_run_prot_prot_config
      input_pdb_path: step23_cmip_ignore_residues_rbd/output_cmip_pdb_path
      input_probe_pdb_path: step19_extract_chain_b/output_structure_path
      input_json_box_path: step20_cmip_run_rbd/output_json_box_path
      input_json_external_box_path: step22_cmip_run_rbd_hace2/output_json_box_path
      output_json_box_path: step24_cmip_run_prot_prot_output_json_box_path
      output_json_external_box_path: step24_cmip_run_prot_prot_output_json_external_box_path
      output_log_path: step24_cmip_run_prot_prot_output_log_path
      output_byat_path: step24_cmip_run_prot_prot_output_byat_path
    out:
    - output_json_box_path
    - output_json_external_box_path
    - output_log_path
    - output_byat_path
  step25_cmip_ignore_residues_hace2:
    label: cmip_ignore_residues
    doc: Mark residues which charges will be ignored in the CMIP potential calculations.
    run: biobb_adapters/cmip_ignore_residues.cwl
    in:
      config: step25_cmip_ignore_residues_hace2_config
      input_cmip_pdb_path: step17_cmip_prepare_structure/output_cmip_pdb_path
      output_cmip_pdb_path: step25_cmip_ignore_residues_hace2_output_cmip_pdb_path
    out:
    - output_cmip_pdb_path
  step26_cmip_run_complex:
    label: cmip_run
    doc: CMIP cmip module compute classical molecular interaction potentials.
    run: biobb_adapters/cmip_run.cwl
    in:
      config: step26_cmip_run_complex_config
      input_pdb_path: step25_cmip_ignore_residues_hace2/output_cmip_pdb_path
      input_probe_pdb_path: step18_extract_chain_a/output_structure_path
      input_json_box_path: step21_cmip_run_hace2/output_json_box_path
      input_json_external_box_path: step22_cmip_run_rbd_hace2/output_json_box_path
      output_json_box_path: step26_cmip_run_complex_output_json_box_path
      output_json_external_box_path: step26_cmip_run_complex_output_json_external_box_path
      output_log_path: step26_cmip_run_complex_output_log_path
      output_byat_path: step26_cmip_run_complex_output_byat_path
    out:
    - output_json_box_path
    - output_json_external_box_path
    - output_log_path
    - output_byat_path
