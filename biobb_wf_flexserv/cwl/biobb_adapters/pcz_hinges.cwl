#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Compute possible hinge regions (residues around which large protein movements
  are organized) of a molecule from a compressed PCZ file.

doc: |-
  Wrapper of the pczdump tool from the PCAsuite FlexServ module.

baseCommand: pcz_hinges

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_flexserv:4.0.3--pypl5321hdfd78af_0

inputs:
  input_pcz_path:
    label: Input compressed trajectory file
    doc: |-
      Input compressed trajectory file
      Type: string
      File type: input
      Accepted formats: pcz
      Example file: https://github.com/bioexcel/biobb_flexserv/raw/master/biobb_flexserv/test/data/pcasuite/pcazip.pcz
    type: File
    format:
    - edam:format_3874
    inputBinding:
      position: 1
      prefix: --input_pcz_path

  output_json_path:
    label: Output hinge regions x PCA mode file
    doc: |-
      Output hinge regions x PCA mode file
      Type: string
      File type: output
      Accepted formats: json
      Example file: https://github.com/bioexcel/biobb_flexserv/raw/master/biobb_flexserv/test/reference/pcasuite/hinges.json
    type: string
    format:
    - edam:format_3464
    inputBinding:
      position: 2
      prefix: --output_json_path
    default: system.json

  config:
    label: Advanced configuration options for biobb_flexserv PCZhinges
    doc: |-
      Advanced configuration options for biobb_flexserv PCZhinges. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_flexserv PCZhinges documentation: https://biobb-flexserv.readthedocs.io/en/latest/pcasuite.html#module-pcasuite.pcz_hinges
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_json_path:
    label: Output hinge regions x PCA mode file
    doc: |-
      Output hinge regions x PCA mode file
    type: File
    outputBinding:
      glob: $(inputs.output_json_path)
    format: edam:format_3464

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
