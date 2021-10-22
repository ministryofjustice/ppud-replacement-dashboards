# frozen_string_literal: true

def collate_results(env)
  {
    environment: env,
    items: DB[:manage_recalls_e2e_results].where(environment: env).map do |item|
      {
        e2e_build_url: item[:e2e_build_url],
        status: item[:successful] ? 'passed' : 'failed',
        ui_version: item[:ui_version],
        ui_build_url: item[:ui_build_url],
        api_version: item[:api_version],
        api_build_url: item[:api_build_url]
      }
    end
  }
end

SCHEDULER.every('1m', { first_in: '2s', allow_overlapping: false }) do
  %w[dev preprod].each do |env|
    send_event("manage-recalls-e2e-result-#{env}", collate_results(env))
  end
end
