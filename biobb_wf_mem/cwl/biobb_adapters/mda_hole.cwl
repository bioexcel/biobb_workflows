#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the MDAnalysis HOLE module for analyzing ion channel pores or transporter
  pathways.

doc: |-
  MDAnalysis HOLE provides an interface to the HOLE suite of tools to analyze pore dimensions and properties along a channel or transporter pathway. The parameter names and defaults follow the MDAnalysis HOLE  implementation.

baseCommand: mda_hole

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

  output_hole_path:
    label: Path to the output HOLE analysis results
    doc: |-
      Path to the output HOLE analysis results
      Type: string
      File type: output
      Accepted formats: vmd
      Example file: https://github.com/bioexcel/biobb_mem/raw/main/biobb_mem/test/reference/mdanalysis_biobb/hole.vmd
    type: string
    format:
    - edam:format_2330
    inputBinding:
      position: 3
      prefix: --output_hole_path
    default: system.vmd

  output_csv_path:
    label: Path to the output CSV file containing the radius and coordinates of the
      pore
    doc: |-
      Path to the output CSV file containing the radius and coordinates of the pore
      Type: string
      File type: output
      Accepted formats: csv
      Example file: https://github.com/bioexcel/biobb_mem/raw/main/biobb_mem/test/reference/mdanalysis_biobb/hole_profile.csv
    type: string
    format:
    - edam:format_3752
    inputBinding:
      position: 4
      prefix: --output_csv_path
    default: system.csv

  config:
    label: Advanced configuration options for biobb_mem MDAHole
    doc: |-
      Advanced configuration options for biobb_mem MDAHole. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_mem MDAHole documentation: https://biobb-mem.readthedocs.io/en/latest/mdanalysis_biobb.html#module-mdanalysis_biobb.mda_hole
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_hole_path:
    label: Path to the output HOLE analysis results
    doc: |-
      Path to the output HOLE analysis results
    type: File
    outputBinding:
      glob: $(inputs.output_hole_path)
    format: edam:format_2330

  output_csv_path:
    label: Path to the output CSV file containing the radius and coordinates of the
      pore
    doc: |-
      Path to the output CSV file containing the radius and coordinates of the pore
    type: File
    outputBinding:
      glob: $(inputs.output_csv_path)
    format: edam:format_3752

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
