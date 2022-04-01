# frozen_string_literal: true

class AddIndexOnTerraformStatesFileStore < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :terraform_states, :file_store
  end

  def down
    remove_concurrent_index :terraform_states, :file_store
  end
end
