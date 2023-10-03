#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the pcaunzip tool from the PCAsuite FlexServ module.

doc: |-
  Uncompress Molecular Dynamics (MD) trajectories compressed using Principal Component Analysis (PCA) algorithms.

baseCommand: pcz_unzip

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_flexserv:4.1.0--pypl5321hdfd78af_0

inputs:
  input_pcz_path:
    label: Input compressed trajectory
    doc: |-
      Input compressed trajectory
      Type: string
      File type: input
      Accepted formats: pcz
      Example file: https://github.com/bioexcel/biobb_flexserv/raw/master/biobb_flexserv/test/data/pcasuite/pcazip.pcz
    type: File
    format:
    - edam:format_3874
    inputBinding:
      position: 1
      prefix: --input_pcz_path

  output_crd_path:
    label: Output uncompressed trajectory
    doc: |-
      Output uncompressed trajectory
      Type: string
      File type: output
      Accepted formats: crd, mdcrd, inpcrd, pdb
      Example file: https://github.com/bioexcel/biobb_flexserv/raw/master/biobb_flexserv/test/reference/pcasuite/traj.crd
    type: string
    format:
    - edam:format_3878
    - edam:format_3878
    - edam:format_3878
    - edam:format_1476
    inputBinding:
      position: 2
      prefix: --output_crd_path
    default: system.crd

  config:
    label: Advanced configuration options for biobb_flexserv PCZunzip
    doc: |-
      Advanced configuration options for biobb_flexserv PCZunzip. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_flexserv PCZunzip documentation: https://biobb-flexserv.readthedocs.io/en/latest/pcasuite.html#module-pcasuite.pcz_unzip
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_crd_path:
    label: Output uncompressed trajectory
    doc: |-
      Output uncompressed trajectory
    type: File
    outputBinding:
      glob: $(inputs.output_crd_path)
    format: edam:format_3878

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
