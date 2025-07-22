cwlVersion: v1.2
class: CommandLineTool
doc: Downloads policy files assigned to datasets in a dcat:Datacatalog object

requirements:
  DockerRequirement:
    dockerPull: registry.gitlab.com/uniluxembourg/lcsb/biocore/iderha/iderha-platform/unilu/iderha-cwl-wes-workflows/iderha-mdc-management:change-mdc-service-name
    # gitlab.lcsb.uni.lu:4567/luca.bolzani/iderha-test-deployment/iderha-mdc-management

hints:
  RemoteLocationRequirement:
    nodeUri: $(inputs.location)

inputs:
  location:
    type: string

  assetsJson:
    type: File
    inputBinding:
      prefix: -i
      position: 1

  strict:
    type: boolean
    default: false
    inputBinding:
      prefix: -s
      position: 2

outputs:
  policyMapping:
    type: File
    outputBinding:
      glob: files_per_policy.json


baseCommand: python
arguments:
  - /app/get-assets-policies.py
