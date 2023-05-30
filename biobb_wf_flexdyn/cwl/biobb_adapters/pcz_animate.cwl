#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Extract PCA animations from a compressed PCZ file.

doc: |-
  Wrapper of the pczdump tool from the PCAsuite FlexServ module.

baseCommand: pcz_animate

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_flexserv:4.0.0--pypl5321hdfd78af_1

inputs:
  input_pcz_path:
    label: Input compressed trajectory file
    doc: |-
      Input compressed trajectory file
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
    label: Output PCA animated trajectory file
    doc: |-
      Output PCA animated trajectory file
      Type: string
      File type: output
      Accepted formats: crd, mdcrd, inpcrd, pdb
      Example file: https://github.com/bioexcel/biobb_flexserv/raw/master/biobb_flexserv/test/reference/pcasuite/pcazip_anim1.pdb
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
    label: Advanced configuration options for biobb_flexserv PCZanimate
    doc: |-
      Advanced configuration options for biobb_flexserv PCZanimate. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_flexserv PCZanimate documentation: https://biobb-flexserv.readthedocs.io/en/latest/pcasuite.html#module-pcasuite.pcz_animate
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_crd_path:
    label: Output PCA animated trajectory file
    doc: |-
      Output PCA animated trajectory file
    type: File
    outputBinding:
      glob: $(inputs.output_crd_path)
    format: edam:format_3878

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
