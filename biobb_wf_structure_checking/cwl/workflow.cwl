#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
label: Molecular Structure Checking
doc: |-
  This workflow aims to illustrate the process of checking a molecular structure before using it as an input for a Molecular Dynamics simulation.
inputs:
  step0_structure_check_init_input_structure_path:
    label: Input file
    doc: Input structure file path.
    type: File
  step0_structure_check_init_output_summary_path:
    label: Output file
    doc: Output summary checking results.
    type: string
  step1_extract_model_input_structure_path:
    label: Input file
    doc: Input structure file path.
    type: File
  step1_extract_model_output_structure_path:
    label: Output file
    doc: Output structure file path.
    type: string
  step1_extract_model_config:
    label: Config file
    doc: Configuration file for biobb_structure_utils.extract_model tool.
    type: string
  step2_extract_chain_output_structure_path:
    label: Output file
    doc: Output structure file path.
    type: string
  step2_extract_chain_config:
    label: Config file
    doc: Configuration file for biobb_structure_utils.extract_chain tool.
    type: string
  step3_fix_altlocs_output_pdb_path:
    label: Output file
    doc: Output PDB file path.
    type: string
  step3_fix_altlocs_config:
    label: Config file
    doc: Configuration file for biobb_model.fix_altlocs tool.
    type: string
  step4_fix_ssbonds_output_pdb_path:
    label: Output file
    doc: Output PDB file path.
    type: string
  step5_remove_molecules_ions_output_molecules_path:
    label: Output file
    doc: Output molcules file path.
    type: string
  step5_remove_molecules_ions_config:
    label: Config file
    doc: Configuration file for biobb_structure_utils.remove_molecules tool.
    type: string
  step6_remove_molecules_ligands_output_molecules_path:
    label: Output file
    doc: Output molcules file path.
    type: string
  step6_remove_molecules_ligands_config:
    label: Config file
    doc: Configuration file for biobb_structure_utils.remove_molecules tool.
    type: string
  step7_reduce_remove_hydrogens_output_path:
    label: Output file
    doc: Path to the output file.
    type: string
  step8_remove_pdb_water_output_pdb_path:
    label: Output file
    doc: Output PDB file path.
    type: string
  step9_fix_amides_output_pdb_path:
    label: Output file
    doc: Output PDB file path.
    type: string
  step10_fix_chirality_output_pdb_path:
    label: Output file
    doc: Output PDB file path.
    type: string
  step11_fix_side_chain_output_pdb_path:
    label: Output file
    doc: Output PDB file path.
    type: string
  step12_fix_backbone_input_fasta_canonical_sequence_path:
    label: Input file
    doc: Input FASTA file path.
    type: File
  step12_fix_backbone_output_pdb_path:
    label: Output file
    doc: Output PDB file path.
    type: string
  step13_leap_gen_top_output_pdb_path:
    label: Output file
    doc: Output 3D structure PDB file matching the topology file.
    type: string
  step13_leap_gen_top_output_top_path:
    label: Output file
    doc: Output topology file (AMBER ParmTop).
    type: string
  step13_leap_gen_top_output_crd_path:
    label: Output file
    doc: Output coordinates file (AMBER crd).
    type: string
  step13_leap_gen_top_config:
    label: Config file
    doc: Configuration file for biobb_amber.leap_gen_top tool.
    type: string
  step14_sander_mdrun_output_traj_path:
    label: Output file
    doc: Output trajectory file.
    type: string
  step14_sander_mdrun_output_rst_path:
    label: Output file
    doc: Output restart file.
    type: string
  step14_sander_mdrun_output_log_path:
    label: Output file
    doc: Output log file.
    type: string
  step14_sander_mdrun_config:
    label: Config file
    doc: Configuration file for biobb_amber.sander_mdrun tool.
    type: string
  step15_amber_to_pdb_output_pdb_path:
    label: Output file
    doc: Structure PDB file.
    type: string
  step16_fix_pdb_output_pdb_path:
    label: Output file
    doc: Output PDB file path.
    type: string
  step17_structure_check_output_summary_path:
    label: Output file
    doc: Output summary checking results.
    type: string
