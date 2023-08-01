#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Class to remove molecules from a 3D structure using Biopython.

doc: |-
  None

baseCommand: remove_molecules

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_structure_utils:4.0.0--pyhdfd78af_0

inputs:
  input_structure_path:
    label: Input structure file path
    doc: |-
      Input structure file path
      Type: string
      File type: input
      Accepted formats: pdb, pdbqt
      Example file: https://github.com/bioexcel/biobb_structure_utils/raw/master/biobb_structure_utils/test/data/utils/2vgb.pdb
    type: File
    format:
    - edam:format_1476
    - edam:format_1476
    inputBinding:
      position: 1
      prefix: --input_structure_path

  output_molecules_path:
    label: Output molcules file path
    doc: |-
      Output molcules file path
      Type: string
      File type: output
      Accepted formats: pdb, pdbqt
      Example file: https://github.com/bioexcel/biobb_structure_utils/raw/master/biobb_structure_utils/test/reference/utils/ref_remove_molecules.pdb
    type: string
    format:
    - edam:format_1476
    - edam:format_1476
    inputBinding:
      position: 2
      prefix: --output_molecules_path
    default: system.pdb

  config:
    label: Advanced configuration options for biobb_structure_utils RemoveMolecules
    doc: |-
      Advanced configuration options for biobb_structure_utils RemoveMolecules. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_structure_utils RemoveMolecules documentation: https://biobb-structure-utils.readthedocs.io/en/latest/utils.html#module-utils.remove_molecules
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_molecules_path:
    label: Output molcules file path
    doc: |-
      Output molcules file path
    type: File
    outputBinding:
      glob: $(inputs.output_molecules_path)
    format: edam:format_1476

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
