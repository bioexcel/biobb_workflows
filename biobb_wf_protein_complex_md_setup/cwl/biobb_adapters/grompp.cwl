#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the GROMACS grompp module.

doc: |-
  The GROMACS preprocessor module needs to be fed with the input system and the dynamics parameters to create a portable binary run input file TPR. The simulation parameters can be specified by two methods:  1.The predefined mdp settings defined at simulation_type property or  2.A custom mdp file defined at the input_mdp_path argument.  These two methods are mutually exclusive. In both cases can be further modified by adding parameters to the mdp section in the yaml configuration file. The simulation parameter names and default values can be consulted in the official MDP specification.

baseCommand: grompp

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_gromacs:4.1.1--pyhdfd78af_0

inputs:
  input_gro_path:
    label: Path to the input GROMACS structure GRO file
    doc: |-
      Path to the input GROMACS structure GRO file
      Type: string
      File type: input
      Accepted formats: gro
      Example file: https://github.com/bioexcel/biobb_gromacs/raw/master/biobb_gromacs/test/data/gromacs/grompp.gro
    type: File
    format:
    - edam:format_2033
    inputBinding:
      position: 1
      prefix: --input_gro_path

  input_top_zip_path:
    label: Path to the input GROMACS topology TOP and ITP files in zip format
    doc: |-
      Path to the input GROMACS topology TOP and ITP files in zip format
      Type: string
      File type: input
      Accepted formats: zip
      Example file: https://github.com/bioexcel/biobb_gromacs/raw/master/biobb_gromacs/test/data/gromacs/grompp.zip
    type: File
    format:
    - edam:format_3987
    inputBinding:
      position: 2
      prefix: --input_top_zip_path

  output_tpr_path:
    label: Path to the output portable binary run file TPR
    doc: |-
      Path to the output portable binary run file TPR
      Type: string
      File type: output
      Accepted formats: tpr
      Example file: https://github.com/bioexcel/biobb_gromacs/raw/master/biobb_gromacs/test/reference/gromacs/ref_grompp.tpr
    type: string
    format:
    - edam:format_2333
    inputBinding:
      position: 3
      prefix: --output_tpr_path
    default: system.tpr

  input_cpt_path:
    label: Path to the input GROMACS checkpoint file CPT
    doc: |-
      Path to the input GROMACS checkpoint file CPT
      Type: string
      File type: input
      Accepted formats: cpt
      Example file: null
    type: File?
    format:
    - edam:format_2333
    inputBinding:
      prefix: --input_cpt_path

  input_ndx_path:
    label: Path to the input GROMACS index files NDX
    doc: |-
      Path to the input GROMACS index files NDX
      Type: string
      File type: input
      Accepted formats: ndx
      Example file: null
    type: File?
    format:
    - edam:format_2033
    inputBinding:
      prefix: --input_ndx_path

  input_mdp_path:
    label: Path to the input GROMACS MDP file
    doc: |-
      Path to the input GROMACS MDP file
      Type: string
      File type: input
      Accepted formats: mdp
      Example file: null
    type: File?
    format:
    - edam:format_2330
    inputBinding:
      prefix: --input_mdp_path

  config:
    label: Advanced configuration options for biobb_gromacs Grompp
    doc: |-
      Advanced configuration options for biobb_gromacs Grompp. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_gromacs Grompp documentation: https://biobb-gromacs.readthedocs.io/en/latest/gromacs.html#module-gromacs.grompp
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_tpr_path:
    label: Path to the output portable binary run file TPR
    doc: |-
      Path to the output portable binary run file TPR
    type: File
    outputBinding:
      glob: $(inputs.output_tpr_path)
    format: edam:format_2333

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
