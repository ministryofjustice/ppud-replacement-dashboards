# frozen_string_literal: true

SCHEDULER.every('1m', { first_in: '2s', allow_overlapping: false }) do
  api = CircleCiApi.new
  api.projects_and_workflows.each do |project, workflows|
    workflows.each do |workflow, workflow_data|
      data_id = "circle-ci-#{api.gh_org}-#{project}-#{workflow}"
      data = {
        pipeline_num: workflow_data['pipeline_number'],
        pipeline_url: workflow_data['pipeline_url'],
        workflow_name: workflow_data['name'],
        workflow_status: workflow_data['status'],
        climate: workflow_data['climate']
      }

      send_event(data_id, data) unless data.empty?
    end
  end
end
