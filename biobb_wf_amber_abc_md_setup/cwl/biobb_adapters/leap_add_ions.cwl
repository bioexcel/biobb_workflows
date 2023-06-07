#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the AmberTools (AMBER MD Package) leap tool module.

doc: |-
  Adds counterions to a system box for an AMBER MD system using tLeap tool from the AmberTools MD package.

baseCommand: leap_add_ions

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_amber:4.0.0--pyhdfd78af_0

inputs:
  input_pdb_path:
    label: Input 3D structure PDB file
    doc: |-
      Input 3D structure PDB file
      Type: string
      File type: input
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/data/leap/structure.solv.pdb
    type: File
    format:
    - edam:format_1476
    inputBinding:
      position: 1
      prefix: --input_pdb_path

  output_pdb_path:
    label: Output 3D structure PDB file matching the topology file
    doc: |-
      Output 3D structure PDB file matching the topology file
      Type: string
      File type: output
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/reference/leap/structure.ions.pdb
    type: string
    format:
    - edam:format_1476
    inputBinding:
      position: 2
      prefix: --output_pdb_path
    default: system.pdb

  output_top_path:
    label: Output topology file (AMBER ParmTop)
    doc: |-
      Output topology file (AMBER ParmTop)
      Type: string
      File type: output
      Accepted formats: top, parmtop, prmtop
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/reference/leap/structure.ions.top
    type: string
    format:
    - edam:format_3881
    - edam:format_3881
    - edam:format_3881
    inputBinding:
      position: 3
      prefix: --output_top_path
    default: system.top

  output_crd_path:
    label: Output coordinates file (AMBER crd)
    doc: |-
      Output coordinates file (AMBER crd)
      Type: string
      File type: output
      Accepted formats: crd, mdcrd, inpcrd
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/reference/leap/structure.ions.crd
    type: string
    format:
    - edam:format_3878
    - edam:format_3878
    - edam:format_3878
    inputBinding:
      position: 4
      prefix: --output_crd_path
    default: system.crd

  input_lib_path:
    label: Input ligand library parameters file
    doc: |-
      Input ligand library parameters file
      Type: string
      File type: input
      Accepted formats: lib, zip
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/data/leap/ligand.lib
    type: File?
    format:
    - edam:format_3889
    - edam:format_3987
    inputBinding:
      prefix: --input_lib_path

  input_frcmod_path:
    label: Input ligand frcmod parameters file
    doc: |-
      Input ligand frcmod parameters file
      Type: string
      File type: input
      Accepted formats: frcmod, zip
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/data/leap/ligand.frcmod
    type: File?
    format:
    - edam:format_3888
    - edam:format_3987
    inputBinding:
      prefix: --input_frcmod_path

  input_params_path:
    label: Additional leap parameter files to load with loadAmberParams Leap command
    doc: |-
      Additional leap parameter files to load with loadAmberParams Leap command
      Type: string
      File type: input
      Accepted formats: in, leapin, txt, zip
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/data/leap/frcmod.ionsdang_spce.txt
    type: File?
    format:
    - edam:format_2330
    - edam:format_2330
    - edam:format_2330
    - edam:format_3987
    inputBinding:
      prefix: --input_params_path

  input_source_path:
    label: Additional leap command files to load with source Leap command
    doc: |-
      Additional leap command files to load with source Leap command
      Type: string
      File type: input
      Accepted formats: in, leapin, txt, zip
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/data/leap/leaprc.water.spce.txt
    type: File?
    format:
    - edam:format_2330
    - edam:format_2330
    - edam:format_2330
    - edam:format_3987
    inputBinding:
      prefix: --input_source_path

  config:
    label: Advanced configuration options for biobb_amber LeapAddIons
    doc: |-
      Advanced configuration options for biobb_amber LeapAddIons. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_amber LeapAddIons documentation: https://biobb-amber.readthedocs.io/en/latest/leap.html#module-leap.leap_add_ions
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_pdb_path:
    label: Output 3D structure PDB file matching the topology file
    doc: |-
      Output 3D structure PDB file matching the topology file
    type: File
    outputBinding:
      glob: $(inputs.output_pdb_path)
    format: edam:format_1476

  output_top_path:
    label: Output topology file (AMBER ParmTop)
    doc: |-
      Output topology file (AMBER ParmTop)
    type: File
    outputBinding:
      glob: $(inputs.output_top_path)
    format: edam:format_3881

  output_crd_path:
    label: Output coordinates file (AMBER crd)
    doc: |-
      Output coordinates file (AMBER crd)
    type: File
    outputBinding:
      glob: $(inputs.output_crd_path)
    format: edam:format_3878

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
