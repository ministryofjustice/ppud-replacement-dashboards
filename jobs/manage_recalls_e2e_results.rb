# frozen_string_literal: true

require 'httparty'

def collate_results(env)
  {
    environment: env,
    current_api_version: ManageRecallsApi.new(env).current_version,
    current_ui_version: ManageRecallsUi.new(env).current_version,
    items: ManageRecallsE2eResult.latest_for_env(env).map(&:as_json)
  }
end

SCHEDULER.every('1m', { first_in: '2s', allow_overlapping: false }) do
  %w[dev preprod prod].each do |env|
    send_event("manage-recalls-e2e-result-#{env}", collate_results(env))
  end
end