outputs:
  step0_structure_check_init_out1:
    label: output_summary_path
    doc: Output summary checking results.
    type: File
    outputSource: step0_structure_check_init/output_summary_path
  step1_extract_model_out1:
    label: output_structure_path
    doc: Output structure file path.
    type: File
    outputSource: step1_extract_model/output_structure_path
  step2_extract_chain_out1:
    label: output_structure_path
    doc: Output structure file path.
    type: File
    outputSource: step2_extract_chain/output_structure_path
  step3_fix_altlocs_out1:
    label: output_pdb_path
    doc: Output PDB file path.
    type: File
    outputSource: step3_fix_altlocs/output_pdb_path
  step4_fix_ssbonds_out1:
    label: output_pdb_path
    doc: Output PDB file path.
    type: File
    outputSource: step4_fix_ssbonds/output_pdb_path
  step5_remove_molecules_ions_out1:
    label: output_molecules_path
    doc: Output molcules file path.
    type: File
    outputSource: step5_remove_molecules_ions/output_molecules_path
  step6_remove_molecules_ligands_out1:
    label: output_molecules_path
    doc: Output molcules file path.
    type: File
    outputSource: step6_remove_molecules_ligands/output_molecules_path
  step7_reduce_remove_hydrogens_out1:
    label: output_path
    doc: Path to the output file.
    type: File
    outputSource: step7_reduce_remove_hydrogens/output_path
  step8_remove_pdb_water_out1:
    label: output_pdb_path
    doc: Output PDB file path.
    type: File
    outputSource: step8_remove_pdb_water/output_pdb_path
  step9_fix_amides_out1:
    label: output_pdb_path
    doc: Output PDB file path.
    type: File
    outputSource: step9_fix_amides/output_pdb_path
  step10_fix_chirality_out1:
    label: output_pdb_path
    doc: Output PDB file path.
    type: File
    outputSource: step10_fix_chirality/output_pdb_path
  step11_fix_side_chain_out1:
    label: output_pdb_path
    doc: Output PDB file path.
    type: File
    outputSource: step11_fix_side_chain/output_pdb_path
  step12_fix_backbone_out1:
    label: output_pdb_path
    doc: Output PDB file path.
    type: File
    outputSource: step12_fix_backbone/output_pdb_path
  step13_leap_gen_top_out1:
    label: output_pdb_path
    doc: Output 3D structure PDB file matching the topology file.
    type: File
    outputSource: step13_leap_gen_top/output_pdb_path
  step13_leap_gen_top_out2:
    label: output_top_path
    doc: Output topology file (AMBER ParmTop).
    type: File
    outputSource: step13_leap_gen_top/output_top_path
  step13_leap_gen_top_out3:
    label: output_crd_path
    doc: Output coordinates file (AMBER crd).
    type: File
    outputSource: step13_leap_gen_top/output_crd_path
  step14_sander_mdrun_out1:
    label: output_traj_path
    doc: Output trajectory file.
    type: File
    outputSource: step14_sander_mdrun/output_traj_path
  step14_sander_mdrun_out2:
    label: output_rst_path
    doc: Output restart file.
    type: File
    outputSource: step14_sander_mdrun/output_rst_path
  step14_sander_mdrun_out3:
    label: output_log_path
    doc: Output log file.
    type: File
    outputSource: step14_sander_mdrun/output_log_path
  step15_amber_to_pdb_out1:
    label: output_pdb_path
    doc: Structure PDB file.
    type: File
    outputSource: step15_amber_to_pdb/output_pdb_path
  step16_fix_pdb_out1:
    label: output_pdb_path
    doc: Output PDB file path.
    type: File
    outputSource: step16_fix_pdb/output_pdb_path
  step17_structure_check_out1:
    label: output_summary_path
    doc: Output summary checking results.
    type: File
    outputSource: step17_structure_check/output_summary_path
