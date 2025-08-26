cwlVersion: v1.2
class: Workflow

doc: Workflow to build figure from federated analysis
requirements:
  MultipleInputFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  datasetRequests:
    type:
      type: array
      items: File
    default:
      - class: File
        location: https://gitlab.com/uniluxembourg/lcsb/BioCore/iderha/iderha-cwl-wes-workflows/raw/main/resources/iderha-edc-input.json
      - class: File
        location: https://gitlab.com/uniluxembourg/lcsb/BioCore/iderha/iderha-cwl-wes-workflows/raw/main/resources/iderha-edc-input-2.json
  locations:
    type:
      type: array
      items: string
    default:
      - http://tesk-api-node-1:8080/ga4gh/tes
      - http://tesk-api-node-2:8080/ga4gh/tes

  # Graph parameters
  legend:
    type: boolean?
  title:
    type: string?
  displayNum:
    type: int?
  colors:
    type: string[]?
  labels:
    type: string[]?

outputs:
  logs:
    type: File
    outputSource:
      nvflare/logs

  output_stats:
    type: File
    outputSource:
      nvflare/output_file

  stats_image:
    type: File
    outputSource:
      build_image/pic

steps:
  subworkflow:
    in:
      datasetRequest: datasetRequests
      location: locations
    out: [dataset]
    scatter: [datasetRequest, location]
    scatterMethod: dotproduct
    run: edc-pull-data-subworkflow.cwl

  nvflare:
    run: nvflare-get-stats.cwl
    in:
      data_files:
        source: subworkflow/dataset

    out: ["logs" , "output_file"]

  build_image:
    run: nvflare-build-graph.cwl
    in:
      stats:
        source: nvflare/output_file
      legend:
        source: legend
      title:
        source: title
      displayNum:
        source: displayNum
      colors:
        source: colors
      labels:
        source: labels
    out: ["pic"]
