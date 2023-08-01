#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
label: Protein conformational transitions
doc: This tutorial aims to illustrate the process of computing a conformational transition between two known structural conformations of a protein, step by step.
inputs:
  step0_extract_chain_input_structure_path:
    label: Input file
    doc: Input structure file path.
    type: File
  step0_extract_chain_output_structure_path:
    label: Output file
    doc: Output structure file path.
    type: string
  step0_extract_chain_config:
    label: Config file
    doc: Configuration file for biobb_structure_utils.extract_chain tool.
    type: string
  step1_extract_chain_input_structure_path:
    label: Input file
    doc: Input structure file path.
    type: File
  step1_extract_chain_output_structure_path:
    label: Output file
    doc: Output structure file path.
    type: string
  step1_extract_chain_config:
    label: Config file
    doc: Configuration file for biobb_structure_utils.extract_chain tool.
    type: string
  step2_remove_molecules_output_molecules_path:
    label: Output file
    doc: Output molcules file path.
    type: string
  step2_remove_molecules_config:
    label: Config file
    doc: Configuration file for biobb_structure_utils.remove_molecules tool.
    type: string
  # uncomment if the target structure has a ligand
  # step3_remove_molecules_output_molecules_path:
  #   label: Output file
  #   doc: Output molcules file path.
  #   type: string
  # step3_remove_molecules_config:
  #   label: Config file
  #   doc: Configuration file for biobb_structure_utils.remove_molecules tool.
  #   type: string
  step4_godmd_prep_output_aln_orig_path:
    label: Output file
    doc: Output GOdMD alignment file corresponding to the origin structure of the conformational transition.
    type: string
  step4_godmd_prep_output_aln_target_path:
    label: Output file
    doc: Output GOdMD alignment file corresponding to the target structure of the conformational transition.
    type: string
  step4_godmd_prep_config:
    label: Config file
    doc: Configuration file for biobb_godmd.godmd_prep tool.
    type: string
  step5_godmd_run_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step5_godmd_run_output_ene_path:
    label: Output file
    doc: Output energy file.
    type: string
  step5_godmd_run_output_trj_path:
    label: Output file
    doc: Output trajectory file.
    type: string
  step5_godmd_run_output_pdb_path:
    label: Output file
    doc: Output structure file.
    type: string
  step5_godmd_run_config:
    label: Config file
    doc: Configuration file for biobb_godmd.godmd_run tool.
    type: string
  step6_cpptraj_convert_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed trajectory.
    type: string
  step6_cpptraj_convert_config:
    label: Config file
    doc: Configuration file for biobb_analysis.cpptraj_convert tool.
    type: string
outputs:
  step0_extract_chain_out1:
    label: output_structure_path
    doc: Output structure file path.
    type: File
    outputSource: step0_extract_chain/output_structure_path
  step1_extract_chain_out1:
    label: output_structure_path
    doc: Output structure file path.
    type: File
    outputSource: step1_extract_chain/output_structure_path
  step2_remove_molecules_out1:
    label: output_molecules_path
    doc: Output molcules file path.
    type: File
    outputSource: step2_remove_molecules/output_molecules_path
  # uncomment if the target structure has a ligand
  # step3_remove_molecules_out1:
  #   label: output_molecules_path
  #   doc: Output molcules file path.
  #   type: File
  #   outputSource: step3_remove_molecules/output_molecules_path
  step4_godmd_prep_out1:
    label: output_aln_orig_path
    doc: Output GOdMD alignment file corresponding to the origin structure of the conformational transition.
    type: File
    outputSource: step4_godmd_prep/output_aln_orig_path
  step4_godmd_prep_out2:
    label: output_aln_target_path
    doc: Output GOdMD alignment file corresponding to the target structure of the conformational transition.
    type: File
    outputSource: step4_godmd_prep/output_aln_target_path
  step5_godmd_run_out1:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step5_godmd_run/output_log_path
  step5_godmd_run_out2:
    label: output_ene_path
    doc: Output energy file.
    type: File
    outputSource: step5_godmd_run/output_ene_path
  step5_godmd_run_out3:
    label: output_trj_path
    doc: Output trajectory file.
    type: File
    outputSource: step5_godmd_run/output_trj_path
  step5_godmd_run_out4:
    label: output_pdb_path
    doc: Output structure file.
    type: File
    outputSource: step5_godmd_run/output_pdb_path
  step6_cpptraj_convert_out1:
    label: output_cpptraj_path
    doc: Path to the output processed trajectory.
    type: File
    outputSource: step6_cpptraj_convert/output_cpptraj_path
