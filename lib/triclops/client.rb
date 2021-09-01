# frozen_string_literal: true

module Triclops
  class Client
    def initialize(url:, api_key:, default_job_options:, request_timeout: 120)
      @default_job_options = default_job_options
      @conn = Faraday.new(
        url: url,
        headers: {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json'
        },
        # A longer request timeout can be useful in a development environment when long-running
        # background jobs are running inline.
        request: {
          timeout: request_timeout
        }
      )
      @conn.authorization :Token, token: api_key
    end

    def enqueue_job(job_type:, resource_request_id:, digital_object_uid:, src_file_location:, options: {})
      # Merge default options and provided options (with provided options overwriting default ones)
      options = @default_job_options.fetch(job_type.to_sym, {}).with_indifferent_access.merge(options)

      response = @conn.post('/api/v1/resource_request_jobs') do |req|
        req.params['resource_request_job'] = {
          job_type: job_type, resource_request_id: resource_request_id, digital_object_uid: digital_object_uid, src_file_location: src_file_location, options: options
        }
      end

      log_response(response, digital_object_uid, job_type, options)

      response.status == 200
    rescue Faraday::ConnectionFailed
      Rails.logger.info("Unable to connect to Triclops, so #{job_type} resource request for #{digital_object_uid} was skipped.")
      false
    end

    private

      def log_response(response, digital_object_uid, job_type, options)
        case response.status
        when 200 # "okay"
          Rails.logger.debug("Successfully submitted Triclops #{job_type} resource request for #{digital_object_uid} with options #{options}.")
        when 400 # "bad request"
          Rails.logger.error(
            "Received 400 bad request response from Triclops for #{job_type} resource request for #{digital_object_uid} with options #{options.inspect}. Response body: #{response.body}"
          )
        else
          Rails.logger.error("Received unexpected response for Triclops resource request of type #{job_type} for #{digital_object_uid} with options #{options.inspect}. Status = #{response.status}")
        end
      end
  end
end
