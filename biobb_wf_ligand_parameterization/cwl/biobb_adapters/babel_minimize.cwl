#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: This class is a wrapper of the Open Babel tool.

doc: |-
  Energetically minimizes small molecules. Open Babel is a chemical toolbox designed to speak the many languages of chemical data. It's an open, collaborative project allowing anyone to search, convert, analyze, or store data from molecular modeling, chemistry, solid-state materials, biochemistry, or related areas. Visit the official page.

baseCommand: babel_minimize

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_chemistry:4.1.0--pyhdfd78af_0

inputs:
  input_path:
    label: Path to the input file
    doc: |-
      Path to the input file
      Type: string
      File type: input
      Accepted formats: pdb, mol2
      Example file: https://github.com/bioexcel/biobb_chemistry/raw/master/biobb_chemistry/test/data/babel/babel.minimize.pdb
    type: File
    format:
    - edam:format_1476
    - edam:format_3816
    inputBinding:
      position: 1
      prefix: --input_path

  output_path:
    label: Path to the output file
    doc: |-
      Path to the output file
      Type: string
      File type: output
      Accepted formats: pdb, mol2
      Example file: https://github.com/bioexcel/biobb_chemistry/raw/master/biobb_chemistry/test/reference/babel/ref_babel.minimize.pdb
    type: string
    format:
    - edam:format_1476
    - edam:format_3816
    inputBinding:
      position: 2
      prefix: --output_path
    default: system.pdb

  config:
    label: Advanced configuration options for biobb_chemistry BabelMinimize
    doc: |-
      Advanced configuration options for biobb_chemistry BabelMinimize. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_chemistry BabelMinimize documentation: https://biobb-chemistry.readthedocs.io/en/latest/babelm.html#module-babelm.babel_minimize
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_path:
    label: Path to the output file
    doc: |-
      Path to the output file
    type: File
    outputBinding:
      glob: $(inputs.output_path)
    format: edam:format_1476

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
