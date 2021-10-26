# frozen_string_literal: true

require 'sequel'

class ManageRecallsE2eResult < Sequel::Model
  plugin :timestamps, create: :created_at, update: :updated_at, update_on_create: true

  def self.latest_for_env(env)
    ManageRecallsE2eResult.where(environment: env)
                          .reverse(:updated_at)
                          .limit(12)
  end

  def self.update_or_create_result(result)
    prev_run = ManageRecallsE2eResult.where(
      api_version: result[:api_version],
      ui_version: result[:ui_version]
    )

    if prev_run.any?
      prev_run.update(result)
    else
      ManageRecallsE2eResult.create(result)
    end
  end

  def as_json
    {
      e2e_build_url: e2e_build_url,
      status: successful ? 'passed' : 'failed',
      ui_version: ui_version,
      ui_build_url: ui_build_url,
      api_version: api_version,
      api_build_url: api_build_url,
      timestamp: updated_at.strftime('%F %H:%M')
    }
  end
end
