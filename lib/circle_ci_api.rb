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

  def projects
    self
      .class
      .get('/v1.1/projects', @options)
      .select { |proj| proj['username'] == @gh_org }
      .map { |proj| proj['reponame'] }
      .sort
  end

  def workflows_for_project(project)
    workflows = {}

    self
      .class
      .get("/v1.1/project/#{project_slug(project)}/tree/main")
      .each do |build|
        workflow_name = build['workflows']['workflow_name']
        next if ['Build Error', 'workflow'].include?(workflow_name)

        workflows[workflow_name] ||= {
          'id' => build['workflows']['workflow_id'],
          'builds' => []
        }

        workflows[workflow_name]['builds'].push(build)
      end

    workflows
  end

  def projects_and_workflows
    data = {}

    projects.each do |project_name|
      data[project_name] = workflows_for_project(project_name)
    end

    data
  end

  private

  def project_slug(project)
    "github/#{@gh_org}/#{project}"
  end
end
