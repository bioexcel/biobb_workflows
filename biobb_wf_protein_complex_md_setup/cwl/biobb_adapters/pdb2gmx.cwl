#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper class for the GROMACS pdb2gmx module.

doc: |-
  The GROMACS pdb2gmx module, reads a .pdb (or .gro) file, reads some database files, adds hydrogens to the molecules and generates coordinates in GROMACS (GROMOS), or optionally .pdb, format and a topology in GROMACS format. These files can subsequently be processed to generate a run input file.

baseCommand: pdb2gmx

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_gromacs:4.0.0--pyhdfd78af_1

inputs:
  input_pdb_path:
    label: Path to the input PDB file
    doc: |-
      Path to the input PDB file
      Type: string
      File type: input
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_gromacs/raw/master/biobb_gromacs/test/data/gromacs/egfr.pdb
    type: File
    format:
    - edam:format_1476
    inputBinding:
      position: 1
      prefix: --input_pdb_path

  output_gro_path:
    label: Path to the output GRO file
    doc: |-
      Path to the output GRO file
      Type: string
      File type: output
      Accepted formats: gro
      Example file: https://github.com/bioexcel/biobb_gromacs/raw/master/biobb_gromacs/test/reference/gromacs/ref_pdb2gmx.gro
    type: string
    format:
    - edam:format_2033
    inputBinding:
      position: 2
      prefix: --output_gro_path
    default: system.gro

  output_top_zip_path:
    label: Path the output TOP topology in zip format
    doc: |-
      Path the output TOP topology in zip format
      Type: string
      File type: output
      Accepted formats: zip
      Example file: https://github.com/bioexcel/biobb_gromacs/raw/master/biobb_gromacs/test/reference/gromacs/ref_pdb2gmx.zip
    type: string
    format:
    - edam:format_3987
    inputBinding:
      position: 3
      prefix: --output_top_zip_path
    default: system.zip

  config:
    label: Advanced configuration options for biobb_gromacs Pdb2gmx
    doc: |-
      Advanced configuration options for biobb_gromacs Pdb2gmx. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_gromacs Pdb2gmx documentation: https://biobb-gromacs.readthedocs.io/en/latest/gromacs.html#module-gromacs.pdb2gmx
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_gro_path:
    label: Path to the output GRO file
    doc: |-
      Path to the output GRO file
    type: File
    outputBinding:
      glob: $(inputs.output_gro_path)
    format: edam:format_2033

  output_top_zip_path:
    label: Path the output TOP topology in zip format
    doc: |-
      Path the output TOP topology in zip format
    type: File
    outputBinding:
      glob: $(inputs.output_top_zip_path)
    format: edam:format_3987

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
