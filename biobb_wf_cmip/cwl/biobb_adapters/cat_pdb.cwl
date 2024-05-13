#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Class to concat two PDB structures in a single PDB file.

doc: |-
  None

baseCommand: cat_pdb

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_structure_utils:4.1.0--pyhdfd78af_0

inputs:
  input_structure1:
    label: Input structure 1 file path
    doc: |-
      Input structure 1 file path
      Type: string
      File type: input
      Accepted formats: pdb, pdbqt
      Example file: https://github.com/bioexcel/biobb_structure_utils/raw/master/biobb_structure_utils/test/data/utils/cat_protein.pdb
    type: File
    format:
    - edam:format_1476
    - edam:format_1476
    inputBinding:
      position: 1
      prefix: --input_structure1

  input_structure2:
    label: Input structure 2 file path
    doc: |-
      Input structure 2 file path
      Type: string
      File type: input
      Accepted formats: pdb, pdbqt
      Example file: https://github.com/bioexcel/biobb_structure_utils/raw/master/biobb_structure_utils/test/data/utils/cat_ligand.pdb
    type: File
    format:
    - edam:format_1476
    - edam:format_1476
    inputBinding:
      position: 2
      prefix: --input_structure2

  output_structure_path:
    label: Output protein file path
    doc: |-
      Output protein file path
      Type: string
      File type: output
      Accepted formats: pdb, pdbqt
      Example file: https://github.com/bioexcel/biobb_structure_utils/raw/master/biobb_structure_utils/test/reference/utils/ref_cat_pdb.pdb
    type: string
    format:
    - edam:format_1476
    - edam:format_1476
    inputBinding:
      position: 3
      prefix: --output_structure_path
    default: system.pdb

  config:
    label: Advanced configuration options for biobb_structure_utils CatPDB
    doc: |-
      Advanced configuration options for biobb_structure_utils CatPDB. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_structure_utils CatPDB documentation: https://biobb-structure-utils.readthedocs.io/en/latest/utils.html#module-utils.cat_pdb
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_structure_path:
    label: Output protein file path
    doc: |-
      Output protein file path
    type: File
    outputBinding:
      glob: $(inputs.output_structure_path)
    format: edam:format_1476

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
