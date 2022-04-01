# frozen_string_literal: true

class AddForeignKeyToPagesDeploymentIdInProjectPagesMetadata < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INDEX_NAME = 'index_project_pages_metadata_on_pages_deployment_id'

  disable_ddl_transaction!

  def up
    add_concurrent_index(:project_pages_metadata, :pages_deployment_id, name: INDEX_NAME)
    add_concurrent_foreign_key :project_pages_metadata, :pages_deployments, column: :pages_deployment_id, on_delete: :nullify
  end

  def down
    remove_foreign_key_if_exists :project_pages_metadata, column: :pages_deployment_id
    remove_concurrent_index_by_name(:project_pages_metadata, INDEX_NAME)
  end
end
