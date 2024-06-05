#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the GROMACS genrestr module.

doc: |-
  The GROMACS genrestr module, produces an #include file for a topology containing a list of atom numbers and three force constants for the x-, y-, and z-direction based on the contents of the -f file. A single isotropic force constant may be given on the command line instead of three components.

baseCommand: genrestr

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_gromacs:4.1.1--pyhdfd78af_0

inputs:
  input_structure_path:
    label: Path to the input structure PDB, GRO or TPR format
    doc: |-
      Path to the input structure PDB, GRO or TPR format
      Type: string
      File type: input
      Accepted formats: pdb, gro, tpr
      Example file: https://github.com/bioexcel/biobb_gromacs/raw/master/biobb_gromacs/test/data/gromacs/genrestr.gro
    type: File
    format:
    - edam:format_1476
    - edam:format_2033
    - edam:format_2333
    inputBinding:
      position: 1
      prefix: --input_structure_path

  output_itp_path:
    label: Path the output ITP topology file with restrains
    doc: |-
      Path the output ITP topology file with restrains
      Type: string
      File type: output
      Accepted formats: itp
      Example file: https://github.com/bioexcel/biobb_gromacs/raw/master/biobb_gromacs/test/reference/gromacs/ref_genrestr.itp
    type: string
    format:
    - edam:format_3883
    inputBinding:
      position: 2
      prefix: --output_itp_path
    default: system.itp

  input_ndx_path:
    label: Path to the input GROMACS index file, NDX format
    doc: |-
      Path to the input GROMACS index file, NDX format
      Type: string
      File type: input
      Accepted formats: ndx
      Example file: https://github.com/bioexcel/biobb_gromacs/raw/master/biobb_gromacs/test/data/gromacs/genrestr.ndx
    type: File?
    format:
    - edam:format_2033
    inputBinding:
      prefix: --input_ndx_path

  config:
    label: Advanced configuration options for biobb_gromacs Genrestr
    doc: |-
      Advanced configuration options for biobb_gromacs Genrestr. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_gromacs Genrestr documentation: https://biobb-gromacs.readthedocs.io/en/latest/gromacs.html#module-gromacs.genrestr
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_itp_path:
    label: Path the output ITP topology file with restrains
    doc: |-
      Path the output ITP topology file with restrains
    type: File
    outputBinding:
      glob: $(inputs.output_itp_path)
    format: edam:format_3883

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
