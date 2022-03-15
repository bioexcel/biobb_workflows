#!/usr/bin/env cwl-runner

cwlVersion: v1.1
class: ExpressionTool

doc: |-
  This javascript takes two inputs: a list of files and a string. 
  It will create a directory named after the string, populate that 
  directory with the files in the list, and return the directory.
requirements:
  InlineJavascriptRequirement: {}
inputs:
  output_folder: string
  external_files: File[]
outputs:
  project_work_dir:     
    label: Output archive directory
    doc: |
      workflow output directory, containing required output files
    type: Directory
expression: |
  ${
    var myRegexp = new RegExp('{"mutation_list":"(.*)"}', "g");
    var match = myRegexp.exec(inputs.output_folder);
    return {
        "project_work_dir": {
            "class": "Directory",  
            "basename": match[1], 
            "listing": inputs.external_files
        }
    };
  }
