cwlVersion: v1.2
class: CommandLineTool

requirements:
  DockerRequirement:
    dockerPull: gitlab.lcsb.uni.lu:4567/luca.bolzani/iderha-test-deployment/iderha-mdc-management
    # gitlab.lcsb.uni.lu:4567/luca.bolzani/iderha-test-deployment/iderha-mdc-management
    # registry.gitlab.com/uniluxembourg/lcsb/biocore/iderha/iderha-platform/unilu/iderha-cwl-wes-workflows/iderha-mdc-management:change-mdc-service-name

inputs:
  assetsMetadataFile:
    type: File
    inputBinding:
      position: 1

outputs:
  status:
    type: string
    outputBinding:
      glob: response.txt
      loadContents: true
      outputEval: $(self[0].contents)

baseCommand: "python3"
arguments:
  - "/app/post-assets-metadata.py"

#  - -X
#  - POST
#  - -H
#  - Content-Type:application/json
#  - --location
#  - http://iderha-catalog:3000/api/catalog
#  - --data
#  - @$(inputs.assetsMetadata.path)
