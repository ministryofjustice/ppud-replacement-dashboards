# frozen_string_literal: true

require 'httparty'
require 'date'

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

  def get_projects
    @projects ||= self
                  .class
                  .get('/v1.1/projects', @options)
                  .select { |proj| proj['username'] == @gh_org }
                  .sort_by { |proj| proj['reponame'] }
  end

  def get_workflows_for_project(project)
    workflows = {}

    project['branches']['main']['latest_workflows'].each do |workflow_name, workflow_info|
      next if ['Build%20Error', 'workflow'].include?(workflow_name)

      workflow = get_workflow(workflow_info['id'])
      recent_runs = get_workflow_runs(workflow)
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

  def get_workflow(workflow_id)
    self.class.get("/v2/workflow/#{workflow_id}")
  end

  def get_workflow_runs(workflow)
    self
      .class
      .get("/v2/insights/#{workflow['project_slug']}/workflows/#{workflow['name']}?branch=main")['items']
  end

  def get_projects_and_workflows
    data = {}

    get_projects.each do |project|
      data[project['reponame']] = get_workflows_for_project(project)
    end

    data
  end

  private

  def calc_climate(workflow_runs)
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
      'https://app.circleci.com/pipelines/%s/%s/workflows/%s',
      workflow['project_slug'],
      workflow['pipeline_number'],
      workflow['id']
    )
  end
end
