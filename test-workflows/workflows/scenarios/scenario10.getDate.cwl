class: CommandLineTool
cwlVersion: v1.0

hints:
  RemoteLocationRequirement:
    nodeUri: $(inputs.nodeId)

baseCommand: date
inputs:
  nodeId:
    type: string
stdout: tmp.txt
outputs:
  output_central:
    type: stdout
