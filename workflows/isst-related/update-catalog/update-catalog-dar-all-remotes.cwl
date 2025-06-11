cwlVersion: v1.2
class: Workflow
doc: Scatters the workflow to update DAR statuses in MDC

requirements:
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}

inputs:
  nodes:
    type: string[]
    default: ["http://tesk-api-node-1:8080/ga4gh/tes", "http://tesk-api-node-2:8080/ga4gh/tes"]

outputs: []
steps:
  scattered:
    run: update-catalog-dar.cwl
    scatter: location
    in:
      location: nodes
    out: []