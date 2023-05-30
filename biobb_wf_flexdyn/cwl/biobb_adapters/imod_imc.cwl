#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the imc tool

doc: |-
  Compute a Monte-Carlo IC-NMA based conformational ensemble using the imc tool from the iMODS package.

baseCommand: imod_imc

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_flexdyn:4.0.2--pyhdfd78af_0

inputs:
  input_pdb_path:
    label: Input PDB file
    doc: |-
      Input PDB file
      Type: string
      File type: input
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_flexdyn/raw/master/biobb_flexdyn/test/data/flexdyn/structure_cleaned.pdb
    type: File
    format:
    - edam:format_1476
    inputBinding:
      position: 1
      prefix: --input_pdb_path

  input_dat_path:
    label: Input dat with normal modes
    doc: |-
      Input dat with normal modes
      Type: string
      File type: input
      Accepted formats: dat, txt
      Example file: https://github.com/bioexcel/biobb_flexdyn/raw/master/biobb_flexdyn/test/data/flexdyn/imod_imode_evecs.dat
    type: File
    format:
    - edam:format_1637
    - edam:format_2330
    inputBinding:
      position: 2
      prefix: --input_dat_path

  output_traj_path:
    label: Output multi-model PDB file with the generated ensemble
    doc: |-
      Output multi-model PDB file with the generated ensemble
      Type: string
      File type: output
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_flexdyn/raw/master/biobb_flexdyn/test/reference/flexdyn/imod_imc_output.pdb
    type: string
    format:
    - edam:format_1476
    inputBinding:
      position: 3
      prefix: --output_traj_path
    default: system.pdb

  config:
    label: Advanced configuration options for biobb_flexdyn imod_imc
    doc: |-
      Advanced configuration options for biobb_flexdyn imod_imc. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_flexdyn imod_imc documentation: https://biobb-flexdyn.readthedocs.io/en/latest/flexdyn.html#module-flexdyn.imod_imc
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_traj_path:
    label: Output multi-model PDB file with the generated ensemble
    doc: |-
      Output multi-model PDB file with the generated ensemble
    type: File
    outputBinding:
      glob: $(inputs.output_traj_path)
    format: edam:format_1476

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
