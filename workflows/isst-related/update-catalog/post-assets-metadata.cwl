cwlVersion: v1.2
class: CommandLineTool

requirements:
  DockerRequirement:
    dockerPull: registry.gitlab.com/uniluxembourg/lcsb/biocore/iderha/iderha-cwl-wes-workflows/iderha-mdc-management:latest

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