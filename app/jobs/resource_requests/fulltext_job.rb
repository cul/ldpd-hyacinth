# frozen_string_literal: true

module ResourceRequests
  class FulltextJob < AbstractJob
    include ResourceRequestJobs::DerivativoJobBehaviors

    queue_as :resource_requests_fulltext

    def self.create_resource_request(digital_object, resource)
      exist_check_conditions = { digital_object_uid: digital_object.uid, status: ['pending', 'in_progress'] }
      return if ResourceRequest.fulltext.exists?(exist_check_conditions)
      base_resource_request_args = { digital_object_uid: digital_object.uid, src_file_location: resource_location_uri(resource) }
      base_resource_request_args[:additional_creation_commit_callback] = proc { |resource_request| submit_derivativo_request(resource_request, digital_object) }
      ResourceRequest.fulltext.create!(base_resource_request_args)
    end

    def self.src_resource_for_digital_object(digital_object)
      digital_object.main_resource
    end

    def self.eligible_object?(digital_object)
      return false unless digital_object.is_a?(::DigitalObject::Asset)
      return false if digital_object.has_fulltext_resource?
      return false if src_resource_for_digital_object(digital_object).nil? # no source to use
      true
    end
  end
end
