cwlVersion: v1.0
class: CommandLineTool

hints:
  RemoteLocationRequirement:
    nodeUri: $(inputs.nodeId)

inputs:
  nodeId:
    type: string
  date:
    type: File
    inputBinding:
      position: 1
outputs:
  printed:
    type: stdout

baseCommand: cat
stdout: printed.txt


