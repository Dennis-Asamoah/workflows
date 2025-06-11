cwlVersion: v1.2
class: Workflow
doc: Extension of scenario 12, where getting the timedelta is done in 2 nodes, then compared

requirements:
  DockerRequirement:
    dockerPull: repomanager.lcsb.uni.lu:9999/python:3.9

inputs:
  nodeId:
    type: string

outputs:
  faster:
    type: File
    outputSource: compare/output

steps:
  getDateCentral:
    in: []
    out: [ dateOutput ]
    run: writeDate.cwl

  getDate1:
    in:
      nodeId:
        source: nodeId
    out: [dateOutput]
    run: writeDate.cwl

  timeDelta1:
    in:
      nodeId:
        source: nodeId
      dateInput:
        source: getDate1/dateOutput
    out: [timedelta]
    run: timedelta.cwl

  timeDeltaCentral:
    in:
      dateInput:
        source: getDateCentral/dateOutput
    out: [timedelta]
    run: timedelta.cwl

  compare:
    in:
      first:
        source: timeDeltaCentral/timedelta
      second:
        source: timeDelta1/timedelta
    out: [output]
    run: scenario13.compare.cwl
