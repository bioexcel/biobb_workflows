#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Class to extract atoms from a 3D structure.

doc: |-
  None

baseCommand: extract_atoms

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_structure_utils:4.0.0--pyhdfd78af_1

inputs:
  input_structure_path:
    label: Input structure file path
    doc: |-
      Input structure file path
      Type: string
      File type: input
      Accepted formats: pdb, gro
      Example file: https://github.com/bioexcel/biobb_structure_utils/raw/master/biobb_structure_utils/test/data/utils/2vgb.pdb
    type: File
    format:
    - edam:format_1476
    - edam:format_2033
    inputBinding:
      position: 1
      prefix: --input_structure_path

  output_structure_path:
    label: Output structure file path
    doc: |-
      Output structure file path
      Type: string
      File type: output
      Accepted formats: pdb, gro
      Example file: https://github.com/bioexcel/biobb_structure_utils/raw/master/biobb_structure_utils/test/reference/utils/OE2_atoms.pdb
    type: string
    format:
    - edam:format_1476
    - edam:format_2033
    inputBinding:
      position: 2
      prefix: --output_structure_path
    default: system.pdb

  config:
    label: Advanced configuration options for biobb_structure_utils ExtractAtoms
    doc: |-
      Advanced configuration options for biobb_structure_utils ExtractAtoms. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_structure_utils ExtractAtoms documentation: https://biobb-structure-utils.readthedocs.io/en/latest/utils.html#module-utils.extract_atoms
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_structure_path:
    label: Output structure file path
    doc: |-
      Output structure file path
    type: File
    outputBinding:
      glob: $(inputs.output_structure_path)
    format: edam:format_1476

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
