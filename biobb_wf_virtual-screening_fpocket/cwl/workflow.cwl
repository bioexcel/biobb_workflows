#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
label: Protein-ligand docking
doc: |-
  This workflow performs the process of protein-ligand docking, step by step, using the BioExcel Building Blocks library (biobb).
inputs:
  step1_fpocket_select_input_pockets_zip:
    label: Input file
    doc: Path to the pockets found by fpocket.
    type: File
  step1_fpocket_select_output_pocket_pdb:
    label: Output file
    doc: Path to the PDB file with the cavity found by fpocket.
    type: string
  step1_fpocket_select_output_pocket_pqr:
    label: Output file
    doc: Path to the PQR file with the pocket found by fpocket.
    type: string
  step1_fpocket_select_config:
    label: Config file
    doc: Configuration file for biobb_vs.fpocket_select tool.
    type: string
  step2_box_output_pdb_path:
    label: Output file
    doc: PDB including the annotation of the box center and size as REMARKs.
    type: string
  step2_box_config:
    label: Config file
    doc: Configuration file for biobb_vs.box tool.
    type: string
  step3_babel_convert_prep_lig_input_path:
    label: Input file
    doc: Path to the input file.
    type: File
  step3_babel_convert_prep_lig_output_path:
    label: Output file
    doc: Path to the output file.
    type: string
  step3_babel_convert_prep_lig_config:
    label: Config file
    doc: Configuration file for biobb_chemistry.babel_convert tool.
    type: string
  step4_str_check_add_hydrogens_input_structure_path:
    label: Input file
    doc: Input structure file path.
    type: File
  step4_str_check_add_hydrogens_output_structure_path:
    label: Output file
    doc: Output structure file path.
    type: string
  step4_str_check_add_hydrogens_config:
    label: Config file
    doc: Configuration file for biobb_structure_utils.str_check_add_hydrogens tool.
    type: string
  step5_autodock_vina_run_output_pdbqt_path:
    label: Output file
    doc: Path to the output PDBQT file.
    type: string
  step5_autodock_vina_run_output_log_path:
    label: Output file
    doc: Path to the log file.
    type: string
  step6_babel_convert_pose_pdb_output_path:
    label: Output file
    doc: Path to the output file.
    type: string
  step6_babel_convert_pose_pdb_config:
    label: Config file
    doc: Configuration file for biobb_chemistry.babel_convert tool.
    type: string
outputs:
  step1_fpocket_select_out1:
    label: output_pocket_pdb
    doc: Path to the PDB file with the cavity found by fpocket.
    type: File
    outputSource: step1_fpocket_select/output_pocket_pdb
  step1_fpocket_select_out2:
    label: output_pocket_pqr
    doc: Path to the PQR file with the pocket found by fpocket.
    type: File
    outputSource: step1_fpocket_select/output_pocket_pqr
  step2_box_out1:
    label: output_pdb_path
    doc: PDB including the annotation of the box center and size as REMARKs.
    type: File
    outputSource: step2_box/output_pdb_path
  step3_babel_convert_prep_lig_out1:
    label: output_path
    doc: Path to the output file.
    type: File
    outputSource: step3_babel_convert_prep_lig/output_path
  step4_str_check_add_hydrogens_out1:
    label: output_structure_path
    doc: Output structure file path.
    type: File
    outputSource: step4_str_check_add_hydrogens/output_structure_path
  step5_autodock_vina_run_out1:
    label: output_pdbqt_path
    doc: Path to the output PDBQT file.
    type: File
    outputSource: step5_autodock_vina_run/output_pdbqt_path
  step5_autodock_vina_run_out2:
    label: output_log_path
    doc: Path to the log file.
    type: File
    outputSource: step5_autodock_vina_run/output_log_path
  step6_babel_convert_pose_pdb_out1:
    label: output_path
    doc: Path to the output file.
    type: File
    outputSource: step6_babel_convert_pose_pdb/output_path
steps:
  step1_fpocket_select:
    label: fpocket_select
    doc: Selects a single pocket in the outputs of the fpocket building block..
    run: biobb_adapters/fpocket_select.cwl
    in:
      config: step1_fpocket_select_config
      input_pockets_zip: step1_fpocket_select_input_pockets_zip
      output_pocket_pdb: step1_fpocket_select_output_pocket_pdb
      output_pocket_pqr: step1_fpocket_select_output_pocket_pqr
    out:
    - output_pocket_pdb
    - output_pocket_pqr
  step2_box:
    label: box
    doc: This class sets the center and the size of a rectangular parallelepiped box around a set of residues or a pocket.
    run: biobb_adapters/box.cwl
    in:
      config: step2_box_config
      input_pdb_path: step1_fpocket_select/output_pocket_pqr
      output_pdb_path: step2_box_output_pdb_path
    out:
    - output_pdb_path
  step3_babel_convert_prep_lig:
    label: babel_convert
    doc: Small molecule format conversion.
    run: biobb_adapters/babel_convert.cwl
    in:
      config: step3_babel_convert_prep_lig_config
      input_path: step3_babel_convert_prep_lig_input_path
      output_path: step3_babel_convert_prep_lig_output_path
    out:
    - output_path
  step4_str_check_add_hydrogens:
    label: str_check_add_hydrogens
    doc: This class is a wrapper of the Structure Checking tool to add hydrogens to a 3D structure.
    run: biobb_adapters/str_check_add_hydrogens.cwl
    in:
      config: step4_str_check_add_hydrogens_config
      input_structure_path: step4_str_check_add_hydrogens_input_structure_path
      output_structure_path: step4_str_check_add_hydrogens_output_structure_path
    out:
    - output_structure_path
  step5_autodock_vina_run:
    label: autodock_vina_run
    doc: Wrapper of the AutoDock Vina software.
    run: biobb_adapters/autodock_vina_run.cwl
    in:
      input_ligand_pdbqt_path: step3_babel_convert_prep_lig/output_path
      input_receptor_pdbqt_path: step4_str_check_add_hydrogens/output_structure_path
      input_box_path: step2_box/output_pdb_path
      output_pdbqt_path: step5_autodock_vina_run_output_pdbqt_path
      output_log_path: step5_autodock_vina_run_output_log_path
    out:
    - output_pdbqt_path
    - output_log_path
  step6_babel_convert_pose_pdb:
    label: babel_convert
    doc: Small molecule format conversion.
    run: biobb_adapters/babel_convert.cwl
    in:
      config: step6_babel_convert_pose_pdb_config
      input_path: step5_autodock_vina_run/output_pdbqt_path
      output_path: step6_babel_convert_pose_pdb_output_path
    out:
    - output_path
