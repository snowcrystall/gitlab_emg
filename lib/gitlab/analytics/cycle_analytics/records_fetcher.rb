# frozen_string_literal: true

module Gitlab
  module Analytics
    module CycleAnalytics
      class RecordsFetcher
        include Gitlab::Utils::StrongMemoize
        include StageQueryHelpers
        include Gitlab::CycleAnalytics::MetricsTables

        MAX_RECORDS = 20

        MAPPINGS = {
          Issue => {
            serializer_class: AnalyticsIssueSerializer,
            includes_for_query: { project: { namespace: [:route] }, author: [] },
            columns_for_select: %I[title iid id created_at author_id project_id]
          },
          MergeRequest => {
            serializer_class: AnalyticsMergeRequestSerializer,
            includes_for_query: { target_project: [:namespace], author: [] },
            columns_for_select: %I[title iid id created_at author_id state_id target_project_id]
          }
        }.freeze

        delegate :subject_class, to: :stage

        def initialize(stage:, query:, params: {})
          @stage = stage
          @query = query
          @params = params
          @sort = params[:sort] || :end_event
          @direction = params[:direction] || :desc
          @page = params[:page] || 1
          @per_page = MAX_RECORDS
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def serialized_records
          strong_memoize(:serialized_records) do
            records = ordered_and_limited_query.select(*columns, *time_columns)

            yield records if block_given?
            records = preload_associations(records)

            records.map do |record|
              project = record.project
              attributes = record.attributes.merge({
                project_path: project.path,
                namespace_path: project.namespace.route.path,
                author: record.author
              })
              serializer.represent(attributes)
            end
          end
        end
        # rubocop: enable CodeReuse/ActiveRecord

        private

        attr_reader :stage, :query, :params, :sort, :direction, :page, :per_page

        def columns
          MAPPINGS.fetch(subject_class).fetch(:columns_for_select).map do |column_name|
            subject_class.arel_table[column_name]
          end
        end

        def serializer
          MAPPINGS.fetch(subject_class).fetch(:serializer_class).new
        end

        def ordered_and_limited_query
          strong_memoize(:ordered_and_limited_query) do
            order_by(query, sort, direction, columns).page(page).per(per_page).without_count
          end
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def preload_associations(records)
          # using preloader instead of includes to avoid AR generating a large column list
          ActiveRecord::Associations::Preloader.new.preload(
            records,
            MAPPINGS.fetch(subject_class).fetch(:includes_for_query)
          )

          records
        end

        # rubocop: enable CodeReuse/ActiveRecord
        def time_columns
          [
            stage.start_event.timestamp_projection.as('start_event_timestamp'),
            end_event_timestamp_projection.as('end_event_timestamp'),
            round_duration_to_seconds.as('total_time')
          ]
        end
      end
    end
  end
end

Gitlab::Analytics::CycleAnalytics::RecordsFetcher.prepend_mod_with('Gitlab::Analytics::CycleAnalytics::RecordsFetcher')
