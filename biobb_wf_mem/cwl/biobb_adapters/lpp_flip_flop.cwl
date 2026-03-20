#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the LiPyphilic FlipFlop module for finding flip-flop events in a
  lipid bilayer.

doc: |-
  LiPyphilic is a Python package for analyzing MD simulations of lipid bilayers. The parameter names and defaults are the same as the ones in the official Lipyphilic documentation.

baseCommand: lpp_flip_flop

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

  input_leaflets_path:
    label: Path to the input leaflet assignments
    doc: |-
      Path to the input leaflet assignments
      Type: string
      File type: input
      Accepted formats: csv, npy
      Example file: https://github.com/bioexcel/biobb_mem/raw/main/biobb_mem/test/reference/lipyphilic_biobb/leaflets_data.csv
    type: File
    format:
    - edam:format_3752
    - edam:format_4003
    inputBinding:
      position: 3
      prefix: --input_leaflets_path

  output_flip_flop_path:
    label: Path to the output flip-flop data
    doc: |-
      Path to the output flip-flop data
      Type: string
      File type: output
      Accepted formats: csv
      Example file: https://github.com/bioexcel/biobb_mem/raw/main/biobb_mem/test/reference/lipyphilic_biobb/flip_flop.csv
    type: string
    format:
    - edam:format_3752
    inputBinding:
      position: 4
      prefix: --output_flip_flop_path
    default: system.csv

  config:
    label: Advanced configuration options for biobb_mem LPPFlipFlop
    doc: |-
      Advanced configuration options for biobb_mem LPPFlipFlop. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_mem LPPFlipFlop documentation: https://biobb-mem.readthedocs.io/en/latest/lipyphilic_biobb.html#module-lipyphilic_biobb.lpp_flip_flop
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_flip_flop_path:
    label: Path to the output flip-flop data
    doc: |-
      Path to the output flip-flop data
    type: File
    outputBinding:
      glob: $(inputs.output_flip_flop_path)
    format: edam:format_3752

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
