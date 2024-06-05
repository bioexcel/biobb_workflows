#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper class for the GROMACS editconf module.

doc: |-
  The GROMACS solvate module generates a box around the selected structure.

baseCommand: editconf

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_gromacs:4.1.1--pyhdfd78af_0

inputs:
  input_gro_path:
    label: Path to the input GRO file
    doc: |-
      Path to the input GRO file
      Type: string
      File type: input
      Accepted formats: gro, pdb
      Example file: https://github.com/bioexcel/biobb_gromacs/raw/master/biobb_gromacs/test/data/gromacs/editconf.gro
    type: File
    format:
    - edam:format_2033
    - edam:format_1476
    inputBinding:
      position: 1
      prefix: --input_gro_path

  output_gro_path:
    label: Path to the output GRO file
    doc: |-
      Path to the output GRO file
      Type: string
      File type: output
      Accepted formats: pdb, gro
      Example file: https://github.com/bioexcel/biobb_gromacs/raw/master/biobb_gromacs/test/reference/gromacs/ref_editconf.gro
    type: string
    format:
    - edam:format_1476
    - edam:format_2033
    inputBinding:
      position: 2
      prefix: --output_gro_path
    default: system.pdb

  config:
    label: Advanced configuration options for biobb_gromacs Editconf
    doc: |-
      Advanced configuration options for biobb_gromacs Editconf. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_gromacs Editconf documentation: https://biobb-gromacs.readthedocs.io/en/latest/gromacs.html#module-gromacs.editconf
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_gro_path:
    label: Path to the output GRO file
    doc: |-
      Path to the output GRO file
    type: File
    outputBinding:
      glob: $(inputs.output_gro_path)
    format: edam:format_1476

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
