# frozen_string_literal: true

require 'google/cloud/tasks'

module TaskBot
  # This is the actual client to the Google Cloud Tasks service. It is designed
  # to mostly work with ActiveJob, so the job in add_task would be something
  # like what ActiveJob would send.
  #
  # Otherwise, this could be used independently from ActiveJob, which should
  # make testing a bit easier.
  class Client
    attr_reader :project, :location, :client, :worker_url, :prefix

    def initialize(project: nil, location: nil, worker_url: nil, prefix: nil)
      @worker_url = worker_url
      @project = project
      @location = location
      @prefix = prefix
      @client = Google::Cloud::Tasks.cloud_tasks
    end

    def add_task(job, attributes = {})
      task = to_task(job, attributes[:scheduled_at])
      client.create_task(task: task, parent: parent(job.queue_name))
    end

    private

    def to_task(job, scheduled)
      task = {
        http_request: {
          http_method: 'POST',
          url: "#{worker_url}/perform?job=#{job.class}",
          body: job.arguments.to_param
        }
      }

      task[:schedule_time] = new_timestamp(scheduled.to_i) if scheduled.present?
      task
    end

    def new_timestamp(seconds)
      Google::Protobuf::Timestamp.new(seconds: seconds)
    end

    def parent(queue)
      queue_name = @prefix.nil? ? queue : "#{@prefix}-#{queue}"
      client.queue_path(project: project, location: location, queue: queue_name)
    end
  end
end
