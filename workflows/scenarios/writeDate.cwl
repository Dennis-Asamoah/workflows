cwlVersion: v1.2
class: CommandLineTool

requirements:
  WorkReuse:
    enableReuse: false

hints:
  RemoteLocationRequirement:
    nodeUri: $(inputs.nodeId)

inputs:
  nodeId:
    type: string
    default: http://tesk-api:8080/ga4gh/tes/

outputs:
  dateOutput:
    type: stdout
stdout: date.txt

baseCommand: python
arguments:
  - "-c"
  - "from datetime import datetime, timezone; print(datetime.now(tz=timezone.utc).isoformat())"
