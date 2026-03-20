#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the gorder atomistic module for computing lipid order parameters
  per atom for carbon tails.

doc: |-
  gorder uses GSL for all its selections.

baseCommand: gorder_aa

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_mem:5.2.2--pyhdfd78af_0

inputs:
  input_top_path:
    label: Path to the input structure or topology file
    doc: |-
      Path to the input structure or topology file
      Type: string
      File type: input
      Accepted formats: tpr
      Example file: https://github.com/bioexcel/biobb_mem/raw/main/biobb_mem/test/data/A01IP/A01IP.tpr
    type: File
    format:
    - edam:format_2333
    inputBinding:
      position: 1
      prefix: --input_top_path

  input_traj_path:
    label: Path to the input trajectory to be processed
    doc: |-
      Path to the input trajectory to be processed
      Type: string
      File type: input
      Accepted formats: xtc, trr, gro
      Example file: https://github.com/bioexcel/biobb_mem/raw/main/biobb_mem/test/data/A01IP/A01IP.xtc
    type: File
    format:
    - edam:format_3875
    - edam:format_3910
    - edam:format_2033
    inputBinding:
      position: 2
      prefix: --input_traj_path

  output_order_path:
    label: Path to results of the order analysis
    doc: |-
      Path to results of the order analysis
      Type: string
      File type: output
      Accepted formats: yaml, xvg, csv
      Example file: https://github.com/bioexcel/biobb_mem/raw/main/biobb_mem/test/reference/gorder/order_aa.yaml
    type: string
    format:
    - edam:format_3570
    - edam:format_2330
    - edam:format_3752
    inputBinding:
      position: 3
      prefix: --output_order_path
    default: system.yaml

  config:
    label: Advanced configuration options for biobb_mem GorderAA
    doc: |-
      Advanced configuration options for biobb_mem GorderAA. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_mem GorderAA documentation: https://biobb-mem.readthedocs.io/en/latest/gorder.html#module-gorder.gorder_aa
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_order_path:
    label: Path to results of the order analysis
    doc: |-
      Path to results of the order analysis
    type: File
    outputBinding:
      glob: $(inputs.output_order_path)
    format: edam:format_3570

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
