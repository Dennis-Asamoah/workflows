cwlVersion: v1.2
class: Workflow
doc: Get starting date in central node, compute timedelta in remote node, then print the timedelta in central node

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
  centralDate:
    in: []
    out: [dateOutput]
    run: writeDate.cwl

  remoteTimeDelta:
    in:
      dateInput:
        source: centralDate/dateOutput
      nodeId:
        source: nodeId
    out: [timedelta]
    run: timedelta.cwl

  final:
    in:
      timedelta:
        source: remoteTimeDelta/timedelta
    out: [printed]
    run: scenario14.final.cwl
