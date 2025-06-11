cwlVersion: v1.2
class: Workflow

doc: Workflow to pull and explore data from one remote node
requirements:
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  datasetRequest:
    type:
      type: record
      fields:
        assetId:
          type: int?
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
      client: datasetRequest
      datasetId:
        valueFrom: $(inputs.client.assetId)
      location:
        valueFrom: $(inputs.client.location)
    out: [dataset]
    run: create_conditions.cwl

  getStats:
    hints:
      CentralStorageRequirement:
        centralStorage: true
    run: flareless-get-stats.cwl
    in:
      data_files: pullData/dataset
      client: datasetRequest
      location:
        valueFrom: $(inputs.client.location)
    out: [ "logs" , "output_file" ]
