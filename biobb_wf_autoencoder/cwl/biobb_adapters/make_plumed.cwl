#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Generate PLUMED input for biased dynamics using an MDAE model.

doc: |-
  Generates a PLUMED input file, features.dat, and converts the model to .ptc format.

baseCommand: make_plumed

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_pytorch:5.2.2--pyhad2cae4_0

inputs:
  input_model_pth_path:
    label: Path to the trained PyTorch model (.pth) to be converted to TorchScript
      and used in PLUMED
    doc: |-
      Path to the trained PyTorch model (.pth) to be converted to TorchScript and used in PLUMED
      Type: string
      File type: input
      Accepted formats: pth
      Example file: null
    type: File
    format:
    - edam:format_2333
    inputBinding:
      position: 1
      prefix: --input_model_pth_path

  output_plumed_dat_path:
    label: Path to the output PLUMED input file
    doc: |-
      Path to the output PLUMED input file
      Type: string
      File type: output
      Accepted formats: dat
      Example file: null
    type: string
    format:
    - edam:format_2330
    inputBinding:
      position: 2
      prefix: --output_plumed_dat_path
    default: system.dat

  output_features_dat_path:
    label: Path to the output features.dat file describing the CVs to PLUMED
    doc: |-
      Path to the output features.dat file describing the CVs to PLUMED
      Type: string
      File type: output
      Accepted formats: dat
      Example file: null
    type: string
    format:
    - edam:format_2330
    inputBinding:
      position: 3
      prefix: --output_features_dat_path
    default: system.dat

  output_model_ptc_path:
    label: Path to the output TorchScript model file (.ptc) for PLUMED's PYTORCH_MODEL
      action
    doc: |-
      Path to the output TorchScript model file (.ptc) for PLUMED's PYTORCH_MODEL action
      Type: string
      File type: output
      Accepted formats: ptc
      Example file: null
    type: string
    format:
    - edam:format_2333
    inputBinding:
      position: 4
      prefix: --output_model_ptc_path
    default: system.ptc

  input_stats_pt_path:
    label: Path to statistics file (.pt) produced during featurization, used to derive
      the PLUMED features.dat content
    doc: |-
      Path to statistics file (.pt) produced during featurization, used to derive the PLUMED features.dat content
      Type: string
      File type: input
      Accepted formats: pt
      Example file: null
    type: File?
    format:
    - edam:format_2333
    inputBinding:
      prefix: --input_stats_pt_path

  input_reference_pdb_path:
    label: Path to reference PDB used for FIT_TO_TEMPLATE actions when Cartesian features
      are present
    doc: |-
      Path to reference PDB used for FIT_TO_TEMPLATE actions when Cartesian features are present
      Type: string
      File type: input
      Accepted formats: pdb
      Example file: null
    type: File?
    format:
    - edam:format_1476
    inputBinding:
      prefix: --input_reference_pdb_path

  input_ndx_path:
    label: Path to GROMACS index (NDX) file used to define groups when required by
      PLUMED
    doc: |-
      Path to GROMACS index (NDX) file used to define groups when required by PLUMED
      Type: string
      File type: input
      Accepted formats: ndx
      Example file: null
    type: File?
    format:
    - edam:format_2033
    inputBinding:
      prefix: --input_ndx_path

  config:
    label: Advanced configuration options for biobb_plumed GeneratePlumed
    doc: |-
      Advanced configuration options for biobb_plumed GeneratePlumed. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_plumed GeneratePlumed documentation: https://biobb-pytorch.readthedocs.io/en/latest/mdae.html#module-biobb_pytorch.mdae.make_plumed
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_plumed_dat_path:
    label: Path to the output PLUMED input file
    doc: |-
      Path to the output PLUMED input file
    type: File
    outputBinding:
      glob: $(inputs.output_plumed_dat_path)
    format: edam:format_2330

  output_features_dat_path:
    label: Path to the output features.dat file describing the CVs to PLUMED
    doc: |-
      Path to the output features.dat file describing the CVs to PLUMED
    type: File
    outputBinding:
      glob: $(inputs.output_features_dat_path)
    format: edam:format_2330

  output_model_ptc_path:
    label: Path to the output TorchScript model file (.ptc) for PLUMED's PYTORCH_MODEL
      action
    doc: |-
      Path to the output TorchScript model file (.ptc) for PLUMED's PYTORCH_MODEL action
    type: File
    outputBinding:
      glob: $(inputs.output_model_ptc_path)
    format: edam:format_2333

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
