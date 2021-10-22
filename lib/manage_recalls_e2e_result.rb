# frozen_string_literal: true

require 'sequel'

class ManageRecallsE2eResult < Sequel::Model
  def self.latest_for_env(env)
    ManageRecallsE2eResult.where(environment: env)
                          .reverse(:id)
                          .limit(20)
  end
end
