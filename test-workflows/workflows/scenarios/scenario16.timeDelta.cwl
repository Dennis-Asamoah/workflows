cwlVersion: v1.2
class: CommandLineTool

inputs:
  date1:
    type: File
    inputBinding:
      position: 2
  date2:
    type: File
    inputBinding:
      position: 3
outputs:
  timedelta:
    type: stdout
stdout: timedelta.txt
baseCommand: python
arguments:
  - "-c"
  - "from datetime import datetime, timezone; import sys;date1=datetime.fromisoformat(open(sys.argv[1]).read().rstrip());date2=datetime.fromisoformat(open(sys.argv[2]).read().rstrip());print((date1-date2).total_seconds())"
