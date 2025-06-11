cwlVersion: v1.2
class: Workflow
doc: Workflow to collect and publish assets metadata

requirements:
  WorkReuse:
    enableReuse: false

inputs:
  jsonTemplate:
    type: File
  location:
    type: string

outputs: []

steps:
  checkUpdated:
    run: check-catalog-update.cwl
    in:
      location: location
    out: [updated]

  updateMDC:
    run: update-catalog-assets.cwl
    when: $(inputs.updated)
    in:
      jsonTemplate: jsonTemplate
      location: location
      updated: checkUpdated/updated
    out: []