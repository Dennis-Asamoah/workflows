cwlVersion: v1.2
class: Workflow
doc: Get date in both remote nodes, then calculate the timedelta between two results in central node

requirements:
  DockerRequirement:
    dockerPull: repomanager.lcsb.uni.lu:9999/python:3.9

inputs:
  firstNode:
    type: string
  secondNode:
    type: string

outputs:
  timedelta:
    type: File

steps:
  dateCentral:
    in:
      nodeId:
        source: firstNode
    out: [dateOutput]
    run: writeDate.cwl

  dateRemote:
    in:
      nodeId:
        source: secondNode
    out: [dateOutput]
    run: writeDate.cwl

  timeDelta:
    in:
      date1:
        source: dateCentral/dateOutput
      date2:
        source: dateRemote/dateOutput
    out: [timedelta]
    run: scenario16.timeDelta.cwl