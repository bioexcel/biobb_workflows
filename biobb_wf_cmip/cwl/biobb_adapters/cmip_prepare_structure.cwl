#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Generate a CMIP suitable PDB input.

doc: |-
  Generate a CMIP suitable PDB input from a common PDB file or a Topology + PDB file.

baseCommand: cmip_prepare_structure

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_cmip:4.1.1--pyhdfd78af_0

inputs:
  input_pdb_path:
    label: Path to the input PDB file
    doc: |-
      Path to the input PDB file
      Type: string
      File type: input
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_cmip/raw/master/biobb_cmip/test/data/cmip/egfr.pdb
    type: File
    format:
    - edam:format_1476
    inputBinding:
      position: 1
      prefix: --input_pdb_path

  output_cmip_pdb_path:
    label: Path to the output PDB file
    doc: |-
      Path to the output PDB file
      Type: string
      File type: output
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_cmip/raw/master/biobb_cmip/test/reference/cmip/egfr_cmip.pdb
    type: string
    format:
    - edam:format_1476
    inputBinding:
      position: 2
      prefix: --output_cmip_pdb_path
    default: system.pdb

  input_topology_path:
    label: Path to the input topology path
    doc: |-
      Path to the input topology path
      Type: string
      File type: input
      Accepted formats: zip, top, psf, prmtop
      Example file: https://github.com/bioexcel/biobb_cmip/raw/master/biobb_cmip/test/data/cmip/egfr_topology.zip
    type: File?
    format:
    - edam:format_3879
    inputBinding:
      prefix: --input_topology_path

  config:
    label: Advanced configuration options for biobb_cmip PrepareStructure
    doc: |-
      Advanced configuration options for biobb_cmip PrepareStructure. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_cmip PrepareStructure documentation: https://biobb-cmip.readthedocs.io/en/latest/cmip.html#module-cmip.cmip_prepare_structure
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_cmip_pdb_path:
    label: Path to the output PDB file
    doc: |-
      Path to the output PDB file
    type: File
    outputBinding:
      glob: $(inputs.output_cmip_pdb_path)
    format: edam:format_1476

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
