# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    alter_table(:manage_recalls_e2e_results) do
      add_column :created_at, Time, { default: nil }
      add_column :updated_at, Time, { default: nil }
    end
  end
end
