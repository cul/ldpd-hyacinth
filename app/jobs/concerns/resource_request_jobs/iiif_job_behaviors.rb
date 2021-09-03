# frozen_string_literal: true

module ResourceRequestJobs
  module IiifJobBehaviors
    extend ActiveSupport::Concern

    class_methods do
      def src_resource_for_digital_object(digital_object)
        digital_object.asset_type == 'Image' ? digital_object.access_resource : digital_object.poster_resource
      end

      def eligible_object?(digital_object)
        return false unless digital_object&.is_a?(::DigitalObject::Asset)
        if digital_object.asset_type == 'Image'
          digital_object.has_access_resource?
        else
          digital_object.has_poster_resource?
        end
      end

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
end
