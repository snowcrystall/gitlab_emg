# frozen_string_literal: true

module Gitlab
  class AnonymousSession
    def initialize(remote_ip)
      @remote_ip = remote_ip
    end

    def count_session_ip
      Gitlab::Redis::SharedState.with do |redis|
        redis.pipelined do
          redis.incr(session_lookup_name)
          redis.expire(session_lookup_name, 24.hours)
        end
      end
    end

    def session_count
      Gitlab::Redis::SharedState.with do |redis|
        redis.get(session_lookup_name).to_i
      end
    end

    def cleanup_session_per_ip_count
      Gitlab::Redis::SharedState.with do |redis|
        redis.del(session_lookup_name)
      end
    end

    private

    attr_reader :remote_ip

    def session_lookup_name
      @session_lookup_name ||= "#{Gitlab::Redis::SharedState::IP_SESSIONS_LOOKUP_NAMESPACE}:#{remote_ip}"
    end
  end
end
