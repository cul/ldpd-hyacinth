# frozen_string_literal: true

module ResourceRequests
  class IiifRegistrationJob < AbstractJob
    include ResourceRequestJobs::IiifJobBehaviors

    queue_as :iiif_registration

    def self.create_resource_request(digital_object, resource)
      exist_check_conditions = { digital_object_uid: digital_object.uid, status: ['pending', 'in_progress'] }
      return if ResourceRequest.iiif_registration.exists?(exist_check_conditions)

      base_resource_request_args = { digital_object_uid: digital_object.uid, src_file_location: resource_location_uri(resource) }
      base_resource_request_args[:additional_creation_commit_callback] = proc { |resource_request| submit_triclops_request(resource_request, digital_object) }
      ResourceRequest.iiif_registration.create!(base_resource_request_args) unless ResourceRequest.iiif_registration.exists?(exist_check_conditions)
    end

    def self.submit_triclops_request(resource_request, digital_object)
      Hyacinth::Config.triclops.with_connection_and_opts do |connection, options|
        response = connection.post('/api/v1/resources.json') do |req|
          req.params['resource'] = {
            identifier: digital_object.uid,
            location_uri: resource_request.src_file_location,
            featured_region: digital_object.featured_thumbnail_region
          }
        end

        log_response(response, resource_request.digital_object_uid, resource_request.job_type, options)

        resource_request.update_attribute!(status: response.status == 200 ? 'success' : 'failure')
      end
    rescue Faraday::ConnectionFailed
      Rails.logger.info("Unable to connect to Triclops, so #{resource_request.job_type} resource request for #{resource_request.digital_object_uid} was skipped.")
    end

    def self.eligible_object?(digital_object)
      return false unless digital_object&.is_a?(::DigitalObject::Asset)
      return false if digital_object.featured_thumbnail_region.blank?
      if digital_object.asset_type == 'Image'
        digital_object.has_access_resource?
      else
        digital_object.has_poster_resource?
      end
    end
  end
end
