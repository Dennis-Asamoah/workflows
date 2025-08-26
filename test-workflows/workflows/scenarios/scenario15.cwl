cwlVersion: v1.2
class: Workflow
doc: Get date in both central and remote nodes, then calculate timedelta between results

requirements:
  DockerRequirement:
    dockerPull: repomanager.lcsb.uni.lu:9999/python:3.9

inputs:
  nodeId:
    type: string

outputs:
  timedelta:
    type: File

steps:
  dateCentral:
    in: []
    out: [dateOutput]
    run: writeDate.cwl

  dateRemote:
    in:
      nodeId:
        source: nodeId
    out: [dateOutput]
    run: writeDate.cwl

  timeDelta:
    in:
      date1:
        source: dateCentral/dateOutput
      date2:
        source: dateRemote/dateOutput
    out: [timedelta]
    run: scenario15.timeDelta.cwl

