#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the GROMACS mdrun module.

doc: |-
  MDRun is the main computational chemistry engine within GROMACS. It performs Molecular Dynamics simulations, but it can also perform Stochastic Dynamics, Energy Minimization, test particle insertion or (re)calculation of energies.

baseCommand: mdrun

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_gromacs:4.0.0--pyhdfd78af_1

inputs:
  input_tpr_path:
    label: Path to the portable binary run input file TPR
    doc: |-
      Path to the portable binary run input file TPR
      Type: string
      File type: input
      Accepted formats: tpr
      Example file: https://github.com/bioexcel/biobb_gromacs/raw/master/biobb_gromacs/test/data/gromacs/mdrun.tpr
    type: File
    format:
    - edam:format_2333
    inputBinding:
      position: 1
      prefix: --input_tpr_path

  output_gro_path:
    label: Path to the output GROMACS structure GRO file
    doc: |-
      Path to the output GROMACS structure GRO file
      Type: string
      File type: output
      Accepted formats: gro
      Example file: https://github.com/bioexcel/biobb_gromacs/raw/master/biobb_gromacs/test/reference/gromacs/ref_mdrun.gro
    type: string
    format:
    - edam:format_2033
    inputBinding:
      position: 2
      prefix: --output_gro_path
    default: system.gro

  output_edr_path:
    label: Path to the output GROMACS portable energy file EDR
    doc: |-
      Path to the output GROMACS portable energy file EDR
      Type: string
      File type: output
      Accepted formats: edr
      Example file: https://github.com/bioexcel/biobb_gromacs/raw/master/biobb_gromacs/test/reference/gromacs/ref_mdrun.edr
    type: string
    format:
    - edam:format_2330
    inputBinding:
      position: 3
      prefix: --output_edr_path
    default: system.edr

  output_log_path:
    label: Path to the output GROMACS trajectory log file LOG
    doc: |-
      Path to the output GROMACS trajectory log file LOG
      Type: string
      File type: output
      Accepted formats: log
      Example file: https://github.com/bioexcel/biobb_gromacs/raw/master/biobb_gromacs/test/reference/gromacs/ref_mdrun.log
    type: string
    format:
    - edam:format_2330
    inputBinding:
      position: 4
      prefix: --output_log_path
    default: system.log

  output_trr_path:
    label: Path to the GROMACS uncompressed raw trajectory file TRR
    doc: |-
      Path to the GROMACS uncompressed raw trajectory file TRR
      Type: string
      File type: output
      Accepted formats: trr
      Example file: https://github.com/bioexcel/biobb_gromacs/raw/master/biobb_gromacs/test/reference/gromacs/ref_mdrun.trr
    type: string
    format:
    - edam:format_3910
    inputBinding:
      prefix: --output_trr_path
    default: system.trr

  input_cpt_path:
    label: Path to the input GROMACS checkpoint file CPT
    doc: |-
      Path to the input GROMACS checkpoint file CPT
      Type: string
      File type: input
      Accepted formats: cpt
      Example file: null
    type: File?
    format:
    - edam:format_2333
    inputBinding:
      prefix: --input_cpt_path

  output_xtc_path:
    label: Path to the GROMACS compressed trajectory file XTC
    doc: |-
      Path to the GROMACS compressed trajectory file XTC
      Type: string
      File type: output
      Accepted formats: xtc
      Example file: null
    type: string
    format:
    - edam:format_3875
    inputBinding:
      prefix: --output_xtc_path
    default: system.xtc

  output_cpt_path:
    label: Path to the output GROMACS checkpoint file CPT
    doc: |-
      Path to the output GROMACS checkpoint file CPT
      Type: string
      File type: output
      Accepted formats: cpt
      Example file: null
    type: string
    format:
    - edam:format_2333
    inputBinding:
      prefix: --output_cpt_path
    default: system.cpt

  output_dhdl_path:
    label: Path to the output dhdl.xvg file only used when free energy calculation
      is turned on
    doc: |-
      Path to the output dhdl.xvg file only used when free energy calculation is turned on
      Type: string
      File type: output
      Accepted formats: xvg
      Example file: null
    type: string
    format:
    - edam:format_2033
    inputBinding:
      prefix: --output_dhdl_path
    default: system.xvg

  config:
    label: Advanced configuration options for biobb_gromacs Mdrun
    doc: |-
      Advanced configuration options for biobb_gromacs Mdrun. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_gromacs Mdrun documentation: https://biobb-gromacs.readthedocs.io/en/latest/gromacs.html#module-gromacs.mdrun
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_gro_path:
    label: Path to the output GROMACS structure GRO file
    doc: |-
      Path to the output GROMACS structure GRO file
    type: File
    outputBinding:
      glob: $(inputs.output_gro_path)
    format: edam:format_2033

  output_edr_path:
    label: Path to the output GROMACS portable energy file EDR
    doc: |-
      Path to the output GROMACS portable energy file EDR
    type: File
    outputBinding:
      glob: $(inputs.output_edr_path)
    format: edam:format_2330

  output_log_path:
    label: Path to the output GROMACS trajectory log file LOG
    doc: |-
      Path to the output GROMACS trajectory log file LOG
    type: File
    outputBinding:
      glob: $(inputs.output_log_path)
    format: edam:format_2330

  output_trr_path:
    label: Path to the GROMACS uncompressed raw trajectory file TRR
    doc: |-
      Path to the GROMACS uncompressed raw trajectory file TRR
    type: File?
    outputBinding:
      glob: $(inputs.output_trr_path)
    format: edam:format_3910

  output_xtc_path:
    label: Path to the GROMACS compressed trajectory file XTC
    doc: |-
      Path to the GROMACS compressed trajectory file XTC
    type: File?
    outputBinding:
      glob: $(inputs.output_xtc_path)
    format: edam:format_3875

  output_cpt_path:
    label: Path to the output GROMACS checkpoint file CPT
    doc: |-
      Path to the output GROMACS checkpoint file CPT
    type: File?
    outputBinding:
      glob: $(inputs.output_cpt_path)
    format: edam:format_2333

  output_dhdl_path:
    label: Path to the output dhdl.xvg file only used when free energy calculation
      is turned on
    doc: |-
      Path to the output dhdl.xvg file only used when free energy calculation is turned on
    type: File?
    outputBinding:
      glob: $(inputs.output_dhdl_path)
    format: edam:format_2033

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
