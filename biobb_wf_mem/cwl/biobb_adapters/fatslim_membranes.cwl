#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the FATSLiM membranes module for leaflet and membrane identification.

doc: |-
  FATSLiM is designed to provide efficient and robust analysis of physical parameters from MD trajectories, with a focus on processing large trajectory files quickly.

baseCommand: fatslim_membranes

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_mem:5.2.2--pyhdfd78af_0

inputs:
  input_top_path:
    label: Path to the input topology file
    doc: |-
      Path to the input topology file
      Type: string
      File type: input
      Accepted formats: tpr, gro, g96, pdb, brk, ent
      Example file: https://github.com/bioexcel/biobb_mem/raw/main/biobb_mem/test/data/A01JD/A01JD.pdb
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
      prefix: --input_top_path

  output_ndx_path:
    label: Path to the output index NDX file
    doc: |-
      Path to the output index NDX file
      Type: string
      File type: output
      Accepted formats: ndx
      Example file: https://github.com/bioexcel/biobb_mem/raw/main/biobb_mem/test/reference/fatslim/leaflets.ndx
    type: string
    format:
    - edam:format_2033
    inputBinding:
      position: 2
      prefix: --output_ndx_path
    default: system.ndx

  input_traj_path:
    label: Path to the GROMACS trajectory file
    doc: |-
      Path to the GROMACS trajectory file
      Type: string
      File type: input
      Accepted formats: xtc, trr, cpt, gro, g96, pdb, tng
      Example file: https://github.com/bioexcel/biobb_mem/raw/main/biobb_mem/test/data/A01JD/A01JD.xtc
    type: File?
    format:
    - edam:format_3875
    - edam:format_3910
    - edam:format_2333
    - edam:format_2033
    - edam:format_2033
    - edam:format_1476
    - edam:format_3876
    inputBinding:
      prefix: --input_traj_path

  input_ndx_path:
    label: Path to the input lipid headgroups index NDX file
    doc: |-
      Path to the input lipid headgroups index NDX file
      Type: string
      File type: input
      Accepted formats: ndx
      Example file: https://github.com/bioexcel/biobb_mem/raw/main/biobb_mem/test/data/A01JD/A01JD.ndx
    type: File?
    format:
    - edam:format_2033
    inputBinding:
      prefix: --input_ndx_path

  config:
    label: Advanced configuration options for biobb_mem FatslimMembranes
    doc: |-
      Advanced configuration options for biobb_mem FatslimMembranes. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_mem FatslimMembranes documentation: https://biobb-mem.readthedocs.io/en/latest/fatslim.html#module-fatslim.fatslim_membranes
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_ndx_path:
    label: Path to the output index NDX file
    doc: |-
      Path to the output index NDX file
    type: File
    outputBinding:
      glob: $(inputs.output_ndx_path)
    format: edam:format_2033

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
