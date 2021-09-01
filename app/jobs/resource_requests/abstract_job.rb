# frozen_string_literal: true

class ResourceRequests::AbstractJob < ApplicationJob
  extend Hyacinth::DigitalObject::ResourceHelper

  def self.perform_later_if_eligible(digital_object)
    perform_later(digital_object.uid) if eligible_object?(digital_object)
  end

  # This method should be overridden by subclasses.
  def self.eligible_object?(_digital_object)
    raise NotImplementedError
  end

  # @param digital_object_uid [Integer] UID for a digital object that should make a resource request.
  def perform(digital_object_uid)
    digital_object = DigitalObject.find_by_uid!(digital_object_uid)
    return unless self.class.eligible_object?(digital_object)

    resource = self.class.src_resource_for_digital_object(digital_object)
    self.class.create_resource_request(digital_object, resource)
  end

  def resource_location_uri(resource)
    Hyacinth::DigitalObject::ResourceHelper.resource_location_uri(resource)
  end
end
