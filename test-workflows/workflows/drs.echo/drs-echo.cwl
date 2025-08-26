cwlVersion: v1.0
class: CommandLineTool
baseCommand: echo

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1
outputs:
  output_file:
    type: File
    outputBinding:
      glob: echo_output.txt
