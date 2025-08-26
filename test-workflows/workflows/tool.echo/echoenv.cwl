cwlVersion: v1.0
class: CommandLineTool

hints:
  RemoteLocationRequirement:
    nodeUri: $(inputs.location)

inputs:
  location:
    type: string

outputs: []

baseCommand: [sh, -c]
arguments:
  - valueFrom: |
      echo "Printing Kubernetes environment variables" && \
      echo "" && \
      printenv && \
      echo "" && \
      echo "------------------------------------------------------------";