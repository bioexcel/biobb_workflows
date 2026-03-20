#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Converts a .pt file (features) to a trajectory using cartesian indices and
  topology from the stats file.

doc: |-
  Converts a .pt file (features) to a trajectory using cartesian indices and topology from the stats file.

baseCommand: feat2traj

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_pytorch:5.2.2--pyhad2cae4_0

inputs:
  input_results_npz_path:
    label: Path to the input reconstructed results file (.npz), typically containing
      an 'xhat' array
    doc: |-
      Path to the input reconstructed results file (.npz), typically containing an 'xhat' array
      Type: string
      File type: input
      Accepted formats: npz
      Example file: https://github.com/bioexcel/biobb_pytorch/raw/master/biobb_pytorch/test/reference/mdae/ref_input_results.npz
    type: File
    format:
    - edam:format_2333
    inputBinding:
      position: 1
      prefix: --input_results_npz_path

  input_stats_pt_path:
    label: Path to the input model statistics file (.pt) containing cartesian indices
      and optionally topology
    doc: |-
      Path to the input model statistics file (.pt) containing cartesian indices and optionally topology
      Type: string
      File type: input
      Accepted formats: pt
      Example file: https://github.com/bioexcel/biobb_pytorch/raw/master/biobb_pytorch/test/reference/mdae/ref_input_model.pt
    type: File
    format:
    - edam:format_2333
    inputBinding:
      position: 2
      prefix: --input_stats_pt_path

  output_traj_path:
    label: Path to save the trajectory in xtc/pdb/dcd format
    doc: |-
      Path to save the trajectory in xtc/pdb/dcd format
      Type: string
      File type: output
      Accepted formats: xtc, pdb, dcd
      Example file: https://github.com/bioexcel/biobb_pytorch/raw/master/biobb_pytorch/test/reference/mdae/output_model.xtc
    type: string
    format:
    - edam:format_3875
    - edam:format_1476
    - edam:format_3878
    inputBinding:
      position: 3
      prefix: --output_traj_path
    default: system.xtc

  input_topology_path:
    label: Path to the topology file (PDB) used if no suitable topology is found in
      the stats file. Used if no topology is found in stats
    doc: |-
      Path to the topology file (PDB) used if no suitable topology is found in the stats file. Used if no topology is found in stats
      Type: string
      File type: input
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_pytorch/mdae/ref_input_topology.pdb
    type: File?
    format:
    - edam:format_1476
    inputBinding:
      prefix: --input_topology_path

  output_top_path:
    label: Path to save the output topology file (pdb). Used if trajectory format
      requires separate topology
    doc: |-
      Path to save the output topology file (pdb). Used if trajectory format requires separate topology
      Type: string
      File type: output
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_pytorch/mdae/output_model.pdb
    type: string
    format:
    - edam:format_1476
    inputBinding:
      prefix: --output_top_path
    default: system.pdb

  config:
    label: Advanced configuration options for biobb_pytorch Feat2Traj
    doc: |-
      Advanced configuration options for biobb_pytorch Feat2Traj. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_pytorch Feat2Traj documentation: https://biobb-pytorch.readthedocs.io/en/latest/mdae.html#module-biobb_pytorch.mdae.feat2traj
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_traj_path:
    label: Path to save the trajectory in xtc/pdb/dcd format
    doc: |-
      Path to save the trajectory in xtc/pdb/dcd format
    type: File
    outputBinding:
      glob: $(inputs.output_traj_path)
    format: edam:format_3875

  output_top_path:
    label: Path to save the output topology file (pdb). Used if trajectory format
      requires separate topology
    doc: |-
      Path to save the output topology file (pdb). Used if trajectory format requires separate topology
    type: File?
    outputBinding:
      glob: $(inputs.output_top_path)
    format: edam:format_1476

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
