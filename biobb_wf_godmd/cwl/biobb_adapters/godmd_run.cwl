#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the GOdMD tool module.

doc: |-
  Computes conformational transition trajectories for proteins using GOdMD tool.

baseCommand: godmd_run

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

  input_aln_orig_path:
    label: Input GOdMD alignment file corresponding to the origin structure of the
      conformational transition
    doc: |-
      Input GOdMD alignment file corresponding to the origin structure of the conformational transition
      Type: string
      File type: input
      Accepted formats: aln, txt
      Example file: https://github.com/bioexcel/biobb_godmd/raw/master/biobb_godmd/test/data/godmd/1ake_A.aln
    type: File
    format:
    - edam:format_2330
    - edam:format_2330
    inputBinding:
      position: 3
      prefix: --input_aln_orig_path

  input_aln_target_path:
    label: Input GOdMD alignment file corresponding to the target structure of the
      conformational transition
    doc: |-
      Input GOdMD alignment file corresponding to the target structure of the conformational transition
      Type: string
      File type: input
      Accepted formats: aln, txt
      Example file: https://github.com/bioexcel/biobb_godmd/raw/master/biobb_godmd/test/data/godmd/4ake_A.aln
    type: File
    format:
    - edam:format_2330
    - edam:format_2330
    inputBinding:
      position: 4
      prefix: --input_aln_target_path

  output_log_path:
    label: Output log file
    doc: |-
      Output log file
      Type: string
      File type: output
      Accepted formats: log, out, txt, o
      Example file: https://github.com/bioexcel/biobb_godmd/raw/master/biobb_godmd/test/reference/godmd/godmd.log
    type: string
    format:
    - edam:format_2330
    - edam:format_2330
    - edam:format_2330
    - edam:format_2330
    inputBinding:
      position: 5
      prefix: --output_log_path
    default: system.log

  output_ene_path:
    label: Output energy file
    doc: |-
      Output energy file
      Type: string
      File type: output
      Accepted formats: log, out, txt, o
      Example file: https://github.com/bioexcel/biobb_godmd/raw/master/biobb_godmd/test/reference/godmd/godmd_ene.out
    type: string
    format:
    - edam:format_2330
    - edam:format_2330
    - edam:format_2330
    - edam:format_2330
    inputBinding:
      position: 6
      prefix: --output_ene_path
    default: system.log

  output_trj_path:
    label: Output trajectory file
    doc: |-
      Output trajectory file
      Type: string
      File type: output
      Accepted formats: trj, crd, mdcrd, x
      Example file: https://github.com/bioexcel/biobb_godmd/raw/master/biobb_godmd/test/reference/godmd/godmd_trj.mdcrd
    type: string
    format:
    - edam:format_3878
    - edam:format_3878
    - edam:format_3878
    - edam:format_3878
    inputBinding:
      position: 7
      prefix: --output_trj_path
    default: system.trj

  output_pdb_path:
    label: Output structure file
    doc: |-
      Output structure file
      Type: string
      File type: output
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_godmd/raw/master/biobb_godmd/test/reference/godmd/godmd_pdb.pdb
    type: string
    format:
    - edam:format_1476
    inputBinding:
      position: 8
      prefix: --output_pdb_path
    default: system.pdb

  input_config_path:
    label: Input GOdMD configuration file
    doc: |-
      Input GOdMD configuration file
      Type: string
      File type: input
      Accepted formats: in, txt
      Example file: https://github.com/bioexcel/biobb_godmd/raw/master/biobb_godmd/test/data/godmd/params.in
    type: File?
    format:
    - edam:format_2330
    - edam:format_2330
    inputBinding:
      prefix: --input_config_path

  config:
    label: Advanced configuration options for biobb_godmd GOdMDRun
    doc: |-
      Advanced configuration options for biobb_godmd GOdMDRun. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_godmd GOdMDRun documentation: https://biobb-godmd.readthedocs.io/en/latest/godmd.html#module-godmd.godmd_run
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_log_path:
    label: Output log file
    doc: |-
      Output log file
    type: File
    outputBinding:
      glob: $(inputs.output_log_path)
    format: edam:format_2330

  output_ene_path:
    label: Output energy file
    doc: |-
      Output energy file
    type: File
    outputBinding:
      glob: $(inputs.output_ene_path)
    format: edam:format_2330

  output_trj_path:
    label: Output trajectory file
    doc: |-
      Output trajectory file
    type: File
    outputBinding:
      glob: $(inputs.output_trj_path)
    format: edam:format_3878

  output_pdb_path:
    label: Output structure file
    doc: |-
      Output structure file
    type: File
    outputBinding:
      glob: $(inputs.output_pdb_path)
    format: edam:format_1476

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
