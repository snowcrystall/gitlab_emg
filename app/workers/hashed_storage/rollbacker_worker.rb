# frozen_string_literal: true

module HashedStorage
  class RollbackerWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker

    data_consistency :always

    sidekiq_options retry: 3

    queue_namespace :hashed_storage
    feature_category :source_code_management

    # Gitlab::HashedStorage::Migrator#rollback_pending? depends on the
    # queue size of this worker.
    tags :exclude_from_gitlab_com, :needs_own_queue

    # @param [Integer] start initial ID of the batch
    # @param [Integer] finish last ID of the batch
    def perform(start, finish)
      migrator = Gitlab::HashedStorage::Migrator.new
      migrator.bulk_rollback(start: start, finish: finish)
    end
  end
end
