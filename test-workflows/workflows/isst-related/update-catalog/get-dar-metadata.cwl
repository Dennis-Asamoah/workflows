cwlVersion: v1.2
class: CommandLineTool

requirements:
  WorkReuse:
    enableReuse: false
  DockerRequirement:
    dockerPull: repomanager.lcsb.uni.lu:9999/curlimages/curl:8.8.0

hints:
  RemoteLocationRequirement:
    nodeUri: $(inputs.location)

inputs:
  location:
    type: string
    default: "http://tesk-api-node-1:8080/ga4gh/tes"

outputs:
  DARMetadata:
    type: File
    outputBinding:
      glob: output.json
  location:
    type: string
    outputBinding:
      outputEval: $(inputs.location)

baseCommand: sh
arguments:
  - -c
  - "curl --location http://policy-issuer:1919/dar/v1/request > output.json"
