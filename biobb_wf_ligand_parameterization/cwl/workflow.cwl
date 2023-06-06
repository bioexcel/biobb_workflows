#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
label: Automatic Ligand parameterization for GROMACS
doc: |-
  This workflow performs an automatic ligand parameterization for a small molecule using GAFF force field, generating parameters compatible with the GROMACS MD package.
inputs:
  step2_babel_minimize_input_path:
    label: Input file
    doc: Path to the input file.
    type: File
  step2_babel_minimize_output_path:
    label: Output file
    doc: Path to the output file.
    type: string
  step2_babel_minimize_config:
    label: Config file
    doc: Configuration file for biobb_chemistry.babel_minimize tool.
    type: string
  step3_acpype_params_gmx_output_path_gro:
    label: Output file
    doc: Path to the GRO output file.
    type: string
  step3_acpype_params_gmx_output_path_itp:
    label: Output file
    doc: Path to the ITP output file.
    type: string
  step3_acpype_params_gmx_output_path_top:
    label: Output file
    doc: Path to the TOP output file.
    type: string
  step3_acpype_params_gmx_config:
    label: Config file
    doc: Configuration file for biobb_chemistry.acpype_params_gmx tool.
    type: string
outputs:
  step2_babel_minimize_out1:
    label: output_path
    doc: Path to the output file.
    type: File
    outputSource: step2_babel_minimize/output_path
  step3_acpype_params_gmx_out1:
    label: output_path_gro
    doc: Path to the GRO output file.
    type: File
    outputSource: step3_acpype_params_gmx/output_path_gro
  step3_acpype_params_gmx_out2:
    label: output_path_itp
    doc: Path to the ITP output file.
    type: File
    outputSource: step3_acpype_params_gmx/output_path_itp
  step3_acpype_params_gmx_out3:
    label: output_path_top
    doc: Path to the TOP output file.
    type: File
    outputSource: step3_acpype_params_gmx/output_path_top
steps:
  step2_babel_minimize:
    label: babel_minimize
    doc: Energetically minimize small molecules.
    run: biobb_adapters/babel_minimize.cwl
    in:
      config: step2_babel_minimize_config
      input_path: step2_babel_minimize_input_path
      output_path: step2_babel_minimize_output_path
    out:
    - output_path
  step3_acpype_params_gmx:
    label: acpype_params_gmx
    doc: Small molecule parameterization for GROMACS MD package.
    run: biobb_adapters/acpype_params_gmx.cwl
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
