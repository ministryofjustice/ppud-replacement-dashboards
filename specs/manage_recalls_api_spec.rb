# frozen_string_literal: true

require_relative 'spec_helper'
require 'webmock/minitest'

WebMock.disable_net_connect!

require_relative 'support/json_fixtures'
require_relative '../lib/manage_recalls_api'

module ManageRecallsApiHelpers
  include JSONFixtures

  def stub_health_request(options = {})
    url           = "#{ManageRecallsApi::URI['dev']}/health"
    status        = options.fetch(:status, 200)
    response_body = options.fetch(:response_body, json_string('manage_recalls_api_health.json'))

    stub_request(:get, url).to_return(status: status, body: response_body)
  end
end

describe ManageRecallsApi do
  include ManageRecallsApiHelpers

  subject { ManageRecallsApi.new('dev') }

  it '#current_version - returns the currently deployed version of the application' do
    stub_health_request

    _(subject.current_version).must_equal('2021-10-25.9245.9b07f95')
  end
end
