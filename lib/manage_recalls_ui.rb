# frozen_string_literal: true

require 'httparty'

class ManageRecallsUi
  include HTTParty
  format :json

  URI = {
    'dev' => 'https://manage-recalls-dev.hmpps.service.justice.gov.uk',
    'preprod' => 'https://manage-recalls-preprod.hmpps.service.justice.gov.uk',
    'prod' => 'https://manage-recalls.hmpps.service.justice.gov.uk'
  }.freeze

  attr_reader :base_uri, :options

  def initialize(env)
    @base_uri = ManageRecallsUi::URI[env]
    @options = { headers: { 'Content-Type' => 'application/json' } }
  end

  def current_version
    self
      .class
      .get("#{base_uri}/health", options)
      .dig('build', 'buildNumber')
  end
end
