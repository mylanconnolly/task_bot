# frozen_string_literal: true

require 'json'
require 'rack'

module TaskBot
  # This is the Rack app designed to process jobs. Currently it returns a 404
  # if it doesn't look like we're being asked to perform a job. If the job runs
  # and does not crash, we return a 200.
  class Rack
    class << self
      def call(env)
        return not_found unless env['PATH_INFO'].match(%r{^/perform})

        begin
          handle_request(env)
        rescue TaskBot::MissingJobError
          unprocessable_entity('Missing job type')
        rescue TaskBot::UnknownJobError
          unprocessable_entity('Unknown job type')
        rescue StandardError
          internal_server_error('Failure processing job')
        end
      end

      private

      def handle_request(env)
        case env['REQUEST_METHOD']
        when 'GET' then handle_get(env)
        when 'POST' then handle_post(env)
        else not_found
        end
      end

      def get_job(params)
        raise TaskBot::MissingJobError unless params.key?(:job)

        constantize(params[:job])
      end

      def handle_get(env)
        params = symbolize_keys(Hash[URI.decode_www_form(env['QUERY_STRING'])])
        get_job(params).perform_now(params)
        ok
      end

      def handle_post(env)
        params = symbolize_keys(Hash[URI.decode_www_form(env['rack.input'].read)])
        get_job(params).perform_now(params)
        ok
      end

      def unprocessable_entity(message = nil)
        rack_resp(422, message || 'unprocessable entity')
      end

      def internal_server_error(message = nil)
        rack_resp(500, message || 'internal server error')
      end

      # Return a simple 404 error.
      def not_found
        rack_resp(404, 'not found')
      end

      # Return a simple 200 response.
      def ok
        rack_resp(200, 'ok')
      end

      def rack_resp(code, body, headers = {})
        [code, headers, [body]]
      end

      def symbolize_keys(hash)
        JSON.parse(hash.to_json, symbolize_names: true)
      end

      # Attempt to get the class of the given job.
      def constantize(job)
        Kernel.const_get(job)
      rescue NameError
        raise TaskBot::UnknownJobError
      end
    end
  end
end
