# frozen_string_literal: true

module AuthorizedProjectUpdate
  class ProjectRecalculateWorker
    include ApplicationWorker

    data_consistency :always
    include Gitlab::ExclusiveLeaseHelpers

    feature_category :authentication_and_authorization
    urgency :high
    queue_namespace :authorized_project_update

    deduplicate :until_executing, including_scheduled: true
    idempotent!

    def perform(project_id)
      project = Project.find_by_id(project_id)
      return unless project

      in_lock(lock_key(project), ttl: 10.seconds) do
        AuthorizedProjectUpdate::ProjectRecalculateService.new(project).execute
      end
    end

    private

    def lock_key(project)
      "#{self.class.name.underscore}/projects/#{project.id}"
    end
  end
end
