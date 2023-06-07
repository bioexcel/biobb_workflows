#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the AmberTools (AMBER MD Package) process_mdout tool module.

doc: |-
  Parses the AMBER (sander) md output file (log) and dumps statistics that can then be plotted. Using the process_mdout.pl tool from the AmberTools MD package.

baseCommand: process_mdout

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_amber:4.0.0--pyhdfd78af_0

inputs:
  input_log_path:
    label: AMBER (sander) MD output (log) file
    doc: |-
      AMBER (sander) MD output (log) file
      Type: string
      File type: input
      Accepted formats: log, out, txt, o
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/data/process/sander.heat.log
    type: File
    format:
    - edam:format_2330
    - edam:format_2330
    - edam:format_2330
    - edam:format_2330
    inputBinding:
      position: 1
      prefix: --input_log_path

  output_dat_path:
    label: Dat output file containing data from the specified terms along the minimization
      process
    doc: |-
      Dat output file containing data from the specified terms along the minimization process
      Type: string
      File type: output
      Accepted formats: dat, txt, csv
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/reference/process/sander.md.temp.dat
    type: string
    format:
    - edam:format_1637
    - edam:format_2330
    - edam:format_3752
    inputBinding:
      position: 2
      prefix: --output_dat_path
    default: system.dat

  config:
    label: Advanced configuration options for biobb_amber.process.process_mdout ProcessMDOut
    doc: |-
      Advanced configuration options for biobb_amber.process.process_mdout ProcessMDOut. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_amber.process.process_mdout ProcessMDOut documentation: https://biobb-amber.readthedocs.io/en/latest/process.html#module-process.process_mdout
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_dat_path:
    label: Dat output file containing data from the specified terms along the minimization
      process
    doc: |-
      Dat output file containing data from the specified terms along the minimization process
    type: File
    outputBinding:
      glob: $(inputs.output_dat_path)
    format: edam:format_1637

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
