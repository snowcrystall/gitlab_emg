# frozen_string_literal: true

class AddForeignKeyToPipelineIdOnPipelineArtifact < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      add_foreign_key :ci_pipeline_artifacts, :ci_pipelines, column: :pipeline_id, on_delete: :cascade
    end
  end

  def down
    with_lock_retries do
      remove_foreign_key :ci_pipeline_artifacts, column: :pipeline_id
    end
  end
end
