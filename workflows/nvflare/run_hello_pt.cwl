cwlVersion: v1.0
class: CommandLineTool

requirements:
  DockerRequirement:
    dockerPull: registry.gitlab.com/uniluxembourg/lcsb/biocore/iderha/iderha-platform/unilu/iderha-cwl-wes-workflows/nvflare-hello-pt

inputs: []

outputs:
#  logs:
#    type: stdout
  output_file:
    type: File
    outputBinding:
      glob: "hello-pt_out.tar"

#stdout: nvflare.log

baseCommand: ["/app/run_job.sh"]
