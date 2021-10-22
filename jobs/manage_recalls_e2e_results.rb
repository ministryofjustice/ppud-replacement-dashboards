# frozen_string_literal: true

def collate_results(env)
  {
    environment: env,
    items: ManageRecallsE2eResult.latest_for_env(env).map(&:as_json)
  }
end

SCHEDULER.every('1m', { first_in: '2s', allow_overlapping: false }) do
  %w[dev preprod].each do |env|
    send_event("manage-recalls-e2e-result-#{env}", collate_results(env))
  end
end
