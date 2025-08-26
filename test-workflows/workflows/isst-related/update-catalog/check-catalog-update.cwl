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
  CentralStorageRequirement:
    centralStorage: true

inputs:
  location:
    type: string

outputs:
  updated:
    type: boolean
    outputBinding:
      glob: updated.txt
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents).updated)


baseCommand: sh
arguments:
  - -c
  - "curl -s http://policy-issuer:1919/api/catalog/update -o updated.txt"
