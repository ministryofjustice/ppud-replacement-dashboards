# frozen_string_literal: true

require 'httparty'
require 'date'

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

      puts "processing #{project['reponame']} -- #{workflow_name}"

      workflow = get_workflow(workflow_info['id'])
      workflows[workflow_name] = workflow.merge({ 'pipeline_url' => workflow_pipeline_url(workflow) })
    end

    workflows
  end

  def get_workflow(workflow_id)
    self.class.get("/v2/workflow/#{workflow_id}")
  end

  def get_projects_and_workflows
    data = {}

    get_projects.each do |project|
      data[project['reponame']] = get_workflows_for_project(project)
    end

    data
  end

  private

  def workflow_pipeline_url(workflow)
    format(
      'https://app.circleci.com/pipelines/%s/%s/workflows/%s',
      workflow['project_slug'],
      workflow['pipeline_number'],
      workflow['id']
    )
  end

  def project_slug(project)
    "github/#{@gh_org}/#{project}"
  end
end
