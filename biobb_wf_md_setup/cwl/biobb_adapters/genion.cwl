#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper class for the GROMACS genion module.

doc: |-
  The GROMACS genion module randomly replaces solvent molecules with monoatomic ions. The group of solvent molecules should be continuous and all molecules should have the same number of atoms.

baseCommand: genion

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_gromacs:4.1.1--pyhdfd78af_0

inputs:
  input_tpr_path:
    label: Path to the input portable run input TPR file
    doc: |-
      Path to the input portable run input TPR file
      Type: string
      File type: input
      Accepted formats: tpr
      Example file: https://github.com/bioexcel/biobb_gromacs/raw/master/biobb_gromacs/test/data/gromacs/genion.tpr
    type: File
    format:
    - edam:format_2333
    inputBinding:
      position: 1
      prefix: --input_tpr_path

  output_gro_path:
    label: Path to the input structure GRO file
    doc: |-
      Path to the input structure GRO file
      Type: string
      File type: output
      Accepted formats: gro
      Example file: https://github.com/bioexcel/biobb_gromacs/raw/master/biobb_gromacs/test/reference/gromacs/ref_genion.gro
    type: string
    format:
    - edam:format_2033
    inputBinding:
      position: 2
      prefix: --output_gro_path
    default: system.gro

  input_top_zip_path:
    label: Path the input TOP topology in zip format
    doc: |-
      Path the input TOP topology in zip format
      Type: string
      File type: input
      Accepted formats: zip
      Example file: https://github.com/bioexcel/biobb_gromacs/raw/master/biobb_gromacs/test/data/gromacs/genion.zip
    type: File
    format:
    - edam:format_3987
    inputBinding:
      position: 3
      prefix: --input_top_zip_path

  output_top_zip_path:
    label: Path the output topology TOP and ITP files zipball
    doc: |-
      Path the output topology TOP and ITP files zipball
      Type: string
      File type: output
      Accepted formats: zip
      Example file: https://github.com/bioexcel/biobb_gromacs/raw/master/biobb_gromacs/test/reference/gromacs/ref_genion.zip
    type: string
    format:
    - edam:format_3987
    inputBinding:
      position: 4
      prefix: --output_top_zip_path
    default: system.zip

  input_ndx_path:
    label: Path to the input index NDX file
    doc: |-
      Path to the input index NDX file
      Type: string
      File type: input
      Accepted formats: ndx
      Example file: null
    type: File?
    format:
    - edam:format_2033
    inputBinding:
      prefix: --input_ndx_path

  config:
    label: Advanced configuration options for biobb_gromacs Genion
    doc: |-
      Advanced configuration options for biobb_gromacs Genion. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_gromacs Genion documentation: https://biobb-gromacs.readthedocs.io/en/latest/gromacs.html#module-gromacs.genion
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_gro_path:
    label: Path to the input structure GRO file
    doc: |-
      Path to the input structure GRO file
    type: File
    outputBinding:
      glob: $(inputs.output_gro_path)
    format: edam:format_2033

  output_top_zip_path:
    label: Path the output topology TOP and ITP files zipball
    doc: |-
      Path the output topology TOP and ITP files zipball
    type: File
    outputBinding:
      glob: $(inputs.output_top_zip_path)
    format: edam:format_3987

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
