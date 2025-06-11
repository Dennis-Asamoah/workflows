cwlVersion: v1.0
class: CommandLineTool

doc: Extension of scenarios 4 & 5. The printed message is now stored as output and should be available

inputs:
  dataset:
    type: File
  message:
    type: string
    inputBinding:
      position: 1

outputs:
  printed:
    type: stdout

baseCommand: echo
stdout: printed.txt