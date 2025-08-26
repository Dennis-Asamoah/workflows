cwlVersion: v1.0
class: Workflow

doc: Workflow to retrieve date from a remote node, then to print it in central node

inputs:
  nodeId:
    type: string

outputs:
  printed:
    type: File
    outputSource: [printDate/printed]
steps:
  - id: getDate
    run: scenario10.getDate.cwl
    in:
      nodeId:
        source: nodeId
    out: [output_central]

  - id: printDate
    run: scenario10.printDate.cwl

    in:
      date:
        source: getDate/output_central
    out: [printed]
