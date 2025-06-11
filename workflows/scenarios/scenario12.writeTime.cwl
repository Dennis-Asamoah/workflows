cwlVersion: v1.0
class: CommandLineTool

inputs:
  timedelta:
    type: File
    inputBinding:
      position: 1

outputs:
  printed:
    type: stdout

stdout: printed.txt
baseCommand: cat
