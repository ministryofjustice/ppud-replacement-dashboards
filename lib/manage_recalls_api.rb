# frozen_string_literal: true

require 'httparty'

class ManageRecallsApi
  include HTTParty
  format :json

  URI = {
    'dev' => 'https://manage-recalls-api-dev.hmpps.service.justice.gov.uk',
    'preprod' => 'https://manage-recalls-api-preprod.hmpps.service.justice.gov.uk',
    'prod' => 'https://manage-recalls-api.hmpps.service.justice.gov.uk'
  }.freeze

  attr_reader :base_uri, :options

  def initialize(env)
    @base_uri = ManageRecallsApi::URI[env]
    @options = { headers: { 'Content-Type' => 'application/json' } }
  end

  def current_version
    self
      .class
      .get("#{base_uri}/health", options)
      .dig('components', 'healthInfo', 'details', 'version')
  end
end
