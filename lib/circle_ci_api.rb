# frozen_string_literal: true

require 'httparty'
require 'date'
require 'parallel'

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

class CircleCiApi
  include HTTParty
  base_uri 'https://circleci.com/api'
  format :json
  # logger ::Logger.new($stdout), :info, :apache

  attr_reader :gh_org

  def initialize(gh_org = 'ministryofjustice')
    @gh_org = gh_org
    @options = {
      headers: {
        'Circle-Token' => ENV['CIRCLE_CI_AUTH_TOKEN'],
        'Content-Type' => 'application/json'
      }
    }
  end

  def projects
    self
      .class
      .get('/v1.1/projects', @options)
      .select { |proj| proj['username'] == @gh_org }
      .sort_by { |proj| proj['reponame'] }
  end

  def workflows_for_project(project)
    workflows = {}
    workflows_to_process = project.dig('branches', 'main', 'latest_workflows')

    Parallel.each(workflows_to_process, in_threads: 5) do |workflow_name, workflow_info|
      next if ['Build%20Error', 'workflow'].include?(workflow_name)

      workflow = workflow(workflow_info['id'])
      recent_runs = workflow_runs(workflow)
      workflows[workflow_name] = workflow.merge(
        {
          'pipeline_url' => workflow_pipeline_url(workflow),
          'recent_runs' => recent_runs,
          'climate' => calc_climate(recent_runs)
        }
      )
    end

    workflows
  end

  def workflow(workflow_id)
    self.class.get("/v2/workflow/#{workflow_id}")
  end

  def workflow_runs(workflow)
    self
      .class
      .get("/v2/insights/#{workflow['project_slug']}/workflows/#{workflow['name']}?branch=main")['items']
  end

  def projects_and_workflows
    data = {}

    Parallel.each(projects, in_threads: 5) do |project|
      data[project['reponame']] = workflows_for_project(project)
    end

    clean_projects_and_workflows(data)
  end

  private

  def clean_projects_and_workflows(data)
    data.delete('ppud-replacement-bandiera')
    data['manage-recalls-api'].delete('pact')
    data['manage-recalls-e2e-tests'].delete('build_docker')
    data['manage-recalls-e2e-tests'].delete('deploy_only')
    data['manage-recalls-e2e-tests'].delete('dev_and_local')
    data['manage-recalls-e2e-tests'].delete('dev_only')
    data['manage-recalls-e2e-tests'].delete('docker_and_build')

    data
  end

  def calc_climate(workflow_runs)
    return '|' if workflow_runs.nil?

    statuses = workflow_runs[0..10].map { |run| run['status'] }.compact
    weight = calc_climate_weight(statuses)

    case weight
    when 0.0..0.25  then '9'
    when 0.26..0.5  then '7'
    when 0.51..0.75 then '1'
    when 0.76..1.0  then 'v'
    else
      '|'
    end
  end

  def calc_climate_weight(statuses)
    weight = nil

    statuses.each do |status|
      factor = begin
        Constants.const_get("#{status.upcase}_C")
      rescue StandardError
        warn "Unrecognised status: #{status}"
        nil
      end
      next unless factor

      weight = weight.nil? ? factor : weight * factor
    end

    weight
  end

  def workflow_pipeline_url(workflow)
    format(
      'https://app.circleci.com/pipelines/%<slug>s/%<num>s/workflows/%<id>s',
      {
        slug: workflow['project_slug'],
        num: workflow['pipeline_number'],
        id: workflow['id']
      }
    )
  end
end
