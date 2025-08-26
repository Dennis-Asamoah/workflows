cwlVersion: v1.2
class: CommandLineTool
doc: Build figure based on analysis results
requirements:
  DockerRequirement:
    dockerPull: gitlab.lcsb.uni.lu:4567/luca.bolzani/iderha-test-deployment/nvflare-build-graph

inputs:
  stats:
    type: File
    inputBinding:
      position: 1
      prefix: -f
  legend:
    type: boolean?
    inputBinding:
      position: 2
      prefix: -l
  title:
    type: string?
    inputBinding:
      position: 3
      prefix: -t
  displayNum:
    type: int?
    inputBinding:
      position: 4
      prefix: -n
  colors:
    type: string[]?
    inputBinding:
      prefix: "-c"
      itemSeparator: ","
  labels:
    type: string[]?
    inputBinding:
      prefix: --names
      itemSeparator: ","

outputs:
  pic:
    type: File
    outputBinding:
      glob: "stats.pdf"

baseCommand: ["python3", "/app/stats_visualizer.py"]

