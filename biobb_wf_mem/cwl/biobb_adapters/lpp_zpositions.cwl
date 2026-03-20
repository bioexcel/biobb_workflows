#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the LiPyphilic ZPositions module for calculating the z distance
  of lipids to the bilayer center.

doc: |-
  LiPyphilic is a Python package for analyzing MD simulations of lipid bilayers. The parameter names and defaults are the same as the ones in the official Lipyphilic documentation.

baseCommand: lpp_zpositions

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_mem:5.2.2--pyhdfd78af_0

inputs:
  input_top_path:
    label: Path to the input structure or topology file
    doc: |-
      Path to the input structure or topology file
      Type: string
      File type: input
      Accepted formats: crd, gro, mdcrd, mol2, pdb, pdbqt, prmtop, psf, top, tpr, xml, xyz
      Example file: https://github.com/bioexcel/biobb_mem/raw/main/biobb_mem/test/data/A01JD/A01JD.pdb
    type: File
    format:
    - edam:3878
    - edam:2033
    - edam:3878
    - edam:3816
    - edam:1476
    - edam:1476
    - edam:3881
    - edam:3882
    - edam:3881
    - edam:2333
    - edam:2332
    - edam:3887
    inputBinding:
      position: 1
      prefix: --input_top_path

  input_traj_path:
    label: Path to the input trajectory to be processed
    doc: |-
      Path to the input trajectory to be processed
      Type: string
      File type: input
      Accepted formats: arc, crd, dcd, ent, gro, inpcrd, mdcrd, mol2, nc, pdb, pdbqt, restrt, tng, trr, xtc, xyz
      Example file: https://github.com/bioexcel/biobb_mem/raw/main/biobb_mem/test/data/A01JD/A01JD.xtc
    type: File
    format:
    - edam:2333
    - edam:3878
    - edam:3878
    - edam:1476
    - edam:2033
    - edam:3878
    - edam:3878
    - edam:3816
    - edam:3650
    - edam:1476
    - edam:1476
    - edam:3886
    - edam:3876
    - edam:3910
    - edam:3875
    - edam:3887
    inputBinding:
      position: 2
      prefix: --input_traj_path

  output_positions_path:
    label: Path to the output z positions
    doc: |-
      Path to the output z positions
      Type: string
      File type: output
      Accepted formats: csv
      Example file: https://github.com/bioexcel/biobb_mem/raw/main/biobb_mem/test/reference/lipyphilic_biobb/zpositions.csv
    type: string
    format:
    - edam:format_3752
    inputBinding:
      position: 3
      prefix: --output_positions_path
    default: system.csv

  config:
    label: Advanced configuration options for biobb_mem LPPZPositions
    doc: |-
      Advanced configuration options for biobb_mem LPPZPositions. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_mem LPPZPositions documentation: https://biobb-mem.readthedocs.io/en/latest/lipyphilic_biobb.html#module-lipyphilic_biobb.lpp_zpositions
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_positions_path:
    label: Path to the output z positions
    doc: |-
      Path to the output z positions
    type: File
    outputBinding:
      glob: $(inputs.output_positions_path)
    format: edam:format_3752

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
