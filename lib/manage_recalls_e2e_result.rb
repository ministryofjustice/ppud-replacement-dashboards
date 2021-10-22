# frozen_string_literal: true

require 'sequel'

class ManageRecallsE2eResult < Sequel::Model
  def self.latest_for_env(env)
    ManageRecallsE2eResult.where(environment: env)
                          .reverse(:id)
                          .limit(20)
  end

  def self.update_or_create_result(result)
    prev_run = ManageRecallsE2eResult.where(
      api_version: result[:api_version],
      ui_version: result[:ui_version],
    )

    if prev_run.any?
      prev_run.update(result)
    else
      ManageRecallsE2eResult.create(result)
    end
  end
end
