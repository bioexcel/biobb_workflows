#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
label: Automatic Ligand parameterization for GROMACS
doc: |-
  This workflow performs an automatic ligand parameterization for a small molecule using GAFF force field, generating parameters compatible with the GROMACS MD package.
inputs:
  step2_babel_minimize_config: string
  step2_babel_minimize_input_path: File
  step2_babel_minimize_output_path: string
  step3_acpype_params_gmx_config: string
  step3_acpype_params_gmx_output_path_gro: string
  step3_acpype_params_gmx_output_path_itp: string
  step3_acpype_params_gmx_output_path_top: string
outputs:
  step2_babel_minimize_out1:
    label: output_path
    doc: |-
      Path to the output file
    type: File
    outputSource: step2_babel_minimize/output_path
  step3_acpype_params_gmx_out1:
    label: output_path_gro
    doc: |-
      Path to the GRO output file
    type: File
    outputSource: step3_acpype_params_gmx/output_path_gro
  step3_acpype_params_gmx_out2:
    label: output_path_itp
    doc: |-
      Path to the ITP output file
    type: File
    outputSource: step3_acpype_params_gmx/output_path_itp
  step3_acpype_params_gmx_out3:
    label: output_path_top
    doc: |-
      Path to the TOP output file
    type: File
    outputSource: step3_acpype_params_gmx/output_path_top
steps:
  step2_babel_minimize:
    label: BabelMinimize
    doc: |-
      Energetically minimize small molecules.
    run: /path/to/biobb_adapters/biobb_adapters/cwl/biobb_chemistry/babel_minimize.cwl
    in:
      config: step2_babel_minimize_config
      input_path: step2_babel_minimize_input_path
      output_path: step2_babel_minimize_output_path
    out:
    - output_path
  step3_acpype_params_gmx:
    label: AcpypeParamsGMX
    doc: |-
      Small molecule parameterization for GROMACS MD package.
    run: /path/to/biobb_adapters/biobb_adapters/cwl/biobb_chemistry/acpype_params_gmx.cwl
    in:
      config: step3_acpype_params_gmx_config
      input_path: step2_babel_minimize/output_path
      output_path_gro: step3_acpype_params_gmx_output_path_gro
      output_path_itp: step3_acpype_params_gmx_output_path_itp
      output_path_top: step3_acpype_params_gmx_output_path_top
    out:
    - output_path_gro
    - output_path_itp
    - output_path_top
