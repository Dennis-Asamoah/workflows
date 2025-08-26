cwlVersion: v1.0
class: CommandLineTool

hints:
  RemoteLocationRequirement:
    nodeUri: $(inputs.nodeId)

inputs:
  nodeId:
    type: string

outputs:
  date1:
    type: File
    outputBinding:
      glob: first_date.txt

baseCommand: python
arguments:
  - "-c"
  - "from datetime import datetime, timezone; print(datetime.now(tz=timezone.utc).isoformat())"
stdout: first_date.txt
