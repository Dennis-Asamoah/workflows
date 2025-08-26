cwlVersion: v1.0
class: CommandLineTool

doc: Extension of scenario 1 to check that simple inputs are correctly processed

inputs:
  message:
    type: string
    inputBinding:
      position: 1
outputs: []

baseCommand: echo