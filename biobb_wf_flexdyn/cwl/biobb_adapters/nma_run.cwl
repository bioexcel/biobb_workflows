#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the Normal Mode Analysis tool from the FlexServ module.

doc: |-
  Generates protein conformational structures using the Normal Mode Analysis (NMA) method.

baseCommand: nma_run

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_flexserv:4.0.0--pypl5321hdfd78af_1

inputs:
  input_pdb_path:
    label: Input PDB file
    doc: |-
      Input PDB file
      Type: string
      File type: input
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_flexserv/raw/master/biobb_flexserv/test/data/flexserv/structure.ca.pdb
    type: File
    format:
    - edam:format_1476
    inputBinding:
      position: 1
      prefix: --input_pdb_path

  output_log_path:
    label: Output log file
    doc: |-
      Output log file
      Type: string
      File type: output
      Accepted formats: log, out, txt, o
      Example file: https://github.com/bioexcel/biobb_flexserv/raw/master/biobb_flexserv/test/reference/flexserv/nma_run_out.log
    type: string
    format:
    - edam:format_2330
    - edam:format_2330
    - edam:format_2330
    - edam:format_2330
    inputBinding:
      position: 2
      prefix: --output_log_path
    default: system.log

  output_crd_path:
    label: Output ensemble
    doc: |-
      Output ensemble
      Type: string
      File type: output
      Accepted formats: crd, mdcrd, inpcrd
      Example file: https://github.com/bioexcel/biobb_flexserv/raw/master/biobb_flexserv/test/reference/flexserv/nma_run_out.crd
    type: string
    format:
    - edam:format_3878
    - edam:format_3878
    - edam:format_3878
    inputBinding:
      position: 3
      prefix: --output_crd_path
    default: system.crd

  config:
    label: Advanced configuration options for biobb_flexserv NMARun
    doc: |-
      Advanced configuration options for biobb_flexserv NMARun. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_flexserv NMARun documentation: https://biobb-flexserv.readthedocs.io/en/latest/flexserv.html#module-flexserv.nma_run
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_log_path:
    label: Output log file
    doc: |-
      Output log file
    type: File
    outputBinding:
      glob: $(inputs.output_log_path)
    format: edam:format_2330

  output_crd_path:
    label: Output ensemble
    doc: |-
      Output ensemble
    type: File
    outputBinding:
      glob: $(inputs.output_crd_path)
    format: edam:format_3878

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
