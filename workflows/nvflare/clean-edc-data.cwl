cwlVersion: v1.2
class: CommandLineTool

requirements:
  DockerRequirement:
    dockerPull: gitlab.lcsb.uni.lu:4567/luca.bolzani/iderha-test-deployment/omop-table-clean-header

hints:
  RemoteLocationRequirement:
    nodeUri: $(inputs.location)

doc: Prepare data for follow-up analysis

inputs:
  dataFile:
    type: File
    inputBinding:
      position: 1
  outputFile:
    type: string
    default: condition_era.csv
    inputBinding:
      position: 2
  location:
    type: string

outputs:
  cleanedFile:
    type: File
    outputBinding:
      glob: $(inputs.outputFile)

baseCommand: [clean_header]