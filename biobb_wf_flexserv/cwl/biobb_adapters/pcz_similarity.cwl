#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Compute PCA similarity between two given compressed PCZ files.

doc: |-
  Wrapper of the pczdump tool from the PCAsuite FlexServ module.

baseCommand: pcz_similarity

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_flexserv:4.1.0--pypl5321hdfd78af_0

inputs:
  input_pcz_path1:
    label: Input compressed trajectory file 1
    doc: |-
      Input compressed trajectory file 1
      Type: string
      File type: input
      Accepted formats: pcz
      Example file: https://github.com/bioexcel/biobb_flexserv/raw/master/biobb_flexserv/test/data/pcasuite/pcazip.pcz
    type: File
    format:
    - edam:format_3874
    inputBinding:
      position: 1
      prefix: --input_pcz_path1

  input_pcz_path2:
    label: Input compressed trajectory file 2
    doc: |-
      Input compressed trajectory file 2
      Type: string
      File type: input
      Accepted formats: pcz
      Example file: https://github.com/bioexcel/biobb_flexserv/raw/master/biobb_flexserv/test/data/pcasuite/pcazip.pcz
    type: File
    format:
    - edam:format_3874
    inputBinding:
      position: 2
      prefix: --input_pcz_path2

  output_json_path:
    label: Output json file with PCA Similarity results
    doc: |-
      Output json file with PCA Similarity results
      Type: string
      File type: output
      Accepted formats: json
      Example file: https://github.com/bioexcel/biobb_flexserv/raw/master/biobb_flexserv/test/reference/pcasuite/pcz_similarity.json
    type: string
    format:
    - edam:format_3464
    inputBinding:
      position: 3
      prefix: --output_json_path
    default: system.json

  config:
    label: Advanced configuration options for biobb_flexserv PCZsimilarity
    doc: |-
      Advanced configuration options for biobb_flexserv PCZsimilarity. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_flexserv PCZsimilarity documentation: https://biobb-flexserv.readthedocs.io/en/latest/pcasuite.html#module-pcasuite.pcz_similarity
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_json_path:
    label: Output json file with PCA Similarity results
    doc: |-
      Output json file with PCA Similarity results
    type: File
    outputBinding:
      glob: $(inputs.output_json_path)
    format: edam:format_3464

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
