# frozen_string_literal: true

module ResourceRequests
  class IiifRegistrationJob < AbstractJob
    include ResourceRequestJobs::IiifJobBehaviors

    @queue = :image_syndication

    def self.create_resource_request(digital_object, resource)
      exist_check_conditions = { digital_object_uid: digital_object.uid, status: ['pending', 'in_progress'] }
      return if ResourceRequest.iiif_registration.exists?(exist_check_conditions)

      base_resource_request_args = { digital_object_uid: digital_object.uid, src_file_location: resource_location_uri(resource) }
      base_resource_request_args[:create_callback] = proc { |resource_request| create_callback(resource_request, digital_object) }
      ResourceRequest.iiif_registration.create!(base_resource_request_args) unless ResourceRequest.iiif_registration.exists?(exist_check_conditions)
    end

    def self.create_callback(resource_request, digital_object)
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
  end
end
