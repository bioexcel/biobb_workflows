#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the AmberTools (AMBER MD Package) parmed tool module.

doc: |-
  Performs a Hydrogen Mass Repartition from an AMBER topology file using parmed tool from the AmberTools MD package.

baseCommand: parmed_hmassrepartition

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_amber:4.1.0--pyhdfd78af_0

inputs:
  input_top_path:
    label: Input AMBER topology file
    doc: |-
      Input AMBER topology file
      Type: string
      File type: input
      Accepted formats: top, parmtop, prmtop
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/data/parmed/input.hmass.prmtop
    type: File
    format:
    - edam:format_3881
    - edam:format_3881
    - edam:format_3881
    inputBinding:
      position: 1
      prefix: --input_top_path

  output_top_path:
    label: Output topology file (AMBER ParmTop)
    doc: |-
      Output topology file (AMBER ParmTop)
      Type: string
      File type: output
      Accepted formats: top, parmtop, prmtop
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/reference/parmed/output.hmass.prmtop
    type: string
    format:
    - edam:format_3881
    - edam:format_3881
    - edam:format_3881
    inputBinding:
      position: 2
      prefix: --output_top_path
    default: system.top

  config:
    label: Advanced configuration options for biobb_amber ParmedHMassRepartition
    doc: |-
      Advanced configuration options for biobb_amber ParmedHMassRepartition. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_amber ParmedHMassRepartition documentation: https://biobb-amber.readthedocs.io/en/latest/parmed.html#module-parmed.parmed_hmassrepartition
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_top_path:
    label: Output topology file (AMBER ParmTop)
    doc: |-
      Output topology file (AMBER ParmTop)
    type: File
    outputBinding:
      glob: $(inputs.output_top_path)
    format: edam:format_3881

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
