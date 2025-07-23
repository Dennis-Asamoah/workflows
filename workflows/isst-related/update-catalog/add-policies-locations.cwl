cwlVersion: v1.2
class: CommandLineTool
doc: "Loads a DCAT containing a catalog and adds the location of required policy files in the odrl:hasPolicy field"

requirements:
  DockerRequirement:
    # dockerPull: gitlab.lcsb.uni.lu:4567/luca.bolzani/iderha-test-deployment/iderha-mdc-management
    dockerPull: registry.gitlab.com/uniluxembourg/lcsb/biocore/iderha/iderha-platform/unilu/iderha-cwl-wes-workflows/iderha-mdc-management:change-mdc-service-name 

hints:
  RemoteLocationRequirement:
    nodeUri: $(inputs.location)

inputs:
  dcatFile:
    type: File
    inputBinding:
      prefix: -i

  policyMapping:
    type: File
    inputBinding:
      prefix: -l
      position: 1

  location:
    type: string
    inputBinding:
      prefix: --host
      position: 2

outputs:
  updatedDCAT:
    type: File
    outputBinding:
      glob: new-dcat.json


baseCommand: python
arguments:
  - /app/update-dcat.py
