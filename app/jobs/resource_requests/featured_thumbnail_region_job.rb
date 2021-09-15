# frozen_string_literal: true

module ResourceRequests
  class FeaturedThumbnailRegionJob < AbstractJob
    include ResourceRequestJobs::DerivativoJobBehaviors

    @queue = :resource_requests_featured_thumbnail_region

    def self.create_resource_request(digital_object, resource)
      exist_check_conditions = { digital_object_uid: digital_object.uid, status: ['pending', 'in_progress'] }
      return if ResourceRequest.featured_thumbnail_region.exists?(exist_check_conditions)
      base_resource_request_args = { digital_object_uid: digital_object.uid, src_file_location: resource_location_uri(resource) }
      base_resource_request_args[:additional_creation_commit_callback] = proc { |resource_request| submit_derivativo_request(resource_request, digital_object) }
      ResourceRequest.featured_thumbnail_region.create!(base_resource_request_args)
    end

    def self.src_resource_for_digital_object(digital_object)
      # Use access resource for images and poster for non-images
      digital_object.asset_type == 'Image' ? digital_object.access_resource : digital_object.poster_resource
    end

    def self.eligible_object?(digital_object)
      return false unless digital_object.is_a?(::DigitalObject::Asset)
      return false if digital_object.featured_thumbnail_region.present? # region has already been set
      return false if src_resource_for_digital_object(digital_object).nil? # no source to use
      true
    end
  end
end
