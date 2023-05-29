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
  step4_concoord_dist_output_pdb_path: string
  step4_concoord_dist_output_gro_path: string
  step4_concoord_dist_output_dat_path: string
  step4_concoord_dist_config: string
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
  step4_concoord_dist_out1:
    label: output_pdb_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step4_concoord_dist/output_pdb_path
  step4_concoord_dist_out2:
    label: output_gro_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step4_concoord_dist/output_gro_path
  step4_concoord_dist_out3:
    label: output_dat_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step4_concoord_dist/output_dat_path
steps:
  step0_extract_model:
    label: ExtractModel
    doc: |-
      Extracts a model from a 3D structure.
    #run: /path/to/biobb_adapters/biobb_adapters/cwl/biobb_structure_utils/extract_model.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_adapters/biobb_adapters/cwl/biobb_structure_utils/extract_model.cwl
    in:
      config: step0_extract_model_config
      input_structure_path: step0_extract_model_input_structure_path
      output_structure_path: step0_extract_model_output_structure_path
    out:
    - output_structure_path
  step1_extract_chain:
    label: ExtractChain
    doc: |-
      Extracts a chain from a 3D structure.
    #run: /path/to/biobb_adapters/biobb_adapters/cwl/biobb_structure_utils/extract_chain.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_adapters/biobb_adapters/cwl/biobb_structure_utils/extract_chain.cwl
    in:
      config: step1_extract_chain_config
      input_structure_path: step0_extract_model/output_structure_path
      output_structure_path: step1_extract_chain_output_structure_path
    out:
    - output_structure_path
  step2_cpptraj_mask:
    label: CpptrajMask
    doc: |-
      Extracts a selection of atoms from a given cpptraj compatible trajectory.
    #run: /path/to/biobb_adapters/biobb_adapters/cwl/biobb_analysis/cpptraj_mask.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_adapters/biobb_adapters/cwl/biobb_analysis/cpptraj_mask.cwl
    in:
      config: step2_cpptraj_mask_config
      input_top_path: step1_extract_chain/output_structure_path
      input_traj_path: step1_extract_chain/output_structure_path
      output_cpptraj_path: step2_cpptraj_mask_output_cpptraj_path
    out:
    - output_cpptraj_path
  step3_cpptraj_mask:
    label: CpptrajMask
    doc: |-
      Extracts a selection of atoms from a given cpptraj compatible trajectory.
    #run: /path/to/biobb_adapters/biobb_adapters/cwl/biobb_analysis/cpptraj_mask.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_adapters/biobb_adapters/cwl/biobb_analysis/cpptraj_mask.cwl
    in:
      config: step3_cpptraj_mask_config
      input_top_path: step1_extract_chain/output_structure_path
      input_traj_path: step1_extract_chain/output_structure_path
      output_cpptraj_path: step3_cpptraj_mask_output_cpptraj_path
    out:
    - output_cpptraj_path
  step4_concoord_dist:
    label: ConcoordDist
    doc: |-
      Wrapper of the Concoord_dist software.
    #run: /path/to/biobb_adapters/biobb_adapters/cwl/biobb_flexdyn/concoord_dist.cwl
    run: /Users/gbayarri/projects/BioBB/biobb_adapters/biobb_adapters/cwl/biobb_flexdyn/concoord_dist.cwl
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
