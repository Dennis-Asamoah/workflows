cwlVersion: v1.0
class: CommandLineTool

doc: Extension of scenarios 1 & 2, where the printed message now is picked up and saved as an output

inputs:
  message:
    type: string
    inputBinding:
      position: 1

outputs:
  printed:
    type: stdout

baseCommand: echo
stdout: printed.txt