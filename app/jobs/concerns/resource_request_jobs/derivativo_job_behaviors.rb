# frozen_string_literal: true

module ResourceRequestJobs
  module DerivativoJobBehaviors
    extend ActiveSupport::Concern

    class_methods do
      def submit_derivativo_request(resource_request, _digital_object)
        Hyacinth::Config.derivativo.with_connection_and_opts(resource_request.job_type, resource_request.options) do |connection, options|
          job_params = {
            job_type: resource_request.job_type, resource_request_id: resource_request.id,
            digital_object_uid: resource_request.digital_object_uid, src_file_location: resource_request.src_file_location,
            options: options
          }
          response = connection.post('/api/v1/resource_request_jobs') { |req| req.params['resource_request_job'] = job_params }
          resource_request.update!(status: 'failure') unless response.status == 200
        end
      rescue Faraday::ConnectionFailed
        Rails.logger.info("Unable to connect to Derivativo, so #{resource_request.job_type} resource request for #{resource_request.digital_object_uid} was skipped.")
      end

      def log_response(response, digital_object_uid, job_type, options)
        case response.status
        when 200 # "okay"
          Rails.logger.debug("Successfully submitted Derivativo #{job_type} resource request for #{digital_object_uid} with options #{options}.")
        when 400 # "bad request"
          Rails.logger.error(
            "Received 400 bad request response from Derivativo for #{job_type} resource request for #{digital_object_uid} with options #{options.inspect}. Response body: #{response.body}"
          )
        else
          Rails.logger.error("Received unexpected response for Derivativo resource request of type #{job_type} for #{digital_object_uid} with options #{options.inspect}. Status = #{response.status}")
        end
      end
    end
  end
end
