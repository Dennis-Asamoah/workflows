cwlVersion: v1.0
class: CommandLineTool
baseCommand: echo
hints:
  - class: DockerRequirement
    dockerPull: trs://192.168.64.1/HJ9B1K/versions/81mrus

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
