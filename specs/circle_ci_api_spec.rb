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

  def stub_project_builds_requests(options = {})
    url           = 'https://circleci.com/api/v1.1/project/github/ministryofjustice/manage-recalls-api/tree/main'
    status        = options.fetch(:status, 200)
    response_body = options.fetch(:response_body, json_string('v1.1_manage_recalls_api_builds.json'))

    stub_request(:get, url).to_return(status: status, body: response_body)
  end
end

describe CircleCiApi do
  include CircleCiApiHelpers

  subject { CircleCiApi.new }

  it '#projects - returns an array of subscribed to projects' do
    stub_projects_request
    _(subject.projects).must_equal(%w[manage-recalls-api manage-recalls-ui])
  end

  it '#workflows(<project>) - returns a hash of workflows for the project (and their status)' do
    stub_project_builds_requests

    expected = {
      'security' => {
        'id' => 'fc759323-a297-4129-9f95-e4ba575ed90d',
        'builds' => [
          { 'build_num' => 717, 'status' => 'failed' },
          { 'build_num' => 716, 'status' => 'success' },
          { 'build_num' => 715, 'status' => 'success' }
        ]
      }
    }

    workflows = subject.workflows_for_project('manage-recalls-api')

    _(workflows.keys).must_equal(%w[security build-test-and-deploy])
    _(workflows['security']['id']).must_equal(expected['security']['id'])
    _(workflows['security']['builds'].size).must_equal(3)
  end
end
