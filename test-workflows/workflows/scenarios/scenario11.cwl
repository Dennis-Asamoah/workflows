class: Workflow
cwlVersion: v1.0

doc: Workflow to retrieve date from central node, then to print it in a remote node


inputs:
  nodeId:
    type: string

outputs:
  printed:
    type: File
    outputSource: [printDate/printed]

steps:
  - id: getDate
    run: scenario11.getDate.cwl
    in: []
    out: [output_central]

  - id: printDate
    run: scenario11.printDate.cwl
    in:
      nodeId:
        source: nodeId
      date:
        source: getDate/output_central
    out: [printed]
