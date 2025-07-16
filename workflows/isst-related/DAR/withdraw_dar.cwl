cwlVersion: v1.2
class: CommandLineTool

requirements:
  DockerRequirement:
    dockerPull: repomanager.lcsb.uni.lu:9999/curlimages/curl:8.8.0

hints:
  RemoteLocationRequirement:
    nodeUri: $(inputs.nodeId)
  CentralStorageRequirement:
    centralStorage: true



inputs:
  nodeId:
    type: string
    doc: "Node where cancel request should be directed to"
    default: "http://tesk-api-node-1:8080/ga4gh/tes"

  darId:
    doc: "DAR identifier"
    type: string

outputs:
  requestStatus:
    type: string
    outputBinding:
      glob: response.txt
      loadContents: true
      outputEval: $(self[0].contents)

stdout: response.txt

baseCommand: curl
arguments:
  - -X
  - PUT
  - -H
  - "Content-Type: application/json"
  - -o
  - unwanted.txt
  - -s
  - -w
  - "%{http_code}"
  - --retry
  - "2"
  - --retry-delay
  - "10"
  - "http://policy-issuer:1919/dar/v2/$(inputs.darId)?state=WITHDRAWN"
