cwlVersion: v1.0
class: CommandLineTool

hints:
  RemoteLocationRequirement:
    nodeUri: $(inputs.nodeId)

inputs:
  nodeId:
    type: string
  date1:
    type: File
    inputBinding:
      position: 2
outputs:
  timedelta:
    type: stdout

stdout: timedelta.txt
baseCommand: python
arguments:
  - "-c"
  - "from datetime import datetime, timezone; import sys;old=datetime.fromisoformat(open(sys.argv[1]).read().rstrip());now=datetime.now(tz=timezone.utc);print(now-old)"
