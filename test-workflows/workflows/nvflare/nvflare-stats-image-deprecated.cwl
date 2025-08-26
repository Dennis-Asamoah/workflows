cwlVersion: v1.2
class: Workflow

doc: Workflow to build figure from federated analysis 
requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  dataset1:
    type: int?
  dataset2:
    type: int?
  client1:
    type: string
    default: "http://tesk-api-node-1:8080/ga4gh/tes/"
  client2:
    type: string
    default: "http://tesk-api-node-2:8080/ga4gh/tes/"

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
  pullData1:
    doc: Here we download data from ftp and provide it as ftp output
    in:
      location:
        source: client1
      datasetId:
        source: dataset1
    out: [dataset]
    run: create_conditions.cwl

  pullData2:
    doc: Same as 1 from the other remote node.
    in:
      location:
        source: client2
      datasetId:
        source: dataset2
    out: [dataset]
    run: create_conditions.cwl

  nvflare:
    run: nvflare-get-stats.cwl
    in:
      data_files:
        source: [pullData1/dataset, pullData2/dataset]
        linkMerge: merge_nested

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

