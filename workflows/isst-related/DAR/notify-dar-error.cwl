cwlVersion: v1.2
class: CommandLineTool

inputs:
  darId:
    type: string

  edcStatus:
    type: string
    default: "Not sent"

  policyStatus:
    type:
      type: array
      items:
        type: record
        fields:
          filename: string
          status: string

outputs: []

permanentFailCodes: [0]
baseCommand: echo
arguments:
  - "Failed to send Data Access Request $(inputs.darId)\n  DAR request status: $(inputs.edcStatus)\n Policy requests statuses:\n $(inputs.policyStatus)\n  "