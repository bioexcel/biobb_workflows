#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Helper bb to prepare inputs for the GOdMD tool module.

doc: |-
  Prepares input files for the GOdMD tool.

baseCommand: godmd_prep

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_godmd:4.1.0--pyhdfd78af_0

inputs:
  input_pdb_orig_path:
    label: Input PDB file to be used as origin in the conformational transition
    doc: |-
      Input PDB file to be used as origin in the conformational transition
      Type: string
      File type: input
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_godmd/raw/master/biobb_godmd/test/data/godmd/1ake_A.pdb
    type: File
    format:
    - edam:format_1476
    inputBinding:
      position: 1
      prefix: --input_pdb_orig_path

  input_pdb_target_path:
    label: Input PDB file to be used as target in the conformational transition
    doc: |-
      Input PDB file to be used as target in the conformational transition
      Type: string
      File type: input
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_godmd/raw/master/biobb_godmd/test/data/godmd/4ake_A.pdb
    type: File
    format:
    - edam:format_1476
    inputBinding:
      position: 2
      prefix: --input_pdb_target_path

  output_aln_orig_path:
    label: Output GOdMD alignment file corresponding to the origin structure of the
      conformational transition
    doc: |-
      Output GOdMD alignment file corresponding to the origin structure of the conformational transition
      Type: string
      File type: output
      Accepted formats: aln, txt
      Example file: https://github.com/bioexcel/biobb_godmd/raw/master/biobb_godmd/test/data/godmd/1ake_A.aln
    type: string
    format:
    - edam:format_2330
    - edam:format_2330
    inputBinding:
      position: 3
      prefix: --output_aln_orig_path
    default: system.aln

  output_aln_target_path:
    label: Output GOdMD alignment file corresponding to the target structure of the
      conformational transition
    doc: |-
      Output GOdMD alignment file corresponding to the target structure of the conformational transition
      Type: string
      File type: output
      Accepted formats: aln, txt
      Example file: https://github.com/bioexcel/biobb_godmd/raw/master/biobb_godmd/test/data/godmd/4ake_A.aln
    type: string
    format:
    - edam:format_2330
    - edam:format_2330
    inputBinding:
      position: 4
      prefix: --output_aln_target_path
    default: system.aln

  config:
    label: Advanced configuration options for biobb_godmd GOdMDPrep
    doc: |-
      Advanced configuration options for biobb_godmd GOdMDPrep. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_godmd GOdMDPrep documentation: https://biobb-godmd.readthedocs.io/en/latest/godmd.html#module-godmd.godmd_prep
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_aln_orig_path:
    label: Output GOdMD alignment file corresponding to the origin structure of the
      conformational transition
    doc: |-
      Output GOdMD alignment file corresponding to the origin structure of the conformational transition
    type: File
    outputBinding:
      glob: $(inputs.output_aln_orig_path)
    format: edam:format_2330

  output_aln_target_path:
    label: Output GOdMD alignment file corresponding to the target structure of the
      conformational transition
    doc: |-
      Output GOdMD alignment file corresponding to the target structure of the conformational transition
    type: File
    outputBinding:
      glob: $(inputs.output_aln_target_path)
    format: edam:format_2330

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
