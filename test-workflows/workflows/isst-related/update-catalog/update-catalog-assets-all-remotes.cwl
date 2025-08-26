cwlVersion: v1.2
class: Workflow
doc: Scatters the workflow to collect and publish assets metadata

requirements:
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}

inputs:
  jsonTemplate:
    type: File
  locations:
    type: string[]
    default: ["http://tesk-api-node-1:8080/ga4gh/tes", "http://tesk-api-node-2:8080/ga4gh/tes"]

outputs: []

steps:
  subworkflow:
    run: update-catalog-assets-if-updated.cwl
    in:
      jsonTemplate: jsonTemplate
      location: locations
    out: []
    scatter: location
