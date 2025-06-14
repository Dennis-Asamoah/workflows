cwlVersion: v1.2
class: CommandLineTool

doc: Trigger data pulling from EDC data space

requirements:
  WorkReuse:
    enableReuse: false
  DockerRequirement:
    dockerPull: registry.gitlab.com/uniluxembourg/lcsb/biocore/iderha/iderha-platform/unilu/iderha-cwl-wes-workflows/edc-client:0.1.0

hints:
  RemoteLocationRequirement:
    nodeUri: $(inputs.location)

inputs:
  datasetRequest:
    type: File
    inputBinding:
      position: 1
  location:
    type: string

outputs:
  datasetLocation:
    type: File
    outputBinding:
      glob: output.txt

baseCommand: ["/app/edc_client.sh"]
