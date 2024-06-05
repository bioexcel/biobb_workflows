#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the AmberTools (AMBER MD Package) ambpdb tool module.

doc: |-
  Generates a PDB structure from AMBER topology (parmtop) and coordinates (crd) files, using the ambpdb tool from the AmberTools MD package.

baseCommand: amber_to_pdb

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_amber:4.1.0--pyhdfd78af_0

inputs:
  input_top_path:
    label: AMBER topology file
    doc: |-
      AMBER topology file
      Type: string
      File type: input
      Accepted formats: top, parmtop, prmtop
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/data/ambpdb/structure.leap.top
    type: File
    format:
    - edam:format_3881
    - edam:format_3881
    - edam:format_3881
    inputBinding:
      position: 1
      prefix: --input_top_path

  input_crd_path:
    label: AMBER coordinates file
    doc: |-
      AMBER coordinates file
      Type: string
      File type: input
      Accepted formats: crd, mdcrd, inpcrd, rst
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/data/ambpdb/structure.leap.crd
    type: File
    format:
    - edam:format_3878
    - edam:format_3878
    - edam:format_3878
    - edam:format_3886
    inputBinding:
      position: 2
      prefix: --input_crd_path

  output_pdb_path:
    label: Structure PDB file
    doc: |-
      Structure PDB file
      Type: string
      File type: output
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/reference/ambpdb/structure.ambpdb.pdb
    type: string
    format:
    - edam:format_1476
    inputBinding:
      position: 3
      prefix: --output_pdb_path
    default: system.pdb

  config:
    label: Advanced configuration options for biobb_amber AmberToPDB
    doc: |-
      Advanced configuration options for biobb_amber AmberToPDB. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_amber AmberToPDB documentation: https://biobb-amber.readthedocs.io/en/latest/ambpdb.html#module-ambpdb.amber_to_pdb
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_pdb_path:
    label: Structure PDB file
    doc: |-
      Structure PDB file
    type: File
    outputBinding:
      glob: $(inputs.output_pdb_path)
    format: edam:format_1476

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
