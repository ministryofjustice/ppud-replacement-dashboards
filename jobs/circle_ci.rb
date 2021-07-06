# frozen_string_literal: true

# Constants for the display formatting and calculations
module Constants
  STATUSES = %w[failed passed running started broken timedout no_tests fixed success canceled].freeze
  FAILED, PASSED, RUNNING, STARTED, BROKEN, TIMEDOUT, NOTESTS, FIXED, SUCCESS, CANCELED = STATUSES
  FAILED_C   = 0.05
  BROKEN_C   = 0.05
  TIMEDOUT_C = 0.3
  NO_TESTS_C = 0.5
  CANCELED_C = 0.5
  RUNNING_C  = 1.0
  STARTED_C  = 1.0
  FIXED_C    = 1.0
  PASSED_C   = 1.0
  SUCCESS_C  = 1.0
end

def get_climate(builds)
  statuses = builds[0..10].map { |build| build['status'] }.compact
  weight = get_climate_weight(statuses)

  case weight
  when 0.0..0.25  then '9'
  when 0.26..0.5  then '7'
  when 0.51..0.75 then '1'
  when 0.76..1.0  then 'v'
  else
    '|'
  end
end

def get_climate_weight(statuses)
  weight = nil

  statuses.each do |status|
    factor = begin
      Constants.const_get("#{status.upcase}_C")
    rescue StandardError
      nil
    end
    next unless factor

    weight = weight.nil? ? factor : weight * factor
  end

  weight
end

# def build_info(builds = [])
#   return {} if builds.empty?

#   build = builds.first

#   {
#     build_num: build['build_num'],
#     build_url: build['build_url'],
#     workflow: build['workflows']['workflow_name'],
#     job_name: build['workflows']['job_name'],
#     committer: build['committer_name'],
#     commit_str: build['subject'],
#     status: build['status'],
#     climate: get_climate(builds)
#   }
# end

SCHEDULER.every('1m', { first_in: '2s', allow_overlapping: false }) do
  api = CircleCiApi.new

  api.get_projects_and_workflows.each do |project, workflows|
    workflows.each do |workflow, workflow_data|
      data_id = "circle-ci-#{api.gh_org}-#{project}-#{workflow}"
      data = {
        pipeline_num: workflow_data['pipeline_number'],
        pipeline_url: workflow_data['pipeline_url'],
        workflow_name: workflow_data['name'],
        workflow_status: workflow_data['status']
      }

      send_event(data_id, data) unless data.empty?
    end
  end
end
