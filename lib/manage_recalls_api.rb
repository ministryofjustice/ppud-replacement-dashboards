# frozen_string_literal: true

require 'httparty'

class ManageRecallsApi
  include HTTParty
  format :json

  URI = {
    'dev' => ENV.fetch('MANAGE_RECALLS_API_DEV', 'http://manage-recalls-api.manage-recalls-dev:81'),
    'preprod' => ENV.fetch('MANAGE_RECALLS_API_PREPROD', 'http://manage-recalls-api.manage-recalls-preprod:81'),
    'prod' => ENV.fetch('MANAGE_RECALLS_API_PROD', 'http://manage-recalls-api.manage-recalls-prod:81')
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
