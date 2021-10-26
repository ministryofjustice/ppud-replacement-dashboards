# frozen_string_literal: true

require_relative 'spec_helper'
require 'webmock/minitest'

WebMock.disable_net_connect!

require_relative 'support/json_fixtures'
require_relative '../lib/manage_recalls_ui'

module ManageRecallsUiHelpers
  include JSONFixtures

  def stub_health_request(options = {})
    url           = "#{ManageRecallsUi::URI['dev']}/health"
    status        = options.fetch(:status, 200)
    response_body = options.fetch(:response_body, json_string('manage_recalls_ui_health.json'))

    stub_request(:get, url).to_return(status: status, body: response_body)
  end
end

describe ManageRecallsUi do
  include ManageRecallsUiHelpers

  subject { ManageRecallsUi.new('dev') }

  it '#current_version - returns the currently deployed version of the application' do
    stub_health_request

    _(subject.current_version).must_equal('2021-10-26.8796.412554e')
  end
end
