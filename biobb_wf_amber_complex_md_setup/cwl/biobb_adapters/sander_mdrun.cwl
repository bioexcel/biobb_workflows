#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the AmberTools (AMBER MD Package) sander tool module.

doc: |-
  Runs energy minimization, molecular dynamics, and NMR refinements using sander tool from the AmberTools MD package.

baseCommand: sander_mdrun

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_amber:4.0.0--pyhdfd78af_0

inputs:
  input_top_path:
    label: Input topology file (AMBER ParmTop)
    doc: |-
      Input topology file (AMBER ParmTop)
      Type: string
      File type: input
      Accepted formats: top, parmtop, prmtop
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/data/sander/cln025.prmtop
    type: File
    format:
    - edam:format_3881
    - edam:format_3881
    - edam:format_3881
    inputBinding:
      position: 1
      prefix: --input_top_path

  input_crd_path:
    label: Input coordinates file (AMBER crd)
    doc: |-
      Input coordinates file (AMBER crd)
      Type: string
      File type: input
      Accepted formats: crd, mdcrd, inpcrd, netcdf, nc, ncrst
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/data/sander/cln025.inpcrd
    type: File
    format:
    - edam:format_3878
    - edam:format_3878
    - edam:format_3878
    - edam:format_3650
    - edam:format_3650
    - edam:format_3886
    inputBinding:
      position: 2
      prefix: --input_crd_path

  output_log_path:
    label: Output log file
    doc: |-
      Output log file
      Type: string
      File type: output
      Accepted formats: log, out, txt, o
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/reference/sander/sander.log
    type: string
    format:
    - edam:format_2330
    - edam:format_2330
    - edam:format_2330
    - edam:format_2330
    inputBinding:
      position: 3
      prefix: --output_log_path
    default: system.log

  output_traj_path:
    label: Output trajectory file
    doc: |-
      Output trajectory file
      Type: string
      File type: output
      Accepted formats: trj, crd, mdcrd, x, netcdf, nc
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/reference/sander/sander.x
    type: string
    format:
    - edam:format_3878
    - edam:format_3878
    - edam:format_3878
    - edam:format_3878
    - edam:format_3650
    - edam:format_3650
    inputBinding:
      position: 4
      prefix: --output_traj_path
    default: system.trj

  output_rst_path:
    label: Output restart file
    doc: |-
      Output restart file
      Type: string
      File type: output
      Accepted formats: rst, rst7, netcdf, nc, ncrst
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/reference/sander/sander.rst
    type: string
    format:
    - edam:format_3886
    - edam:format_3886
    - edam:format_3650
    - edam:format_3650
    - edam:format_3886
    inputBinding:
      position: 5
      prefix: --output_rst_path
    default: system.rst

  input_mdin_path:
    label: Input configuration file (MD run options) (AMBER mdin)
    doc: |-
      Input configuration file (MD run options) (AMBER mdin)
      Type: string
      File type: input
      Accepted formats: mdin, in, txt
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/data/sander/npt.mdin
    type: File?
    format:
    - edam:format_2330
    - edam:format_2330
    - edam:format_2330
    inputBinding:
      prefix: --input_mdin_path

  input_cpin_path:
    label: Input constant pH file (AMBER cpin)
    doc: |-
      Input constant pH file (AMBER cpin)
      Type: string
      File type: input
      Accepted formats: cpin
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/data/sander/cln025.cpin
    type: File?
    format:
    - edam:format_2330
    inputBinding:
      prefix: --input_cpin_path

  input_ref_path:
    label: Input reference coordinates for position restraints
    doc: |-
      Input reference coordinates for position restraints
      Type: string
      File type: input
      Accepted formats: rst, rst7, netcdf, nc, ncrst, crd
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/data/sander/sander.rst
    type: File?
    format:
    - edam:format_3886
    - edam:format_3886
    - edam:format_3650
    - edam:format_3650
    - edam:format_3886
    - edam:format_3878
    inputBinding:
      prefix: --input_ref_path

  output_cpout_path:
    label: Output constant pH file (AMBER cpout)
    doc: |-
      Output constant pH file (AMBER cpout)
      Type: string
      File type: output
      Accepted formats: cpout
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/reference/sander/sander.cpout
    type: string
    format:
    - edam:format_2330
    inputBinding:
      prefix: --output_cpout_path
    default: system.cpout

  output_cprst_path:
    label: Output constant pH restart file (AMBER rstout)
    doc: |-
      Output constant pH restart file (AMBER rstout)
      Type: string
      File type: output
      Accepted formats: cprst, rst, rst7
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/reference/sander/sander.cprst
    type: string
    format:
    - edam:format_3886
    - edam:format_3886
    - edam:format_3886
    inputBinding:
      prefix: --output_cprst_path
    default: system.cprst

  output_mdinfo_path:
    label: Output MD info
    doc: |-
      Output MD info
      Type: string
      File type: output
      Accepted formats: mdinfo
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/reference/sander/sander.mdinfo
    type: string
    format:
    - edam:format_2330
    inputBinding:
      prefix: --output_mdinfo_path
    default: system.mdinfo

  config:
    label: Advanced configuration options for biobb_amber SanderMDRun
    doc: |-
      Advanced configuration options for biobb_amber SanderMDRun. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_amber SanderMDRun documentation: https://biobb-amber.readthedocs.io/en/latest/sander.html#module-sander.sander_mdrun
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_log_path:
    label: Output log file
    doc: |-
      Output log file
    type: File
    outputBinding:
      glob: $(inputs.output_log_path)
    format: edam:format_2330

  output_traj_path:
    label: Output trajectory file
    doc: |-
      Output trajectory file
    type: File
    outputBinding:
      glob: $(inputs.output_traj_path)
    format: edam:format_3878

  output_rst_path:
    label: Output restart file
    doc: |-
      Output restart file
    type: File
    outputBinding:
      glob: $(inputs.output_rst_path)
    format: edam:format_3886

  output_cpout_path:
    label: Output constant pH file (AMBER cpout)
    doc: |-
      Output constant pH file (AMBER cpout)
    type: File?
    outputBinding:
      glob: $(inputs.output_cpout_path)
    format: edam:format_2330

  output_cprst_path:
    label: Output constant pH restart file (AMBER rstout)
    doc: |-
      Output constant pH restart file (AMBER rstout)
    type: File?
    outputBinding:
      glob: $(inputs.output_cprst_path)
    format: edam:format_3886

  output_mdinfo_path:
    label: Output MD info
    doc: |-
      Output MD info
    type: File?
    outputBinding:
      glob: $(inputs.output_mdinfo_path)
    format: edam:format_2330

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
