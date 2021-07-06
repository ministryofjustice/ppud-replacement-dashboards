# frozen_string_literal: true

require 'minitest/autorun'
require 'webmock/minitest'

WebMock.disable_net_connect!

require_relative 'support/json_fixtures'
require_relative '../lib/circle_ci_api'

module CircleCiApiHelpers
  include JSONFixtures

  def stub_projects_request(options = {})
    url           = 'https://circleci.com/api/v1.1/projects'
    status        = options.fetch(:status, 200)
    response_body = options.fetch(:response_body, json_string('v1.1_projects.json'))

    stub_request(:get, url).to_return(status: status, body: response_body)
  end

  def stub_workflow_requests(options = {})
    Dir.glob("#{json_dir}/v2_workflow_*.json").each do |filepath|
      filename = File.basename(filepath)
      workflow = json_struct(filename)

      url           = "https://circleci.com/api/v2/workflow/#{workflow['id']}"
      status        = options.fetch(:status, 200)
      response_body = options.fetch(:response_body, json_string(filename))

      stub_request(:get, url).to_return(status: status, body: response_body)
    end
  end

  def stub_workflow_runs_requests(options = {})
    Dir.glob("#{json_dir}/v2_workflow_runs__*.json").each do |filepath|
      filename = File.basename(filepath)
      matcher = /__(.+)__(.+).json/.match(filename)

      url           = "https://circleci.com/api/v2/insights/gh/ministryofjustice/#{matcher[1]}/workflows/#{matcher[2]}\?branch\=main"
      status        = options.fetch(:status, 200)
      response_body = options.fetch(:response_body, json_string(filename))

      stub_request(:get, url).to_return(status: status, body: response_body)
    end
  end
end

describe CircleCiApi do
  include CircleCiApiHelpers

  subject { CircleCiApi.new }

  it '#projects - returns an array of subscribed to projects' do
    stub_projects_request

    _(subject.projects.length).must_equal(2)
    _(subject.projects.map { |proj| proj['reponame'] }).must_equal(%w[manage-recalls-api manage-recalls-ui])
  end

  it '#workflows_for_project(<project>) - returns a hash of workflows for the project (and their status)' do
    stub_projects_request
    stub_workflow_requests
    stub_workflow_runs_requests

    expected = {
      'security' => {
        'pipeline_id' => 'a68bddd8-fd43-4823-9cbc-aea539e01d0a',
        'id' => 'f4b87ad9-da1c-4ff9-a761-08c8ea7e8709',
        'name' => 'security',
        'project_slug' => 'gh/ministryofjustice/manage-recalls-api',
        'status' => 'success',
        'started_by' => 'd9b3fcaa-6032-405a-8c75-40079ce33c3e',
        'pipeline_number' => 144,
        'created_at' => '2021-07-02T07:03:53Z',
        'stopped_at' => '2021-07-02T07:10:17Z',
        'pipeline_url' => 'https://app.circleci.com/pipelines/gh/ministryofjustice/manage-recalls-api/144/workflows/f4b87ad9-da1c-4ff9-a761-08c8ea7e8709',
        'recent_runs' => [],
        'climate' => '9'
      }
    }

    projects = subject.projects
    workflows = subject.workflows_for_project(projects.first)

    _(workflows.keys).must_equal(%w[build_test_and_deploy security])
    _(workflows['security'].merge({ 'recent_runs' => [] })).must_equal(expected['security'])
    _(workflows.dig('security', 'recent_runs').length).must_equal(29)
  end
end
