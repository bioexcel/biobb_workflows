#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Extract residue bfactors x PCA mode from a compressed PCZ file.

doc: |-
  Wrapper of the pczdump tool from the PCAsuite FlexServ module.

baseCommand: pcz_bfactor

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_flexserv:4.0.2--pypl5321hdfd78af_0

inputs:
  input_pcz_path:
    label: Input compressed trajectory file
    doc: |-
      Input compressed trajectory file
      Type: string
      File type: input
      Accepted formats: pcz
      Example file: https://github.com/bioexcel/biobb_flexserv/raw/master/biobb_flexserv/test/data/pcasuite/pcazip.pcz
    type: File
    format:
    - edam:format_3874
    inputBinding:
      position: 1
      prefix: --input_pcz_path

  output_dat_path:
    label: Output Bfactor x residue x PCA mode file
    doc: |-
      Output Bfactor x residue x PCA mode file
      Type: string
      File type: output
      Accepted formats: dat, txt, csv
      Example file: https://github.com/bioexcel/biobb_flexserv/raw/master/biobb_flexserv/test/reference/pcasuite/bfactors.dat
    type: string
    format:
    - edam:format_1637
    - edam:format_2330
    - edam:format_3752
    inputBinding:
      position: 2
      prefix: --output_dat_path
    default: system.dat

  output_pdb_path:
    label: Output PDB with Bfactor x residue x PCA mode file
    doc: |-
      Output PDB with Bfactor x residue x PCA mode file
      Type: string
      File type: output
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_flexserv/raw/master/biobb_flexserv/test/reference/pcasuite/bfactors.pdb
    type: string
    format:
    - edam:format_1476
    inputBinding:
      prefix: --output_pdb_path
    default: system.pdb

  config:
    label: Advanced configuration options for biobb_flexserv PCZbfactor
    doc: |-
      Advanced configuration options for biobb_flexserv PCZbfactor. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_flexserv PCZbfactor documentation: https://biobb-flexserv.readthedocs.io/en/latest/pcasuite.html#module-pcasuite.pcz_bfactor
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_dat_path:
    label: Output Bfactor x residue x PCA mode file
    doc: |-
      Output Bfactor x residue x PCA mode file
    type: File
    outputBinding:
      glob: $(inputs.output_dat_path)
    format: edam:format_1637

  output_pdb_path:
    label: Output PDB with Bfactor x residue x PCA mode file
    doc: |-
      Output PDB with Bfactor x residue x PCA mode file
    type: File?
    outputBinding:
      glob: $(inputs.output_pdb_path)
    format: edam:format_1476

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
