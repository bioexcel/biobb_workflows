#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the Dist tool from the Concoord package.

doc: |-
  Structure interpretation and bond definitions from a PDB/GRO file.

baseCommand: concoord_dist

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_flexdyn:4.0.3--pyhdfd78af_0

inputs:
  input_structure_path:
    label: Input structure file
    doc: |-
      Input structure file
      Type: string
      File type: input
      Accepted formats: pdb, gro
      Example file: https://github.com/bioexcel/biobb_flexdyn/raw/master/biobb_flexdyn/test/data/flexdyn/structure.pdb
    type: File
    format:
    - edam:format_1476
    - edam:format_2033
    inputBinding:
      position: 1
      prefix: --input_structure_path

  output_pdb_path:
    label: Output pdb file
    doc: |-
      Output pdb file
      Type: string
      File type: output
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_flexdyn/raw/master/biobb_flexdyn/test/reference/flexdyn/dist.pdb
    type: string
    format:
    - edam:format_1476
    inputBinding:
      position: 2
      prefix: --output_pdb_path
    default: system.pdb

  output_gro_path:
    label: Output gro file
    doc: |-
      Output gro file
      Type: string
      File type: output
      Accepted formats: gro
      Example file: https://github.com/bioexcel/biobb_flexdyn/raw/master/biobb_flexdyn/test/reference/flexdyn/dist.gro
    type: string
    format:
    - edam:format_2033
    inputBinding:
      position: 3
      prefix: --output_gro_path
    default: system.gro

  output_dat_path:
    label: Output dat with structure interpretation and bond definitions
    doc: |-
      Output dat with structure interpretation and bond definitions
      Type: string
      File type: output
      Accepted formats: dat, txt
      Example file: https://github.com/bioexcel/biobb_flexdyn/raw/master/biobb_flexdyn/test/reference/flexdyn/dist.dat
    type: string
    format:
    - edam:format_1637
    - edam:format_2330
    inputBinding:
      position: 4
      prefix: --output_dat_path
    default: system.dat

  config:
    label: Advanced configuration options for biobb_flexdyn ConcoordDist
    doc: |-
      Advanced configuration options for biobb_flexdyn ConcoordDist. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_flexdyn ConcoordDist documentation: https://biobb-flexdyn.readthedocs.io/en/latest/flexdyn.html#module-flexdyn.concoord_dist
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_pdb_path:
    label: Output pdb file
    doc: |-
      Output pdb file
    type: File
    outputBinding:
      glob: $(inputs.output_pdb_path)
    format: edam:format_1476

  output_gro_path:
    label: Output gro file
    doc: |-
      Output gro file
    type: File
    outputBinding:
      glob: $(inputs.output_gro_path)
    format: edam:format_2033

  output_dat_path:
    label: Output dat with structure interpretation and bond definitions
    doc: |-
      Output dat with structure interpretation and bond definitions
    type: File
    outputBinding:
      glob: $(inputs.output_dat_path)
    format: edam:format_1637

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
