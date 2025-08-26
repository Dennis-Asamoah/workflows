cwlVersion: v1.2
class: CommandLineTool
requirements:
  DockerRequirement:
    dockerPull: gitlab.lcsb.uni.lu:4567/luca.bolzani/iderha-test-deployment/flareless-analysis
  WorkReuse:
    enableReuse: false

doc: Merge analyses results from remote nodes

inputs:
  dataFiles:
    type:
      type: array
      items: File
      inputBinding:
        prefix: -i

  logs:
    type:
      type: array
      items: File
      inputBinding:
        prefix: -l

outputs:
  output_file:
    type: File
    outputBinding:
      glob: ["image_statistics.json"]

  logs:
    type: File
    outputBinding:
      glob: ["merged_logs.txt"]


baseCommand: python3
arguments:
  - /app/flareless_merge.py