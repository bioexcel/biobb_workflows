#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the pcazip tool from the PCAsuite FlexServ module.

doc: |-
  Compress Molecular Dynamics (MD) trajectories using Principal Component Analysis (PCA) algorithms.

baseCommand: pcz_zip

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_flexserv:4.0.2--pypl5321hdfd78af_0

inputs:
  input_pdb_path:
    label: Input PDB file
    doc: |-
      Input PDB file
      Type: string
      File type: input
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_flexserv/raw/master/biobb_flexserv/test/data/pcasuite/structure.ca.pdb
    type: File
    format:
    - edam:format_1476
    inputBinding:
      position: 1
      prefix: --input_pdb_path

  input_crd_path:
    label: Input Trajectory file
    doc: |-
      Input Trajectory file
      Type: string
      File type: input
      Accepted formats: crd, mdcrd, inpcrd
      Example file: https://github.com/bioexcel/biobb_flexserv/raw/master/biobb_flexserv/test/data/pcasuite/traj.crd
    type: File
    format:
    - edam:format_3878
    - edam:format_3878
    - edam:format_3878
    inputBinding:
      position: 2
      prefix: --input_crd_path

  output_pcz_path:
    label: Output compressed trajectory
    doc: |-
      Output compressed trajectory
      Type: string
      File type: output
      Accepted formats: pcz
      Example file: https://github.com/bioexcel/biobb_flexserv/raw/master/biobb_flexserv/test/reference/pcasuite/pcazip.pcz
    type: string
    format:
    - edam:format_3874
    inputBinding:
      position: 3
      prefix: --output_pcz_path
    default: system.pcz

  config:
    label: Advanced configuration options for biobb_flexserv PCZzip
    doc: |-
      Advanced configuration options for biobb_flexserv PCZzip. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_flexserv PCZzip documentation: https://biobb-flexserv.readthedocs.io/en/latest/pcasuite.html#module-pcasuite.pcz_zip
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_pcz_path:
    label: Output compressed trajectory
    doc: |-
      Output compressed trajectory
    type: File
    outputBinding:
      glob: $(inputs.output_pcz_path)
    format: edam:format_3874

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
