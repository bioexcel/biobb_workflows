#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the AmberTools (AMBER MD Package) pdb4amber tool module.

doc: |-
  Analyse PDB files and clean them for further usage, especially with the LEaP programs of Amber, using pdb4amber tool from the AmberTools MD package.

baseCommand: pdb4amber_run

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_amber:4.0.1--pyhdfd78af_0

inputs:
  input_pdb_path:
    label: Input 3D structure PDB file
    doc: |-
      Input 3D structure PDB file
      Type: string
      File type: input
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/data/pdb4amber/1aki_fixed.pdb
    type: File
    format:
    - edam:format_1476
    inputBinding:
      position: 1
      prefix: --input_pdb_path

  output_pdb_path:
    label: Output 3D structure PDB file
    doc: |-
      Output 3D structure PDB file
      Type: string
      File type: output
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/reference/pdb4amber/structure.pdb4amber.pdb
    type: string
    format:
    - edam:format_1476
    inputBinding:
      position: 2
      prefix: --output_pdb_path
    default: system.pdb

  config:
    label: Advanced configuration options for biobb_amber.pdb4amber.pdb4amber_run
      Pdb4amberRun
    doc: |-
      Advanced configuration options for biobb_amber.pdb4amber.pdb4amber_run Pdb4amberRun. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_amber.pdb4amber.pdb4amber_run Pdb4amberRun documentation: https://biobb-amber.readthedocs.io/en/latest/pdb4amber.html#module-pdb4amber.pdb4amber_run
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_pdb_path:
    label: Output 3D structure PDB file
    doc: |-
      Output 3D structure PDB file
    type: File
    outputBinding:
      glob: $(inputs.output_pdb_path)
    format: edam:format_1476

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
