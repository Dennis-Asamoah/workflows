cwlVersion: v1.2
class: Workflow

requirements:
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  policyFiles:
    doc: "Access Forms filled by user"
    type: File[]
    default: []

  nodeId:
    type: string
    doc: "Node where DAR should be directed to"
    default: "http://tesk-api-node-1:8080/ga4gh/tes"

  darId:
    doc: "DAR identifier"
    type: string

  userId:
    doc: "User identifier"
    type: string

  policyId:
    type: string

  assetId:
    doc: "Asset identifier"
    type: string

  additionalInformation:
    doc: "Any relevant notes"
    type: string
    default: null

outputs: []

steps:
  postDARFile:
    hints:
      CentralStorageRequirement:
        centralStorage: true
    run: post-dar-file.cwl
    in:
      policyFile: policyFiles
      policyId: policyId
      nodeId: nodeId
      userId: userId
    out: [out]
    scatter: policyFile


  postDARInfo:
    hints:
      CentralStorageRequirement:
        centralStorage: true
    run: post-dar-info.cwl
    in:
      nodeId: nodeId
      darId: darId
      assetId: assetId
      userId: userId
      policyId: policyId
      additionalInformation: additionalInformation
      policyStatus: postDARFile/out
      file:
        valueFrom: $(self.map(function(o){ return o['basename'] }))
        source: policyFiles
    out: [status]
    # Verify to true when policystatus is [] or if non empty must have a 2XX status code
    when: ${return (inputs.policyStatus.length === 0) ||  inputs.policyStatus.some(function(o){return o.status.search("2[0-9]{2}") === 0;})}

  notify:
    run: notify-dar-error.cwl
    in:
      darId: darId
      policyStatus: postDARFile/out
      edcStatus: postDARInfo/status
    out: []
    when: $(inputs.policyStatus.some(function(o){return o.status.search("2[0-9]{2}") === -1;}) || inputs.edcStatus.search("2[0-9]{2}") == -1)


