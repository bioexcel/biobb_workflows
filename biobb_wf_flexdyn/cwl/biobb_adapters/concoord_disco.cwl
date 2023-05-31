#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the Disco tool from the Concoord package.

doc: |-
  Structure generation based on a set of geometric constraints extracted with the Concoord Dist tool.

baseCommand: concoord_disco

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_flexdyn:4.0.3--pyhdfd78af_0

inputs:
  input_pdb_path:
    label: Input structure file in PDB format
    doc: |-
      Input structure file in PDB format
      Type: string
      File type: input
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_flexdyn/raw/master/biobb_flexdyn/test/data/flexdyn/structure.pdb
    type: File
    format:
    - edam:format_1476
    inputBinding:
      position: 1
      prefix: --input_pdb_path

  input_dat_path:
    label: Input dat with structure interpretation and bond definitions
    doc: |-
      Input dat with structure interpretation and bond definitions
      Type: string
      File type: input
      Accepted formats: dat, txt
      Example file: https://github.com/bioexcel/biobb_flexdyn/raw/master/biobb_flexdyn/test/data/flexdyn/dist.dat
    type: File
    format:
    - edam:format_1637
    - edam:format_2330
    inputBinding:
      position: 2
      prefix: --input_dat_path

  output_traj_path:
    label: Output trajectory file
    doc: |-
      Output trajectory file
      Type: string
      File type: output
      Accepted formats: pdb, xtc, gro
      Example file: https://github.com/bioexcel/biobb_flexdyn/raw/master/biobb_flexdyn/test/reference/flexdyn/disco_trj.pdb
    type: string
    format:
    - edam:format_1476
    - edam:format_3875
    - edam:format_2033
    inputBinding:
      position: 3
      prefix: --output_traj_path
    default: system.pdb

  output_rmsd_path:
    label: Output rmsd file
    doc: |-
      Output rmsd file
      Type: string
      File type: output
      Accepted formats: dat
      Example file: https://github.com/bioexcel/biobb_flexdyn/raw/master/biobb_flexdyn/test/reference/flexdyn/disco_rmsd.dat
    type: string
    format:
    - edam:format_1637
    inputBinding:
      position: 4
      prefix: --output_rmsd_path
    default: system.dat

  output_bfactor_path:
    label: Output B-factor file
    doc: |-
      Output B-factor file
      Type: string
      File type: output
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_flexdyn/raw/master/biobb_flexdyn/test/reference/flexdyn/disco_bfactor.pdb
    type: string
    format:
    - edam:format_1476
    inputBinding:
      position: 5
      prefix: --output_bfactor_path
    default: system.pdb

  config:
    label: Advanced configuration options for biobb_flexdyn ConcoordDisco
    doc: |-
      Advanced configuration options for biobb_flexdyn ConcoordDisco. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_flexdyn ConcoordDisco documentation: https://biobb-flexdyn.readthedocs.io/en/latest/flexdyn.html#module-flexdyn.concoord_disco
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_traj_path:
    label: Output trajectory file
    doc: |-
      Output trajectory file
    type: File
    outputBinding:
      glob: $(inputs.output_traj_path)
    format: edam:format_1476

  output_rmsd_path:
    label: Output rmsd file
    doc: |-
      Output rmsd file
    type: File
    outputBinding:
      glob: $(inputs.output_rmsd_path)
    format: edam:format_1637

  output_bfactor_path:
    label: Output B-factor file
    doc: |-
      Output B-factor file
    type: File
    outputBinding:
      glob: $(inputs.output_bfactor_path)
    format: edam:format_1476

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