steps:
  step0_extract_chain:
    label: extract_chain
    doc: This class is a wrapper of the Structure Checking tool to extract a chain from a 3D structure.
    run: biobb_adapters/extract_chain.cwl
    in:
      config: step0_extract_chain_config
      input_structure_path: step0_extract_chain_input_structure_path
      output_structure_path: step0_extract_chain_output_structure_path
    out:
    - output_structure_path
  step1_extract_chain:
    label: extract_chain
    doc: This class is a wrapper of the Structure Checking tool to extract a chain from a 3D structure.
    run: biobb_adapters/extract_chain.cwl
    in:
      config: step1_extract_chain_config
      input_structure_path: step1_extract_chain_input_structure_path
      output_structure_path: step1_extract_chain_output_structure_path
    out:
    - output_structure_path
  step2_remove_molecules:
    label: remove_molecules
    doc: Class to remove molecules from a 3D structure using Biopython.
    run: biobb_adapters/remove_molecules.cwl
    in:
      config: step2_remove_molecules_config
      input_structure_path: step0_extract_chain/output_structure_path
      output_molecules_path: step2_remove_molecules_output_molecules_path
    out:
    - output_molecules_path
  # uncomment if the target structure has a ligand
  # step3_remove_molecules:
  #   label: remove_molecules
  #   doc: Class to remove molecules from a 3D structure using Biopython.
  #   run: biobb_adapters/remove_molecules.cwl
  #   in:
  #     config: step3_remove_molecules_config
  #     input_structure_path: step1_extract_chain/output_structure_path
  #     output_molecules_path: step3_remove_molecules_output_molecules_path
  #   out:
  #   - output_molecules_path
  step4_godmd_prep:
    label: godmd_prep
    doc: Helper BioBB to prepare inputs for the GOdMD tool (protein conformational transitions).
    run: biobb_adapters/godmd_prep.cwl
    in:
      config: step4_godmd_prep_config
      input_pdb_orig_path: step2_remove_molecules/output_molecules_path
      # uncomment if the target structure has a ligand
      # input_pdb_target_path: step3_remove_molecules/output_molecules_path
      # comment if the target structure has a ligand
      input_pdb_target_path: step1_extract_chain/output_structure_path
      output_aln_orig_path: step4_godmd_prep_output_aln_orig_path
      output_aln_target_path: step4_godmd_prep_output_aln_target_path
    out:
    - output_aln_orig_path
    - output_aln_target_path
  step5_godmd_run:
    label: godmd_run
    doc: Wrapper of the GOdMD tool to compute protein conformational transitions.
    run: biobb_adapters/godmd_run.cwl
    in:
      config: step5_godmd_run_config
      input_pdb_orig_path: step2_remove_molecules/output_molecules_path
      # uncomment if the target structure has a ligand
      # input_pdb_target_path: step3_remove_molecules/output_molecules_path
      # comment if the target structure has a ligand
      input_pdb_target_path: step1_extract_chain/output_structure_path
      input_aln_orig_path: step4_godmd_prep/output_aln_orig_path
      input_aln_target_path: step4_godmd_prep/output_aln_target_path
      output_log_path: step5_godmd_run_output_log_path
      output_ene_path: step5_godmd_run_output_ene_path
      output_trj_path: step5_godmd_run_output_trj_path
      output_pdb_path: step5_godmd_run_output_pdb_path
    out:
    - output_log_path
    - output_ene_path
    - output_trj_path
    - output_pdb_path
  step6_cpptraj_convert:
    label: cpptraj_convert
    doc: Wrapper of the Ambertools Cpptraj module for converting between cpptraj compatible trajectory file formats and/or extracting a selection of atoms or frames.
    run: biobb_adapters/cpptraj_convert.cwl
    in:
      config: step6_cpptraj_convert_config
      input_top_path: step5_godmd_run/output_pdb_path
      input_traj_path: step5_godmd_run/output_pdb_path
      output_cpptraj_path: step6_cpptraj_convert_output_cpptraj_path
    out:
    - output_cpptraj_path
