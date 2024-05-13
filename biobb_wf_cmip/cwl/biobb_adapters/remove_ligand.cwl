#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Class to remove the selected ligand atoms from a 3D structure.

doc: |-
  None

baseCommand: remove_ligand

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_structure_utils:4.1.0--pyhdfd78af_0

inputs:
  input_structure_path:
    label: Input structure file path
    doc: |-
      Input structure file path
      Type: string
      File type: input
      Accepted formats: pdb, gro
      Example file: https://github.com/bioexcel/biobb_structure_utils/raw/master/biobb_structure_utils/test/data/utils/WT_aq4_md_1.pdb
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
      Example file: https://github.com/bioexcel/biobb_structure_utils/raw/master/biobb_structure_utils/test/reference/utils/WT_apo_md_1.pdb
    type: string
    format:
    - edam:format_1476
    - edam:format_2033
    inputBinding:
      position: 2
      prefix: --output_structure_path
    default: system.pdb

  config:
    label: Advanced configuration options for biobb_structure_utils RemoveLigand
    doc: |-
      Advanced configuration options for biobb_structure_utils RemoveLigand. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_structure_utils RemoveLigand documentation: https://biobb-structure-utils.readthedocs.io/en/latest/utils.html#module-utils.remove_ligand
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
