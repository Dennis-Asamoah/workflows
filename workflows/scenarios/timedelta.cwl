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
  dateInput:
    type: File
    inputBinding:
      position: 2

outputs:
  timedelta:
    type: stdout
baseCommand: python
arguments:
  - "-c"
  - "from datetime import datetime, timezone; import sys;old=datetime.fromisoformat(open(sys.argv[1]).read().rstrip());now=datetime.now(tz=timezone.utc);print((now-old).total_seconds())"

stdout: timedelta1.txt
