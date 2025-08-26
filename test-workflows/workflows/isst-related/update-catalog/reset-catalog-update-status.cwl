cwlVersion: v1.2
class: CommandLineTool

requirements:
  DockerRequirement:
    dockerPull: repomanager.lcsb.uni.lu:9999/curlimages/curl
  InlineJavascriptRequirement: {}
  NetworkAccess:
    networkAccess: true

hints:
  RemoteLocationRequirement:
    nodeUri: $(inputs.location)

inputs:
  location:
    type: string

outputs: []


baseCommand: sh
arguments:
  - -c
  - "curl -s -X PUT http://policy-issuer:1919/api/catalog/update"
