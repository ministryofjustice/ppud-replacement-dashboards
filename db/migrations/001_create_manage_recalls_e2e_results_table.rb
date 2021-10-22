# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:manage_recalls_e2e_results) do
      primary_key :id
      String :e2e_build_url, null: false, unique: true
      String :environment, null: false
      TrueClass :successful, null: false
      String :ui_version, null: false
      String :ui_build_url, null: false
      String :api_version, null: false
      String :api_build_url, null: false
    end
  end
end
