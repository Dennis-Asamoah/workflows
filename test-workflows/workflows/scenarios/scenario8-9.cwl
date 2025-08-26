class: CommandLineTool
cwlVersion: v1.0

doc: Asking for the execution date to a specific node

hints:
  - class: RemoteLocationRequirement
    nodeUri: $(inputs.nodeId)

inputs:
  nodeId:
    type: string
    default: central-node.org

outputs:
  printed:
    type: stdout

baseCommand: date
stdout: printed.txt