cwlVersion: v1.2
class: Workflow

doc: Workflow to pull and explore data from one remote node
requirements:
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  datasetRequest:
    type: File
  location:
    type: string

outputs:
  logs:
    type: File
    outputSource: [getStats/logs]
  output_file:
    type: File
    outputSource: [getStats/output_file]

steps:
  pullData:
    in:
      datasetRequest: datasetRequest
      location: location
    out: [dataset]
    run: edc-pull-data-subworkflow.cwl

  getStats:
    hints:
      CentralStorageRequirement:
        centralStorage: true
    run: flareless-get-stats.cwl
    in:
      data_files: pullData/dataset
      location: location
    out: [ "logs" , "output_file" ]
