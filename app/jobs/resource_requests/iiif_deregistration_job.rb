# frozen_string_literal: true

module ResourceRequests
  class IiifDeregistrationJob < AbstractJob
    include ResourceRequestJobs::IiifJobBehaviors

    @queue = :image_syndication

    def self.create_resource_request(digital_object, resource)
      exist_check_conditions = { digital_object_uid: digital_object.uid, status: ['pending', 'in_progress'] }
      return if ResourceRequest.iiif_deregistration.exists?(exist_check_conditions)

      # although src_file_location is not necessary to remove, it facilitates validations
      base_resource_request_args = { digital_object_uid: digital_object.uid, src_file_location: resource_location_uri(resource) }
      base_resource_request_args[:additional_creation_commit_callback] = proc { |resource_request| submit_triclops_request(resource_request, digital_object) }
      ResourceRequest.iiif_deregistration.create!(base_resource_request_args)
    end

    def self.submit_triclops_request(resource_request, _digital_object)
      Hyacinth::Config.triclops.with_connection_and_opts do |connection, options|
        response = connection.delete("/api/v1/resources/#{resource_request.digital_object_uid}.json")

        log_response(response, resource_request.digital_object_uid, resource_request.job_type, options)

        resource_request.update_attribute!(status: response.status == 200 ? 'success' : 'failure')
      end
    rescue Faraday::ConnectionFailed
      Rails.logger.info("Unable to connect to Triclops, so #{resource_request.job_type} resource request for #{resource_request.digital_object_uid} was skipped.")
    end

    def self.eligible_object?(digital_object)
      return false unless digital_object&.is_a?(::DigitalObject::Asset)
    end
  end
end
