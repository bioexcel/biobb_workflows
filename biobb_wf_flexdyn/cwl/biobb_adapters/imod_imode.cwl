#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the imode tool

doc: |-
  Compute the normal modes of a macromolecule using the imode tool from the iMODS package.

baseCommand: imod_imode

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_flexdyn:4.1.0--pyhdfd78af_0

inputs:
  input_pdb_path:
    label: Input PDB file
    doc: |-
      Input PDB file
      Type: string
      File type: input
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_flexdyn/raw/master/biobb_flexdyn/test/data/flexdyn/structure.pdb
    type: File
    format:
    - edam:format_1476
    inputBinding:
      position: 1
      prefix: --input_pdb_path

  output_dat_path:
    label: Output dat with normal modes
    doc: |-
      Output dat with normal modes
      Type: string
      File type: output
      Accepted formats: dat, txt
      Example file: https://github.com/bioexcel/biobb_flexdyn/raw/master/biobb_flexdyn/test/reference/flexdyn/imod_imode_evecs.dat
    type: string
    format:
    - edam:format_1637
    - edam:format_2330
    inputBinding:
      position: 2
      prefix: --output_dat_path
    default: system.dat

  config:
    label: Advanced configuration options for biobb_flexdyn imod_imode
    doc: |-
      Advanced configuration options for biobb_flexdyn imod_imode. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_flexdyn imod_imode documentation: https://biobb-flexdyn.readthedocs.io/en/latest/flexdyn.html#module-flexdyn.imod_imode
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_dat_path:
    label: Output dat with normal modes
    doc: |-
      Output dat with normal modes
    type: File
    outputBinding:
      glob: $(inputs.output_dat_path)
    format: edam:format_1637

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
