#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the LiPyphilic AssignLeaflets module for assigning lipids to leaflets
  in a bilayer.

doc: |-
  LiPyphilic is a Python package for analyzing MD simulations of lipid bilayers. The parameter names and defaults are the same as the ones in the official Lipyphilic documentation.

baseCommand: lpp_assign_leaflets

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
    - edam:format_3878
    - edam:format_2033
    - edam:format_3878
    - edam:format_3816
    - edam:format_1476
    - edam:format_1476
    - edam:format_3881
    - edam:format_3882
    - edam:format_3881
    - edam:format_2333
    - edam:format_2332
    - edam:format_3887
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
    - edam:format_2333
    - edam:format_3878
    - edam:format_3878
    - edam:format_1476
    - edam:format_2033
    - edam:format_3878
    - edam:format_3878
    - edam:format_3816
    - edam:format_3650
    - edam:format_1476
    - edam:format_1476
    - edam:format_3886
    - edam:format_3876
    - edam:format_3910
    - edam:format_3875
    - edam:format_3887
    inputBinding:
      position: 2
      prefix: --input_traj_path

  output_leaflets_path:
    label: Path to the output leaflet assignments
    doc: |-
      Path to the output leaflet assignments
      Type: string
      File type: output
      Accepted formats: csv, npy
      Example file: https://github.com/bioexcel/biobb_mem/raw/main/biobb_mem/test/reference/lipyphilic_biobb/leaflets_data.csv
    type: string
    format:
    - edam:format_3752
    - edam:format_4003
    inputBinding:
      position: 3
      prefix: --output_leaflets_path
    default: system.csv

  config:
    label: Advanced configuration options for biobb_mem LPPAssignLeaflets
    doc: |-
      Advanced configuration options for biobb_mem LPPAssignLeaflets. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_mem LPPAssignLeaflets documentation: https://biobb-mem.readthedocs.io/en/latest/lipyphilic_biobb.html#module-lipyphilic_biobb.lpp_assign_leaflets
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_leaflets_path:
    label: Path to the output leaflet assignments
    doc: |-
      Path to the output leaflet assignments
    type: File
    outputBinding:
      glob: $(inputs.output_leaflets_path)
    format: edam:format_3752

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
