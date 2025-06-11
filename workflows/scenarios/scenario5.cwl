cwlVersion: v1.0
class: CommandLineTool

doc: Extension of scenario 4, the message to be displayed in remote node is provided as input

inputs:
  dataset:
    type: File
  message:
    type: string
    inputBinding:
      position: 1

outputs: []

baseCommand: echo
