cwlVersion: v1.2
class: Workflow
doc: Workflow to collect and publish assets metadata

requirements:
  WorkReuse:
    enableReuse: false
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  jsonTemplate:
    type: File
  location:
    type: string

outputs: []

steps:
  getMetadata:
    in:
      jsonTemplate: jsonTemplate
      location: location

    out: [assetsMetadata]
    run: get-assets-metadata.cwl

  getAssetPolicies:
    run: get-assets-policies.cwl
    in:
      location: location
      assetsJson: getMetadata/assetsMetadata
    out: [policyMapping]

  addLocations:
    hints:
      CentralStorageRequirement:
        centralStorage: true
    run: add-policies-locations.cwl
    in:
      location: location
      dcatFile: getMetadata/assetsMetadata
      policyMapping: getAssetPolicies/policyMapping
    out: [updatedDCAT]

  updateCatalog:
    in:
      assetsMetadataFile:
        source: [addLocations/updatedDCAT]
    out: [status]
    run: post-assets-metadata.cwl

  resetCatalogStatus:
    in:
      location: location
      status: updateCatalog/status
    out: []
    run: reset-catalog-update-status.cwl
    when: $(inputs.status.search("2[0-9]{2}") === 0)
