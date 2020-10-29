# frozen_string_literal: true

require 'task_bot/version'
require 'task_bot/client'
require 'task_bot/rack'
require 'active_job/task_bot/adapter'

module TaskBot
  # This represents a generic error within the TaskBot library.
  class Error < StandardError; end

  # This represents an error where we were not supplied with the job to be
  # performed
  class MissingJobError < Error; end

  # This represents an error where we have an unknown job passed in to be
  # performed.
  class UnknownJobError < Error; end
end
