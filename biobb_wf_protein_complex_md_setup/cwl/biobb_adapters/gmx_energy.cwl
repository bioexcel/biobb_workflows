#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the GROMACS energy module for extracting energy components from
  a given GROMACS energy file.

doc: |-
  GROMACS energy extracts energy components from an energy file. The user is prompted to interactively select the desired energy terms.

baseCommand: gmx_energy

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_analysis:4.1.0--pyhdfd78af_0

inputs:
  input_energy_path:
    label: Path to the input EDR file
    doc: |-
      Path to the input EDR file
      Type: string
      File type: input
      Accepted formats: edr
      Example file: https://github.com/bioexcel/biobb_analysis/raw/master/biobb_analysis/test/data/gromacs/energy.edr
    type: File
    format:
    - edam:format_2330
    inputBinding:
      position: 1
      prefix: --input_energy_path

  output_xvg_path:
    label: Path to the XVG output file
    doc: |-
      Path to the XVG output file
      Type: string
      File type: output
      Accepted formats: xvg
      Example file: https://github.com/bioexcel/biobb_analysis/raw/master/biobb_analysis/test/reference/gromacs/ref_energy.xvg
    type: string
    format:
    - edam:format_2030
    inputBinding:
      position: 2
      prefix: --output_xvg_path
    default: system.xvg

  config:
    label: Advanced configuration options for biobb_analysis GMXEnergy
    doc: |-
      Advanced configuration options for biobb_analysis GMXEnergy. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_analysis GMXEnergy documentation: https://biobb-analysis.readthedocs.io/en/latest/gromacs.html#module-gromacs.gmx_energy
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_xvg_path:
    label: Path to the XVG output file
    doc: |-
      Path to the XVG output file
    type: File
    outputBinding:
      glob: $(inputs.output_xvg_path)
    format: edam:format_2030

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
