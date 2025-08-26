cwlVersion: v1.0
class: Workflow

doc: Get date in a remote node, then ask that node again and get the time delta. The time delta is sent to central node for printing

hints:
  DockerRequirement:
    dockerPull: python:3.9-alpine

inputs:
  nodeId:
    type: string

outputs:
  delta:
    type: File
    outputSource: writeTime/printed


steps:
  getDate:
    run: scenario12.getDate.cwl
    in:
      nodeId:
        source: nodeId
    out: [date1]
  getTimeDelta:
    run: scenario12.getTimeDelta.cwl
    in:
      nodeId:
        source: nodeId
      date1:
        source: getDate/date1
    out: [timedelta]
  writeTime:
    run: scenario12.writeTime.cwl
    in:
      timedelta:
        source: getTimeDelta/timedelta
    out: [printed]
