cwlVersion: v1.2
class: CommandLineTool
doc: Pull dataset from remote location
requirements:
  DockerRequirement:
    dockerPull: gitlab.lcsb.uni.lu:4567/luca.bolzani/iderha-test-deployment/nvflare-mock-data
  WorkReuse:
    enableReuse: false

hints:
  RemoteLocationRequirement:
    nodeUri: $(inputs.location)

inputs:
  datasetId:
    type: int?
    inputBinding:
      position: 1
  location:
    type: string?

outputs:
  dataset:
    type: File
    outputBinding:
      glob: [condition_era.csv]


baseCommand: python3
arguments:
  - /workspace/create_random_conditions.py