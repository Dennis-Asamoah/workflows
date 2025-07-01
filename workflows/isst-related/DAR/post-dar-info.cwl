cwlVersion: v1.2
class: CommandLineTool

doc: "Task to send a cURL request to edc endpoint"

requirements:
  DockerRequirement:
    dockerPull: gitlab.lcsb.uni.lu:4567/luca.bolzani/iderha-test-deployment/iderha-mdc-management
  WorkReuse:
    enableReuse: false

hints:
  - class: RemoteLocationRequirement
    nodeUri: $(inputs.nodeId)

inputs:
  - id: nodeId
    type: string
    default: "http://tesk-api-node-1:8080/ga4gh/tes"

  - id: userId
    type: string
    inputBinding:
      prefix: -u

  - id: policyId
    type: string
    inputBinding:
      prefix: -p

  - id: darId
    type: string
    inputBinding:
      prefix: -d

  - id: assetId
    type: string
    inputBinding:
      prefix: -a

  - id: additionalInformation
    type: string
    default: null
    inputBinding:
      prefix: -i

  - id: file
    type:
      type: array
      items: string
    inputBinding:
      prefix: -f
      itemSeparator: " -f "  # Explicit separator
    default: []

outputs:
  status:
    type: string
    outputBinding:
      glob: response.txt
      loadContents: true
      outputEval: $(self[0].contents)

baseCommand: python
arguments:
  - "/app/send-dar-info.py"
stdout: response.txt
