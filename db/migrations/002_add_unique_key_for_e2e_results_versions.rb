# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    alter_table(:manage_recalls_e2e_results) do
      add_index %i[api_version ui_version], unique: true
    end
  end
end
