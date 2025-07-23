cwlVersion: v1.2
class: CommandLineTool

requirements:
  DockerRequirement:
    # dockerPull: gitlab.lcsb.uni.lu:4567/luca.bolzani/iderha-test-deployment/iderha-mdc-management
    dockerPull: registry.gitlab.com/uniluxembourg/lcsb/biocore/iderha/iderha-platform/unilu/iderha-cwl-wes-workflows/iderha-mdc-management:change-mdc-service-name

hints:
  RemoteLocationRequirement:
    nodeUri: $(inputs.location)

inputs:
  jsonTemplate:
    type: File

  location:
    type: string
    default: "http://tesk-api-node-1:8080/ga4gh/tes"

  providerId:
    type: string
    default: provider

outputs:
  assetsMetadata:
    type: File
    outputBinding:
      glob: output.json

baseCommand: sh
arguments:
  - -c
  - "python3 /app/get-assets-metadata.py $(inputs.jsonTemplate.path)"
