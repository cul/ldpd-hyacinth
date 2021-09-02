# frozen_string_literal: true

module ResourceRequests
  class IiifDeregistrationJob < AbstractJob
    include ResourceRequestJobs::IiifJobBehaviors

    @queue = :image_syndication

    def self.create_resource_request(digital_object, resource)
      # although src_file_location is not necessary to remove, it facilitates validations
      base_resource_request_args = { digital_object_uid: digital_object.uid, src_file_location: resource_location_uri(resource) }
      exist_check_conditions = { digital_object_uid: digital_object.uid, status: ['pending', 'in_progress'] }
      ResourceRequest.iiif_deregistration.create!(base_resource_request_args) unless ResourceRequest.iiif_deregistration.exists?(exist_check_conditions)
    end
  end
end