steps:
  step0_structure_check_init:
    label: structure_check
    doc: This class is a wrapper of the Structure Checking tool to generate summary checking results on a json file.
    run: biobb_adapters/structure_check.cwl
    in:
      input_structure_path: step0_structure_check_init_input_structure_path
      output_summary_path: step0_structure_check_init_output_summary_path
    out:
    - output_summary_path
  step1_extract_model:
    label: extract_model
    doc: This class is a wrapper of the Structure Checking tool to extract a model from a 3D structure.
    run: biobb_adapters/extract_model.cwl
    in:
      config: step1_extract_model_config
      input_structure_path: step1_extract_model_input_structure_path
      output_structure_path: step1_extract_model_output_structure_path
    out:
    - output_structure_path
  step2_extract_chain:
    label: extract_chain
    doc: This class is a wrapper of the Structure Checking tool to extract a chain from a 3D structure.
    run: biobb_adapters/extract_chain.cwl
    in:
      config: step2_extract_chain_config
      input_structure_path: step1_extract_model/output_structure_path
      output_structure_path: step2_extract_chain_output_structure_path
    out:
    - output_structure_path
  step3_fix_altlocs:
    label: fix_altlocs
    doc: Fix alternate locations from residues.
    run: biobb_adapters/fix_altlocs.cwl
    in:
      config: step3_fix_altlocs_config
      input_pdb_path: step2_extract_chain/output_structure_path
      output_pdb_path: step3_fix_altlocs_output_pdb_path
    out:
    - output_pdb_path
  step4_fix_ssbonds:
    label: fix_ssbonds
    doc: Fix SS bonds from residues.
    run: biobb_adapters/fix_ssbonds.cwl
    in:
      input_pdb_path: step3_fix_altlocs/output_pdb_path
      output_pdb_path: step4_fix_ssbonds_output_pdb_path
    out:
    - output_pdb_path
  step5_remove_molecules_ions:
    label: remove_molecules
    doc: Class to remove molecules from a 3D structure using Biopython.
    run: biobb_adapters/remove_molecules.cwl
    in:
      config: step5_remove_molecules_ions_config
      input_structure_path: step4_fix_ssbonds/output_pdb_path
      output_molecules_path: step5_remove_molecules_ions_output_molecules_path
    out:
    - output_molecules_path
  step6_remove_molecules_ligands:
    label: remove_molecules
    doc: Class to remove molecules from a 3D structure using Biopython.
    run: biobb_adapters/remove_molecules.cwl
    in:
      config: step6_remove_molecules_ligands_config
      input_structure_path: step5_remove_molecules_ions/output_molecules_path
      output_molecules_path: step6_remove_molecules_ligands_output_molecules_path
    out:
    - output_molecules_path
  step7_reduce_remove_hydrogens:
    label: reduce_remove_hydrogens
    doc: Removes hydrogen atoms to small molecules.
    run: biobb_adapters/reduce_remove_hydrogens.cwl
    in:
      input_path: step6_remove_molecules_ligands/output_molecules_path
      output_path: step7_reduce_remove_hydrogens_output_path
    out:
    - output_path
  step8_remove_pdb_water:
    label: remove_pdb_water
    doc: This class is a wrapper of the Structure Checking tool to remove water molecules from PDB 3D structures.
    run: biobb_adapters/remove_pdb_water.cwl
    in:
      input_pdb_path: step7_reduce_remove_hydrogens/output_path
      output_pdb_path: step8_remove_pdb_water_output_pdb_path
    out:
    - output_pdb_path
  step9_fix_amides:
    label: fix_amides
    doc: Creates a new PDB file flipping the clashing amide groups.
    run: biobb_adapters/fix_amides.cwl
    in:
      input_pdb_path: step8_remove_pdb_water/output_pdb_path
      output_pdb_path: step9_fix_amides_output_pdb_path
    out:
    - output_pdb_path
  step10_fix_chirality:
    label: fix_chirality
    doc: Creates a new PDB file fixing stereochemical errors in residue side-chains changing It's chirality.
    run: biobb_adapters/fix_chirality.cwl
    in:
      input_pdb_path: step9_fix_amides/output_pdb_path
      output_pdb_path: step10_fix_chirality_output_pdb_path
    out:
    - output_pdb_path
  step11_fix_side_chain:
    label: fix_side_chain
    doc: Reconstructs the missing side chains and heavy atoms of the given PDB file.
    run: biobb_adapters/fix_side_chain.cwl
    in:
      input_pdb_path: step10_fix_chirality/output_pdb_path
      output_pdb_path: step11_fix_side_chain_output_pdb_path
    out:
    - output_pdb_path
  step12_fix_backbone:
    label: fix_backbone
    doc: Reconstructs the missing backbone atoms of the given PDB file.
    run: biobb_adapters/fix_backbone.cwl
    in:
      input_pdb_path: step11_fix_side_chain/output_pdb_path
      input_fasta_canonical_sequence_path: step12_fix_backbone_input_fasta_canonical_sequence_path
      output_pdb_path: step12_fix_backbone_output_pdb_path
    out:
    - output_pdb_path
  step13_leap_gen_top:
    label: leap_gen_top
    doc: Generates a MD topology from a molecule structure using tLeap tool from the AmberTools MD package
    run: biobb_adapters/leap_gen_top.cwl
    in:
      config: step13_leap_gen_top_config
      input_pdb_path: step12_fix_backbone/output_pdb_path
      output_pdb_path: step13_leap_gen_top_output_pdb_path
      output_top_path: step13_leap_gen_top_output_top_path
      output_crd_path: step13_leap_gen_top_output_crd_path
    out:
    - output_pdb_path
    - output_top_path
    - output_crd_path
  step14_sander_mdrun:
    label: sander_mdrun
    doc: Runs energy minimization, molecular dynamics, and NMR refinements using sander tool from the AmberTools MD package
    run: biobb_adapters/sander_mdrun.cwl
    in:
      config: step14_sander_mdrun_config
      input_top_path: step13_leap_gen_top/output_top_path
      input_crd_path: step13_leap_gen_top/output_crd_path
      output_traj_path: step14_sander_mdrun_output_traj_path
      output_rst_path: step14_sander_mdrun_output_rst_path
      output_log_path: step14_sander_mdrun_output_log_path
    out:
    - output_traj_path
    - output_rst_path
    - output_log_path
  step15_amber_to_pdb:
    label: amber_to_pdb
    doc: Generates a PDB structure from AMBER topology (parmtop) and coordinates (crd) files, using the ambpdb tool from the AmberTools MD package
    run: biobb_adapters/amber_to_pdb.cwl
    in:
      input_top_path: step13_leap_gen_top/output_top_path
      input_crd_path: step14_sander_mdrun/output_rst_path
      output_pdb_path: step15_amber_to_pdb_output_pdb_path
    out:
    - output_pdb_path
  step16_fix_pdb:
    label: fix_pdb
    doc: Renumerates residues in a PDB structure according to a reference sequence from UniProt
    run: biobb_adapters/fix_pdb.cwl
    in:
      input_pdb_path: step15_amber_to_pdb/output_pdb_path
      output_pdb_path: step16_fix_pdb_output_pdb_path
    out:
    - output_pdb_path
  step17_structure_check:
    label: structure_check
    doc: This class is a wrapper of the Structure Checking tool to generate summary checking results on a json file.
    run: biobb_adapters/structure_check.cwl
    in:
      input_structure_path: step16_fix_pdb/output_pdb_path
      output_summary_path: step17_structure_check_output_summary_path
    out:
    - output_summary_path
