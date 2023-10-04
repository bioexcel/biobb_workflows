#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: This class is a wrapper of the Ambertools reduce module for removing hydrogens
  from a given structure.

doc: |-
  Reduce is a program for adding or removing hydrogens to a Protein DataBank (PDB) molecular structure file.

baseCommand: reduce_remove_hydrogens

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
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_chemistry/raw/master/biobb_chemistry/test/data/ambertools/reduce.H.pdb
    type: File
    format:
    - edam:format_1476
    inputBinding:
      position: 1
      prefix: --input_path

  output_path:
    label: Path to the output file
    doc: |-
      Path to the output file
      Type: string
      File type: output
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_chemistry/raw/master/biobb_chemistry/test/reference/ambertools/ref_reduce.remove.pdb
    type: string
    format:
    - edam:format_1476
    inputBinding:
      position: 2
      prefix: --output_path
    default: system.pdb

  config:
    label: Advanced configuration options for biobb_chemistry ReduceRemoveHydrogens
    doc: |-
      Advanced configuration options for biobb_chemistry ReduceRemoveHydrogens. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_chemistry ReduceRemoveHydrogens documentation: https://biobb-chemistry.readthedocs.io/en/latest/ambertools.html#module-ambertools.reduce_remove_hydrogens
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
