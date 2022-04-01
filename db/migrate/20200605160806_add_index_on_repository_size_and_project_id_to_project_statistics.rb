# frozen_string_literal: true

class AddIndexOnRepositorySizeAndProjectIdToProjectStatistics < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :project_statistics, [:repository_size, :project_id]
  end

  def down
    remove_concurrent_index :project_statistics, [:repository_size, :project_id]
  end
end
