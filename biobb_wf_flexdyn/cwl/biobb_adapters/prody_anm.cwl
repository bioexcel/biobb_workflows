#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the ANM tool from the Prody package.

doc: |-
  Generate an ensemble of structures using the Prody Anisotropic Network Model (ANM), for coarse-grained NMA.

baseCommand: prody_anm

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_flexdyn:4.1.0--pyhdfd78af_0

inputs:
  input_pdb_path:
    label: Input PDB file
    doc: |-
      Input PDB file
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

  output_pdb_path:
    label: Output multi-model PDB file with the generated ensemble
    doc: |-
      Output multi-model PDB file with the generated ensemble
      Type: string
      File type: output
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_flexdyn/raw/master/biobb_flexdyn/test/reference/prody/prody_output.pdb
    type: string
    format:
    - edam:format_1476
    inputBinding:
      position: 2
      prefix: --output_pdb_path
    default: system.pdb

  config:
    label: Advanced configuration options for biobb_flexdyn ProdyANM
    doc: |-
      Advanced configuration options for biobb_flexdyn ProdyANM. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_flexdyn ProdyANM documentation: https://biobb-flexdyn.readthedocs.io/en/latest/flexdyn.html#module-flexdyn.prody_anm
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_pdb_path:
    label: Output multi-model PDB file with the generated ensemble
    doc: |-
      Output multi-model PDB file with the generated ensemble
    type: File
    outputBinding:
      glob: $(inputs.output_pdb_path)
    format: edam:format_1476

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
