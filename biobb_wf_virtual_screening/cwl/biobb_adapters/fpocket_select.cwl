#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Selects a single pocket in the outputs of the fpocket building block.

doc: |-
  Selects a single pocket in the outputs of the fpocket building block from a given parameter.

baseCommand: fpocket_select

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_vs:4.0.0--pyhdfd78af_2

inputs:
  input_pockets_zip:
    label: Path to the pockets found by fpocket
    doc: |-
      Path to the pockets found by fpocket
      Type: string
      File type: input
      Accepted formats: zip
      Example file: https://github.com/bioexcel/biobb_vs/raw/master/biobb_vs/test/data/fpocket/input_pockets.zip
    type: File
    format:
    - edam:format_3987
    inputBinding:
      position: 1
      prefix: --input_pockets_zip

  output_pocket_pdb:
    label: Path to the PDB file with the cavity found by fpocket
    doc: |-
      Path to the PDB file with the cavity found by fpocket
      Type: string
      File type: output
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_vs/raw/master/biobb_vs/test/reference/fpocket/ref_output_pocket.pdb
    type: string
    format:
    - edam:format_1476
    inputBinding:
      position: 2
      prefix: --output_pocket_pdb
    default: system.pdb

  output_pocket_pqr:
    label: Path to the PQR file with the pocket found by fpocket
    doc: |-
      Path to the PQR file with the pocket found by fpocket
      Type: string
      File type: output
      Accepted formats: pqr
      Example file: https://github.com/bioexcel/biobb_vs/raw/master/biobb_vs/test/reference/fpocket/ref_output_pocket.pqr
    type: string
    format:
    - edam:format_1476
    inputBinding:
      position: 3
      prefix: --output_pocket_pqr
    default: system.pqr

  config:
    label: Advanced configuration options for biobb_vs FPocketSelect
    doc: |-
      Advanced configuration options for biobb_vs FPocketSelect. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_vs FPocketSelect documentation: https://biobb-vs.readthedocs.io/en/latest/fpocket.html#module-fpocket.fpocket_select
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_pocket_pdb:
    label: Path to the PDB file with the cavity found by fpocket
    doc: |-
      Path to the PDB file with the cavity found by fpocket
    type: File
    outputBinding:
      glob: $(inputs.output_pocket_pdb)
    format: edam:format_1476

  output_pocket_pqr:
    label: Path to the PQR file with the pocket found by fpocket
    doc: |-
      Path to the PQR file with the pocket found by fpocket
    type: File
    outputBinding:
      glob: $(inputs.output_pocket_pqr)
    format: edam:format_1476

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
