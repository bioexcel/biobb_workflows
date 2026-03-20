#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper class for the GROMACS trjcat module.

doc: |-
  The GROMACS solvate module generates a box around the selected structure.

baseCommand: trjcat

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_gromacs:5.2.1--pyhdfd78af_0

inputs:
  input_trj_zip_path:
    label: Path the input GROMACS trajectories (xtc, trr, cpt, gro, pdb, tng) to concatenate
      in zip format
    doc: |-
      Path the input GROMACS trajectories (xtc, trr, cpt, gro, pdb, tng) to concatenate in zip format
      Type: string
      File type: input
      Accepted formats: zip
      Example file: https://github.com/bioexcel/biobb_gromacs/raw/master/biobb_gromacs/test/data/gromacs/trjcat.zip
    type: File
    format:
    - edam:format_3987
    inputBinding:
      position: 1
      prefix: --input_trj_zip_path

  output_trj_path:
    label: Path to the output trajectory file
    doc: |-
      Path to the output trajectory file
      Type: string
      File type: output
      Accepted formats: pdb, gro, xtc, trr, tng
      Example file: https://github.com/bioexcel/biobb_gromacs/raw/master/biobb_gromacs/test/reference/gromacs/ref_trjcat.trr
    type: string
    format:
    - edam:format_1476
    - edam:format_2033
    - edam:format_3875
    - edam:format_3910
    - edam:format_3876
    inputBinding:
      position: 2
      prefix: --output_trj_path
    default: system.pdb

  config:
    label: Advanced configuration options for biobb_gromacs Trjcat
    doc: |-
      Advanced configuration options for biobb_gromacs Trjcat. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_gromacs Trjcat documentation: https://biobb-gromacs.readthedocs.io/en/latest/gromacs.html#module-gromacs.trjcat
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_trj_path:
    label: Path to the output trajectory file
    doc: |-
      Path to the output trajectory file
    type: File
    outputBinding:
      glob: $(inputs.output_trj_path)
    format: edam:format_1476

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
