#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the AmberTools (AMBER MD Package) process_minout tool module.

doc: |-
  Parses the AMBER (sander) minimization output file (log) and dumps statistics that can then be plotted. Using the process_minout.pl tool from the AmberTools MD package.

baseCommand: process_minout

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_amber:4.0.1--pyhdfd78af_0

inputs:
  input_log_path:
    label: AMBER (sander) Minimization output (log) file
    doc: |-
      AMBER (sander) Minimization output (log) file
      Type: string
      File type: input
      Accepted formats: log, out, txt, o
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/data/process/sander.min.log
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
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/reference/process/sander.min.energy.dat
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
    label: Advanced configuration options for biobb_amber.process.process_minout ProcessMinOut
    doc: |-
      Advanced configuration options for biobb_amber.process.process_minout ProcessMinOut. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_amber.process.process_minout ProcessMinOut documentation: https://biobb-amber.readthedocs.io/en/latest/process.html#module-process.process_minout
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
