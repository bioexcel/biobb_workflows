#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Class to ignore residues in CMIP potential calculations.

doc: |-
  Mark residues which will be ignored in the CMIP potential calculations except for dielectric definition.

baseCommand: cmip_ignore_residues

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_cmip:4.1.1--pyhdfd78af_0

inputs:
  input_cmip_pdb_path:
    label: Input PDB file path
    doc: |-
      Input PDB file path
      Type: string
      File type: input
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_cmip/raw/master/biobb_cmip/test/data/cmip/input_ignore_res.pdb
    type: File
    format:
    - edam:format_1476
    inputBinding:
      position: 1
      prefix: --input_cmip_pdb_path

  output_cmip_pdb_path:
    label: Output PDB file path
    doc: |-
      Output PDB file path
      Type: string
      File type: output
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_cmip/raw/master/biobb_cmip/test/reference/cmip/ignore_res_gln3.pdb
    type: string
    format:
    - edam:format_1476
    inputBinding:
      position: 2
      prefix: --output_cmip_pdb_path
    default: system.pdb

  config:
    label: Advanced configuration options for biobb_cmip CmipIgnoreResidues
    doc: |-
      Advanced configuration options for biobb_cmip CmipIgnoreResidues. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_cmip CmipIgnoreResidues documentation: https://biobb-cmip.readthedocs.io/en/latest/cmip.html#module-cmip.cmip_ignore_residues
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_cmip_pdb_path:
    label: Output PDB file path
    doc: |-
      Output PDB file path
    type: File
    outputBinding:
      glob: $(inputs.output_cmip_pdb_path)
    format: edam:format_1476

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
