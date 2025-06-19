cwlVersion: v1.0
class: CommandLineTool
doc: Run exploratory analysis with NVidia Flare
requirements:
  DockerRequirement:
    dockerPull: registry.gitlab.com/uniluxembourg/lcsb/biocore/iderha/iderha-platform/unilu/iderha-cwl-wes-workflows/nvflare-stats_omop:latest

inputs:
  data_files:
    type:
      type: array
      items: File
      inputBinding:
        valueFrom: $(self.location)
    inputBinding:
      position: 1

outputs:
  logs:
    type: stdout
  output_file:
    type: File
    outputBinding:
      glob: "image_statistics.json"

stdout: nvflare.log

baseCommand: ["/app/run_job.sh"]
