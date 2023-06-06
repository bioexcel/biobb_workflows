#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the AutoDock Vina software.

doc: |-
  This class performs docking of the ligand to a set of grids describing the target protein via the AutoDock Vina software.

baseCommand: autodock_vina_run

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_vs:4.0.0--pyhdfd78af_2

inputs:
  input_ligand_pdbqt_path:
    label: Path to the input PDBQT ligand
    doc: |-
      Path to the input PDBQT ligand
      Type: string
      File type: input
      Accepted formats: pdbqt
      Example file: https://github.com/bioexcel/biobb_vs/raw/master/biobb_vs/test/data/vina/vina_ligand.pdbqt
    type: File
    format:
    - edam:format_1476
    inputBinding:
      position: 1
      prefix: --input_ligand_pdbqt_path

  input_receptor_pdbqt_path:
    label: Path to the input PDBQT receptor
    doc: |-
      Path to the input PDBQT receptor
      Type: string
      File type: input
      Accepted formats: pdbqt
      Example file: https://github.com/bioexcel/biobb_vs/raw/master/biobb_vs/test/data/vina/vina_receptor.pdbqt
    type: File
    format:
    - edam:format_1476
    inputBinding:
      position: 2
      prefix: --input_receptor_pdbqt_path

  input_box_path:
    label: Path to the PDB containig the residues belonging to the binding site
    doc: |-
      Path to the PDB containig the residues belonging to the binding site
      Type: string
      File type: input
      Accepted formats: pdb
      Example file: https://github.com/bioexcel/biobb_vs/raw/master/biobb_vs/test/data/vina/vina_box.pdb
    type: File
    format:
    - edam:format_1476
    inputBinding:
      position: 3
      prefix: --input_box_path

  output_pdbqt_path:
    label: Path to the output PDBQT file
    doc: |-
      Path to the output PDBQT file
      Type: string
      File type: output
      Accepted formats: pdbqt
      Example file: https://github.com/bioexcel/biobb_vs/raw/master/biobb_vs/test/reference/vina/ref_output_vina.pdbqt
    type: string
    format:
    - edam:format_1476
    inputBinding:
      position: 4
      prefix: --output_pdbqt_path
    default: system.pdbqt

  output_log_path:
    label: Path to the log file
    doc: |-
      Path to the log file
      Type: string
      File type: output
      Accepted formats: log
      Example file: https://github.com/bioexcel/biobb_vs/raw/master/biobb_vs/test/reference/vina/ref_output_vina.log
    type: string
    format:
    - edam:format_2330
    inputBinding:
      prefix: --output_log_path
    default: system.log

  config:
    label: Advanced configuration options for biobb_vs AutoDockVinaRun
    doc: |-
      Advanced configuration options for biobb_vs AutoDockVinaRun. This should be passed as a string containing a dict. The possible options to include here are listed under 'properties' in the biobb_vs AutoDockVinaRun documentation: https://biobb-vs.readthedocs.io/en/latest/vina.html#module-vina.autodock_vina_run
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_pdbqt_path:
    label: Path to the output PDBQT file
    doc: |-
      Path to the output PDBQT file
    type: File
    outputBinding:
      glob: $(inputs.output_pdbqt_path)
    format: edam:format_1476

  output_log_path:
    label: Path to the log file
    doc: |-
      Path to the log file
    type: File?
    outputBinding:
      glob: $(inputs.output_log_path)
    format: edam:format_2330

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
