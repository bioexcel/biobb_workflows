#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Build a Molecular Dynamics AutoEncoder (MDAE) PyTorch model.

doc: |-
  Builds a PyTorch autoencoder from the given properties.

baseCommand: build_model

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_pytorch:5.2.3--pyha658751_0

inputs:
  input_stats_pt_path:
    label: Path to the input model statistics file
    doc: |-
      Path to the input model statistics file
      Type: string
      File type: input
      Accepted formats: pt
      Example file: https://github.com/bioexcel/biobb_pytorch/raw/master/biobb_pytorch/test/reference/mdae/ref_input_model.pt
    type: File
    format:
    - edam:format_2333
    inputBinding:
      position: 1
      prefix: --input_stats_pt_path

  output_model_pth_path:
    label: Path to save the model in .pth format
    doc: |-
      Path to save the model in .pth format
      Type: string
      File type: output
      Accepted formats: pth
      Example file: https://github.com/bioexcel/biobb_pytorch/raw/master/biobb_pytorch/test/reference/mdae/output_model.pth
    type: string
    format:
    - edam:format_2333
    inputBinding:
      prefix: --output_model_pth_path
    default: system.pth

  config:
    label: Advanced configuration options for biobb_pytorch BuildModel
    doc: |-
      Advanced configuration options for biobb_pytorch BuildModel. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_pytorch BuildModel documentation: https://biobb-pytorch.readthedocs.io/en/latest/mdae.html#module-biobb_pytorch.mdae.build_model
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_model_pth_path:
    label: Path to save the model in .pth format
    doc: |-
      Path to save the model in .pth format
    type: File?
    outputBinding:
      glob: $(inputs.output_model_pth_path)
    format: edam:format_2333

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
