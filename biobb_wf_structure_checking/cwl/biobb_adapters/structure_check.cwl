#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: This class is a wrapper of the Structure Checking tool to generate summary
  checking results on a json file.

doc: |-
  Wrapper for the Structure Checking tool to generate summary checking results on a json file from a given structure and a list of features.

baseCommand: structure_check

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_structure_utils:4.1.0--pyhdfd78af_0

inputs:
  input_structure_path:
    label: Input structure file path
    doc: |-
      Input structure file path
      Type: string
      File type: input
      Accepted formats: pdb, pdbqt
      Example file: https://github.com/bioexcel/biobb_structure_utils/raw/master/biobb_structure_utils/test/data/utils/2vgb.pdb
    type: File
    format:
    - edam:format_1476
    - edam:format_1476
    inputBinding:
      position: 1
      prefix: --input_structure_path

  output_summary_path:
    label: Output summary checking results
    doc: |-
      Output summary checking results
      Type: string
      File type: output
      Accepted formats: json
      Example file: https://github.com/bioexcel/biobb_structure_utils/raw/master/biobb_structure_utils/test/reference/utils/summary.json
    type: string
    format:
    - edam:format_3464
    inputBinding:
      position: 2
      prefix: --output_summary_path
    default: system.json

  config:
    label: Advanced configuration options for biobb_structure_utils StructureCheck
    doc: |-
      Advanced configuration options for biobb_structure_utils StructureCheck. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_structure_utils StructureCheck documentation: https://biobb-structure-utils.readthedocs.io/en/latest/utils.html#module-utils.structure_check
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_summary_path:
    label: Output summary checking results
    doc: |-
      Output summary checking results
    type: File
    outputBinding:
      glob: $(inputs.output_summary_path)
    format: edam:format_3464

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
