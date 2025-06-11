cwlVersion: v1.2
class: CommandLineTool

requirements:
  DockerRequirement:
    dockerPull: registry.gitlab.com/uniluxembourg/lcsb/biocore/iderha/iderha-cwl-wes-workflows/iderha-mdc-management:latest

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
