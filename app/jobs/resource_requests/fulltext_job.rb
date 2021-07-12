# frozen_string_literal: true

module ResourceRequests
  class FulltextJob < AbstractJob
    @queue = :resource_requests_fulltext

    # @param digital_object_uid [Integer] UID for a digital object that should make a resource request to Derivativo.
    def perform(digital_object_uid)
      digital_object = DigitalObject.find_by_uid!(digital_object_uid)
      return unless self.class.eligible_object?(digital_object)

      resource = self.class.src_resource_for_digital_object(digital_object)
      self.class.create_resource_request(digital_object, resource)
    end

    def self.create_resource_request(digital_object, resource)
      base_resource_request_args = { digital_object_uid: digital_object.uid, src_file_location: Derivativo::ResourceHelper.resource_location_for_derivativo(resource) }
      exist_check_conditions = { digital_object_uid: digital_object.uid, status: ['pending', 'in_progress'] }
      ResourceRequest.fulltext.create!(base_resource_request_args) unless ResourceRequest.fulltext.exists?(exist_check_conditions)
    end

    def self.src_resource_for_digital_object(digital_object)
      digital_object.master_resource
    end

    def self.eligible_object?(digital_object)
      return false unless digital_object.is_a?(::DigitalObject::Asset)
      return false if digital_object.has_fulltext_resource?
      return false if src_resource_for_digital_object(digital_object).nil? # no source to use
      true
    end
  end
end
