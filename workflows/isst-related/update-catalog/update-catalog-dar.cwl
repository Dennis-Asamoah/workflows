cwlVersion: v1.2
class: Workflow
doc: Workflow to collect DAR statuses from a location and update MDC

inputs:
  location: string

outputs: []

steps:
  getDAR:
    hints:
      CentralStorageRequirement:
        centralStorage: true
    run: get-dar-metadata.cwl
    in:
      location: location
    out: [DARMetadata, location]

  postDAR:
    run: post-dar-metadata.cwl
    in:
      DARMetadata: getDAR/DARMetadata
      location: getDAR/location
    out: []