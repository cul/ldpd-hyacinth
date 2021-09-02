# frozen_string_literal: true

module ResourceRequests
  class IiifRegistrationJob < AbstractJob
    include ResourceRequestJobs::IiifJobBehaviors

    @queue = :image_syndication

    def self.create_resource_request(digital_object, resource)
      base_resource_request_args = { digital_object_uid: digital_object.uid, src_file_location: resource_location_uri(resource) }
      base_resource_request_args[:options] = {
        params: {
          featured_thumbnail_region: digital_object.featured_thumbnail_region
        }
      }
      exist_check_conditions = { digital_object_uid: digital_object.uid, status: ['pending', 'in_progress'] }
      ResourceRequest.iiif_registration.create!(base_resource_request_args) unless ResourceRequest.iiif_registration.exists?(exist_check_conditions)
    end
  end
end
