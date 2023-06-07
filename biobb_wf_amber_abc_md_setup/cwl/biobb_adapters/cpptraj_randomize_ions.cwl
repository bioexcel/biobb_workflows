#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the AmberTools (AMBER MD Package) cpptraj tool module.

doc: |-
  Swap specified ions with randomly selected solvent molecules using cpptraj tool from the AmberTools MD package.

baseCommand: cpptraj_randomize_ions

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
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/data/cpptraj/structure.ions.parmtop
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
      Accepted formats: crd, mdcrd, inpcrd
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/data/cpptraj/structure.ions.crd
    type: File
    format:
    - edam:format_3878
    - edam:format_3878
    - edam:format_3878
    inputBinding:
      position: 2
      prefix: --input_crd_path

  output_pdb_path:
    label: Structure PDB file with randomized ions
    doc: |-
      Structure PDB file with randomized ions
      Type: string
      File type: output
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/reference/cpptraj/structure.randIons.pdb
    type: string
    format:
    - edam:format_1476
    inputBinding:
      position: 3
      prefix: --output_pdb_path
    default: system.pdb

  output_crd_path:
    label: Structure CRD file with coordinates including randomized ions
    doc: |-
      Structure CRD file with coordinates including randomized ions
      Type: string
      File type: output
      Accepted formats: crd, mdcrd, inpcrd
      Example file: https://github.com/bioexcel/biobb_amber/raw/master/biobb_amber/test/reference/cpptraj/structure.randIons.crd
    type: string
    format:
    - edam:format_3878
    - edam:format_3878
    - edam:format_3878
    inputBinding:
      position: 4
      prefix: --output_crd_path
    default: system.crd

  config:
    label: Advanced configuration options for biobb_amber.cpptraj.cpptraj_randomize_ions
      CpptrajRandomizeIons
    doc: |-
      Advanced configuration options for biobb_amber.cpptraj.cpptraj_randomize_ions CpptrajRandomizeIons. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_amber.cpptraj.cpptraj_randomize_ions CpptrajRandomizeIons documentation: https://biobb-amber.readthedocs.io/en/latest/cpptraj.html#module-cpptraj.cpptraj_randomize_ions
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_pdb_path:
    label: Structure PDB file with randomized ions
    doc: |-
      Structure PDB file with randomized ions
    type: File
    outputBinding:
      glob: $(inputs.output_pdb_path)
    format: edam:format_1476

  output_crd_path:
    label: Structure CRD file with coordinates including randomized ions
    doc: |-
      Structure CRD file with coordinates including randomized ions
    type: File
    outputBinding:
      glob: $(inputs.output_crd_path)
    format: edam:format_3878

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
