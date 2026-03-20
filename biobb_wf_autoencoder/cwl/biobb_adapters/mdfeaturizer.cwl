#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Obtain the Molecular Dynamics Features for PyTorch model training.

doc: |-
  Obtain the Molecular Dynamics Features for PyTorch model training.

baseCommand: mdfeaturizer

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_pytorch:5.2.3--pyha658751_0

inputs:
  input_topology_path:
    label: Path to the input topology file
    doc: |-
      Path to the input topology file
      Type: string
      File type: input
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_pytorch/raw/master/biobb_pytorch/test/data/mdae/MCV1900209.pdb
    type: File
    format:
    - edam:format_2333
    inputBinding:
      position: 1
      prefix: --input_topology_path

  output_dataset_pt_path:
    label: Path to the output dataset model file
    doc: |-
      Path to the output dataset model file
      Type: string
      File type: output
      Accepted formats: pt
      Example file: https://github.com/bioexcel/biobb_pytorch/raw/master/biobb_pytorch/test/reference/mdae/ref_output_dataset.pt
    type: string
    format:
    - edam:format_2333
    inputBinding:
      position: 2
      prefix: --output_dataset_pt_path
    default: system.pt

  output_stats_pt_path:
    label: Path to the output model statistics file
    doc: |-
      Path to the output model statistics file
      Type: string
      File type: output
      Accepted formats: pt
      Example file: https://github.com/bioexcel/biobb_pytorch/raw/master/biobb_pytorch/test/reference/mdae/ref_output_stats.pt
    type: string
    format:
    - edam:format_2333
    inputBinding:
      position: 3
      prefix: --output_stats_pt_path
    default: system.pt

  input_trajectory_path:
    label: Path to the input trajectory file (if omitted topology file is used as
      trajectory)
    doc: |-
      Path to the input trajectory file (if omitted topology file is used as trajectory)
      Type: string
      File type: input
      Accepted formats: xtc, dcd
      Example file: https://github.com/bioexcel/biobb_pytorch/raw/master/biobb_pytorch/test/data/mdae/train_mdae_traj.xtc
    type: File?
    format:
    - edam:format_3875
    - edam:format_3878
    inputBinding:
      prefix: --input_trajectory_path

  config:
    label: Advanced configuration options for biobb_pytorch MDFeaturePipeline
    doc: |-
      Advanced configuration options for biobb_pytorch MDFeaturePipeline. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_pytorch MDFeaturePipeline documentation: https://biobb-pytorch.readthedocs.io/en/latest/mdae.html#module-biobb_pytorch.mdae.mdfeaturizer
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_dataset_pt_path:
    label: Path to the output dataset model file
    doc: |-
      Path to the output dataset model file
    type: File
    outputBinding:
      glob: $(inputs.output_dataset_pt_path)
    format: edam:format_2333

  output_stats_pt_path:
    label: Path to the output model statistics file
    doc: |-
      Path to the output model statistics file
    type: File
    outputBinding:
      glob: $(inputs.output_stats_pt_path)
    format: edam:format_2333

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
