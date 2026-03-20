#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Trains a PyTorch autoencoder using the given properties.

doc: |-
  Trains a PyTorch autoencoder using the given properties.

baseCommand: train_model

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_pytorch:5.2.3--pyha658751_0

inputs:
  input_model_pth_path:
    label: Path to the input model file
    doc: |-
      Path to the input model file
      Type: string
      File type: input
      Accepted formats: pth
      Example file: https://github.com/bioexcel/biobb_pytorch/raw/master/biobb_pytorch/test/reference/mdae/output_model.pth
    type: File
    format:
    - edam:format_2333
    inputBinding:
      position: 1
      prefix: --input_model_pth_path

  input_dataset_pt_path:
    label: Path to the input dataset file (.pt) produced by the MD feature pipeline
    doc: |-
      Path to the input dataset file (.pt) produced by the MD feature pipeline
      Type: string
      File type: input
      Accepted formats: pt
      Example file: https://github.com/bioexcel/biobb_pytorch/raw/master/biobb_pytorch/test/reference/mdae/output_model.pt
    type: File
    format:
    - edam:format_2333
    inputBinding:
      position: 2
      prefix: --input_dataset_pt_path

  output_model_pth_path:
    label: Path to save the trained model (.pth). If omitted, the trained model is
      only available in memory
    doc: |-
      Path to save the trained model (.pth). If omitted, the trained model is only available in memory
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

  output_metrics_npz_path:
    label: Path save training metrics in compressed NumPy format (.npz)
    doc: |-
      Path save training metrics in compressed NumPy format (.npz)
      Type: string
      File type: output
      Accepted formats: npz
      Example file: https://github.com/bioexcel/biobb_pytorch/raw/master/biobb_pytorch/test/reference/mdae/output_model.npz
    type: string
    format:
    - edam:format_2333
    inputBinding:
      prefix: --output_metrics_npz_path
    default: system.npz

  config:
    label: Advanced configuration options for biobb_pytorch TrainModel
    doc: |-
      Advanced configuration options for biobb_pytorch TrainModel. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_pytorch TrainModel documentation: https://biobb-pytorch.readthedocs.io/en/latest/mdae.html#module-biobb_pytorch.mdae.train_model
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_model_pth_path:
    label: Path to save the trained model (.pth). If omitted, the trained model is
      only available in memory
    doc: |-
      Path to save the trained model (.pth). If omitted, the trained model is only available in memory
    type: File?
    outputBinding:
      glob: $(inputs.output_model_pth_path)
    format: edam:format_2333

  output_metrics_npz_path:
    label: Path save training metrics in compressed NumPy format (.npz)
    doc: |-
      Path save training metrics in compressed NumPy format (.npz)
    type: File?
    outputBinding:
      glob: $(inputs.output_metrics_npz_path)
    format: edam:format_2333

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
