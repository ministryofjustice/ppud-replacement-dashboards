# frozen_string_literal: true

require 'httparty'

MANAGE_RECALLS_API = {
  'dev' => 'https://manage-recalls-api-dev.hmpps.service.justice.gov.uk',
  'preprod' => 'https://manage-recalls-api-preprod.hmpps.service.justice.gov.uk',
  'prod' => 'https://manage-recalls-api.hmpps.service.justice.gov.uk'
}

MANAGE_RECALLS_UI = {
  'dev' => 'https://manage-recalls-dev.hmpps.service.justice.gov.uk',
  'preprod' => 'https://manage-recalls-preprod.hmpps.service.justice.gov.uk',
  'prod' => 'https://manage-recalls.hmpps.service.justice.gov.uk'
}

def manage_recalls_api_version(env)
  response = HTTParty.get(
    "#{MANAGE_RECALLS_API[env]}/health",
    headers: { 'Content-Type' => 'application/json' },
    format: :plain
  )

  JSON
    .parse(response.body, symbolize_names: true)
    .dig(:components, :healthInfo, :details, :version)
end

def manage_recalls_ui_version(env)
  response = HTTParty.get(
    "#{MANAGE_RECALLS_UI[env]}/health",
    headers: { 'Content-Type' => 'application/json' },
    format: :plain
  )

  JSON
    .parse(response.body, symbolize_names: true)
    .dig(:build, :buildNumber)
end

def collate_results(env)
  {
    environment: env,
    current_api_version: manage_recalls_api_version(env),
    current_ui_version: manage_recalls_ui_version(env),
    items: ManageRecallsE2eResult.latest_for_env(env).map(&:as_json)
  }
end

SCHEDULER.every('1m', { first_in: '2s', allow_overlapping: false }) do
  %w[dev preprod prod].each do |env|
    send_event("manage-recalls-e2e-result-#{env}", collate_results(env))
  end
end
