#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: This class is a wrapper of the Structure Checking tool to remove water molecules
  from PDB 3D structures.

doc: |-
  Wrapper for the Structure Checking tool to remove water molecules from PDB 3D structures.

baseCommand: remove_pdb_water

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_structure_utils:4.1.0--pyhdfd78af_0

inputs:
  input_pdb_path:
    label: Input PDB file path
    doc: |-
      Input PDB file path
      Type: string
      File type: input
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_structure_utils/raw/master/biobb_structure_utils/test/data/utils/WT_aq4_md_WAT.pdb
    type: File
    format:
    - edam:format_1476
    inputBinding:
      position: 1
      prefix: --input_pdb_path

  output_pdb_path:
    label: Output PDB file path
    doc: |-
      Output PDB file path
      Type: string
      File type: output
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_structure_utils/raw/master/biobb_structure_utils/test/reference/utils/WT_apo_no_wat.pdb
    type: string
    format:
    - edam:format_1476
    inputBinding:
      position: 2
      prefix: --output_pdb_path
    default: system.pdb

  config:
    label: Advanced configuration options for biobb_structure_utils RemovePdbWater
    doc: |-
      Advanced configuration options for biobb_structure_utils RemovePdbWater. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_structure_utils RemovePdbWater documentation: https://biobb-structure-utils.readthedocs.io/en/latest/utils.html#module-utils.remove_pdb_water
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_pdb_path:
    label: Output PDB file path
    doc: |-
      Output PDB file path
    type: File
    outputBinding:
      glob: $(inputs.output_pdb_path)
    format: edam:format_1476

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
