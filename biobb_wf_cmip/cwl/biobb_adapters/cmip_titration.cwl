#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper class for the CMIP titration module.

doc: |-
  The CMIP titration module. CMIP titration module adds water molecules, positive ions (Na+) and negative ions (Cl-) in the energetically most favorable structure locations.

baseCommand: cmip_titration

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_cmip:4.1.1--pyhdfd78af_0

inputs:
  input_pdb_path:
    label: Path to the input PDB file
    doc: |-
      Path to the input PDB file
      Type: string
      File type: input
      Accepted formats: pdb
      Example file: https://raw.githubusercontent.com/bioexcel/biobb_cmip/master/biobb_cmip/test/data/cmip/1kim_h.pdb
    type: File
    format:
    - edam:format_1476
    inputBinding:
      position: 1
      prefix: --input_pdb_path

  output_pdb_path:
    label: Path to the output PDB file
    doc: |-
      Path to the output PDB file
      Type: string
      File type: output
      Accepted formats: pdb
      Example file: https://raw.githubusercontent.com/bioexcel/biobb_cmip/master/biobb_cmip/test/reference/cmip/1kim_neutral.pdb
    type: string
    format:
    - edam:format_1476
    inputBinding:
      position: 2
      prefix: --output_pdb_path
    default: system.pdb

  input_vdw_params_path:
    label: Path to the CMIP input Van der Waals force parameters, if not provided
      the CMIP conda installation one is used ("$CONDA_PREFIX/share/cmip/dat/vdwprm")
    doc: |-
      Path to the CMIP input Van der Waals force parameters, if not provided the CMIP conda installation one is used ("$CONDA_PREFIX/share/cmip/dat/vdwprm")
      Type: string
      File type: input
      Accepted formats: txt
      Example file: null
    type: File?
    format:
    - edam:format_2330
    inputBinding:
      prefix: --input_vdw_params_path

  input_params_path:
    label: Path to the CMIP input parameters file
    doc: |-
      Path to the CMIP input parameters file
      Type: string
      File type: input
      Accepted formats: txt
      Example file: null
    type: File?
    format:
    - edam:format_2330
    inputBinding:
      prefix: --input_params_path

  config:
    label: Advanced configuration options for biobb_cmip Titration
    doc: |-
      Advanced configuration options for biobb_cmip Titration. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_cmip Titration documentation: https://biobb-cmip.readthedocs.io/en/latest/cmip.html#module-cmip.cmip_titration
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_pdb_path:
    label: Path to the output PDB file
    doc: |-
      Path to the output PDB file
    type: File
    outputBinding:
      glob: $(inputs.output_pdb_path)
    format: edam:format_1476

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
