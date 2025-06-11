cwlVersion: v1.0
class: CommandLineTool

doc: "Switching input to a file to be sure these are correctly processed. This file is provided as a DRS entry that points to a remote node
      to test the implicit dispatching"

inputs:
  dataset:
    type: File

outputs: []

baseCommand: echo
arguments: ["Hello World from some remote node! We are testing scenario 4 :)"]
