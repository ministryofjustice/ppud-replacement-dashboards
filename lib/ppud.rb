require 'circleci'
require 'date'

GH_ORG = 'ministryofjustice'

CircleCi.configure do |config|
  config.token = ENV['CIRCLE_CI_AUTH_TOKEN']
end

class Ppud
  def self.projects
    @projects ||= begin
      projects_req = CircleCi::Projects.new
      project_list = projects_req
                     .get
                     .body
                     .select { |proj| proj['username'] == GH_ORG }
                     .map { |proj| proj['reponame'] }
                     .sort
    end
  end

  def self.workflows_for_project(project_name)
    workflows = {}

    project = CircleCi::Project.new(GH_ORG, project_name)
    builds  = project.recent_builds_branch('main').body

    builds.each do |build|
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

  def self.projects_and_workflows
    ppud_projects = {}

    Ppud.projects.each do |project_name|
      ppud_projects[project_name] = Ppud.workflows_for_project(project_name)
    end

    ppud_projects
  end
end
