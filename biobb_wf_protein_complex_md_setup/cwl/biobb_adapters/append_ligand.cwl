#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: This class takes a ligand ITP file and inserts it in a topology.

doc: |-
  This module automatizes the process of inserting a ligand ITP file in a GROMACS topology.

baseCommand: append_ligand

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_gromacs:4.0.0--pyhdfd78af_1

inputs:
  input_top_zip_path:
    label: Path the input topology TOP and ITP files zipball
    doc: |-
      Path the input topology TOP and ITP files zipball
      Type: string
      File type: input
      Accepted formats: zip
      Example file: https://github.com/bioexcel/biobb_gromacs/raw/master/biobb_gromacs/test/data/gromacs_extra/ndx2resttop.zip
    type: File
    format:
    - edam:format_3987
    inputBinding:
      position: 1
      prefix: --input_top_zip_path

  input_itp_path:
    label: Path to the ligand ITP file to be inserted in the topology
    doc: |-
      Path to the ligand ITP file to be inserted in the topology
      Type: string
      File type: input
      Accepted formats: itp
      Example file: https://github.com/bioexcel/biobb_gromacs/raw/master/biobb_gromacs/test/data/gromacs_extra/pep_ligand.itp
    type: File
    format:
    - edam:format_3883
    inputBinding:
      position: 2
      prefix: --input_itp_path

  output_top_zip_path:
    label: Path/Name the output topology TOP and ITP files zipball
    doc: |-
      Path/Name the output topology TOP and ITP files zipball
      Type: string
      File type: output
      Accepted formats: zip
      Example file: https://github.com/bioexcel/biobb_gromacs/raw/master/biobb_gromacs/test/reference/gromacs_extra/ref_appendligand.zip
    type: string
    format:
    - edam:format_3987
    inputBinding:
      position: 3
      prefix: --output_top_zip_path
    default: system.zip

  input_posres_itp_path:
    label: Path to the position restriction ITP file
    doc: |-
      Path to the position restriction ITP file
      Type: string
      File type: input
      Accepted formats: itp
      Example file: null
    type: File?
    format:
    - edam:format_3883
    inputBinding:
      prefix: --input_posres_itp_path

  config:
    label: Advanced configuration options for biobb_gromacs AppendLigand
    doc: |-
      Advanced configuration options for biobb_gromacs AppendLigand. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_gromacs AppendLigand documentation: https://biobb-gromacs.readthedocs.io/en/latest/gromacs_extra.html#gromacs-extra-append-ligand-module
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_top_zip_path:
    label: Path/Name the output topology TOP and ITP files zipball
    doc: |-
      Path/Name the output topology TOP and ITP files zipball
    type: File
    outputBinding:
      glob: $(inputs.output_top_zip_path)
    format: edam:format_3987

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
