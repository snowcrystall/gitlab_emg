# frozen_string_literal: true

module Repositories
  class LfsApiController < Repositories::GitHttpClientController
    include LfsRequest
    include Gitlab::Utils::StrongMemoize

    LFS_TRANSFER_CONTENT_TYPE = 'application/octet-stream'

    skip_before_action :lfs_check_access!, only: [:deprecated]
    before_action :lfs_check_batch_operation!, only: [:batch]

    # added here as a part of the refactor, will be removed
    # https://gitlab.com/gitlab-org/gitlab/-/issues/328692
    delegate :deploy_token, :user, to: :authentication_result, allow_nil: true

    def batch
      unless objects.present?
        render_lfs_not_found
        return
      end

      if download_request?
        render json: { objects: download_objects! }, content_type: LfsRequest::CONTENT_TYPE
      elsif upload_request?
        render json: { objects: upload_objects! }, content_type: LfsRequest::CONTENT_TYPE
      else
        raise "Never reached"
      end
    end

    def deprecated
      render(
        json: {
          message: _('Server supports batch API only, please update your Git LFS client to version 1.0.1 and up.'),
          documentation_url: "#{Gitlab.config.gitlab.url}/help"
        },
        content_type: LfsRequest::CONTENT_TYPE,
        status: :not_implemented
      )
    end

    private

    def download_request?
      params[:operation] == 'download'
    end

    def upload_request?
      params[:operation] == 'upload'
    end

    def download_objects!
      existing_oids = project.lfs_objects_oids(oids: objects_oids)

      objects.each do |object|
        if existing_oids.include?(object[:oid])
          object[:actions] = download_actions(object)

          if Guest.can?(:download_code, project)
            object[:authenticated] = true
          end
        else
          object[:error] = {
            code: 404,
            message: _("Object does not exist on the server or you don't have permissions to access it")
          }
        end
      end

      objects
    end

    def upload_objects!
      existing_oids = project.lfs_objects_oids(oids: objects_oids)

      objects.each do |object|
        object[:actions] = upload_actions(object) unless existing_oids.include?(object[:oid])
      end

      objects
    end

    def download_actions(object)
      {
        download: {
          href: "#{project.http_url_to_repo}/gitlab-lfs/objects/#{object[:oid]}",
          header: {
            Authorization: authorization_header
          }.compact
        }
      }
    end

    def upload_actions(object)
      {
        upload: {
          href: "#{upload_http_url_to_repo}/gitlab-lfs/objects/#{object[:oid]}/#{object[:size]}",
          header: upload_headers
        }
      }
    end

    # Overridden in EE
    def upload_http_url_to_repo
      project.http_url_to_repo
    end

    def upload_headers
      {
        Authorization: authorization_header,
        # git-lfs v2.5.0 sets the Content-Type based on the uploaded file. This
        # ensures that Workhorse can intercept the request.
        'Content-Type': LFS_TRANSFER_CONTENT_TYPE,
        'Transfer-Encoding': 'chunked'
      }
    end

    def lfs_check_batch_operation!
      if batch_operation_disallowed?
        render(
          json: {
            message: lfs_read_only_message
          },
          content_type: LfsRequest::CONTENT_TYPE,
          status: :forbidden
        )
      end
    end

    # Overridden in EE
    def batch_operation_disallowed?
      upload_request? && Gitlab::Database.read_only?
    end

    # Overridden in EE
    def lfs_read_only_message
      _('You cannot write to this read-only GitLab instance.')
    end

    def authorization_header
      strong_memoize(:authorization_header) do
        lfs_auth_header || request.headers['Authorization']
      end
    end

    def lfs_auth_header
      return unless user

      Gitlab::LfsToken.new(user).basic_encoding
    end
  end
end

Repositories::LfsApiController.prepend_mod_with('Repositories::LfsApiController')
