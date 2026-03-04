#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the GROMACS rms module for performing a Root Mean Square deviation
  (RMSd) analysis from a given GROMACS compatible trajectory.

doc: |-
  GROMACS rms compares two structures by computing the root mean square deviation (RMSD), the size-independent rho similarity parameter (rho) or the scaled rho (rhosc).

baseCommand: gmx_rms

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_analysis:4.1.0--pyhdfd78af_0

inputs:
  input_structure_path:
    label: Path to the input structure file
    doc: |-
      Path to the input structure file
      Type: string
      File type: input
      Accepted formats: tpr, gro, g96, pdb, brk, ent
      Example file: https://github.com/bioexcel/biobb_analysis/raw/master/biobb_analysis/test/data/gromacs/topology.tpr
    type: File
    format:
    - edam:format_2333
    - edam:format_2033
    - edam:format_2033
    - edam:format_1476
    - edam:format_2033
    - edam:format_1476
    inputBinding:
      position: 1
      prefix: --input_structure_path

  input_traj_path:
    label: Path to the GROMACS trajectory file
    doc: |-
      Path to the GROMACS trajectory file
      Type: string
      File type: input
      Accepted formats: xtc, trr, cpt, gro, g96, pdb, tng
      Example file: https://github.com/bioexcel/biobb_analysis/raw/master/biobb_analysis/test/data/gromacs/trajectory.trr
    type: File
    format:
    - edam:format_3875
    - edam:format_3910
    - edam:format_2333
    - edam:format_2033
    - edam:format_2033
    - edam:format_1476
    - edam:format_3876
    inputBinding:
      position: 2
      prefix: --input_traj_path

  output_xvg_path:
    label: Path to the XVG output file
    doc: |-
      Path to the XVG output file
      Type: string
      File type: output
      Accepted formats: xvg
      Example file: https://github.com/bioexcel/biobb_analysis/raw/master/biobb_analysis/test/reference/gromacs/ref_rms.xvg
    type: string
    format:
    - edam:format_2030
    inputBinding:
      position: 3
      prefix: --output_xvg_path
    default: system.xvg

  input_index_path:
    label: Path to the GROMACS index file
    doc: |-
      Path to the GROMACS index file
      Type: string
      File type: input
      Accepted formats: ndx
      Example file: https://github.com/bioexcel/biobb_analysis/raw/master/biobb_analysis/test/data/gromacs/index.ndx
    type: File?
    format:
    - edam:format_2033
    inputBinding:
      prefix: --input_index_path

  config:
    label: Advanced configuration options for biobb_analysis GMXRms
    doc: |-
      Advanced configuration options for biobb_analysis GMXRms. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_analysis GMXRms documentation: https://biobb-analysis.readthedocs.io/en/latest/gromacs.html#module-gromacs.gmx_rms
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
