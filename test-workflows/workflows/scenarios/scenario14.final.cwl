cwlVersion: v1.2
class: CommandLineTool
inputs:
  timedelta:
    type: File
    inputBinding:
      position: 1
outputs:
  printed:
    type: stdout
stdout: final-timedelta.txt
baseCommand: cat