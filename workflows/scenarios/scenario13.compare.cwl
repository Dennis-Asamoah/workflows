cwlVersion: v1.2
class: CommandLineTool

inputs:
  first:
    type: File
    inputBinding:
      position: 2
  second:
    type: File
    inputBinding:
      position: 3
outputs:
  output:
    type: stdout
stdout: comparison.txt
baseCommand: python
arguments:
  - "-c"
  - "from datetime import timedelta; import sys; labels = [\"central\", \"remote\"]; values = [timedelta(seconds=float(open(sys.argv[1]).read().rstrip())), timedelta(seconds=float(open(sys.argv[2]).read().rstrip()))];print(f\"{labels[values.index(min(values))]} ({min(values)}) is faster than {labels[values.index(max(values))]} ({max(values)})\")"
