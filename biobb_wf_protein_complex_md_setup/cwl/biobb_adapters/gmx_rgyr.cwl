#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the GROMACS gyrate module for computing the radius of gyration (Rgyr)
  of a molecule about the x-, y- and z-axes, as a function of time, from a given GROMACS

  compatible trajectory.

doc: |-
  GROMACS gyrate computes the radius of gyration of a molecule and the radii of gyration about the x-, y- and z-axes, as a function of time. The atoms are explicitly mass weighted.

baseCommand: gmx_rgyr

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
      Example file: https://github.com/bioexcel/biobb_analysis/raw/master/biobb_analysis/test/reference/gromacs/ref_rgyr.xvg
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
    label: Advanced configuration options for biobb_analysis GMXRgyr
    doc: |-
      Advanced configuration options for biobb_analysis GMXRgyr. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_analysis GMXRgyr documentation: https://biobb-analysis.readthedocs.io/en/latest/gromacs.html#module-gromacs.gmx_rgyr
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
