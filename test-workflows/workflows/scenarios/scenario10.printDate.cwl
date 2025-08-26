class: CommandLineTool
cwlVersion: v1.0

baseCommand: cat
stdout: printed.txt

inputs:
  date:
    type: File
    inputBinding:
      position: 1

outputs:
  printed:
    type: stdout
