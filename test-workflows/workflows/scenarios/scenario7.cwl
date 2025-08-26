class: CommandLineTool
cwlVersion: v1.0

doc: Extension of scenario 3, where the task is executed in a node explicitly given in the inputs

hints:
  RemoteLocationRequirement:
    nodeUri: $(inputs.nodeId)

inputs:
  nodeId:
    type: string

  message:
    type: string
    inputBinding:
      position: 1

outputs:
  printed:
    type: stdout

baseCommand: echo
stdout: printed.txt