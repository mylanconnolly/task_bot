# frozen_string_literal: true

module ActiveJob
  module TaskBot
    # This is the ActiveJob adapter that provides the ActiveJob interface.
    class Adapter
      attr_reader :client

      def initialize(project: nil, location: nil, worker_url: nil)
        @client = TaskBot::Client.new(
          project: project,
          location: location,
          worker_url: worker_url
        )
      end

      def enqueue(job, attributes = {})
        client.add_task(job, attributes)
      end

      def enqueue_at(job, scheduled_at)
        enqueue(job, scheduled_at: scheduled_at)
      end
    end
  end
end
