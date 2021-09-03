# frozen_string_literal: true

module ResourceRequests
  class AccessJob < AbstractJob
    include ResourceRequestJobs::DerivativoJobBehaviors

    @queue = :resource_requests_access

    # Mapping for how many degrees to rotate by to create an upright orientation.
    # Note: Only handling non-mirrored rotations for now.
    EXIF_ORIENTATION_TO_REQUIRED_ROTATION = {
      # non-mirrored orientations
      1 => '0',
      3 => '180',
      6 => '90',
      8 => '270',
      # mirrored orientations
      2 => '!0',
      4 => '!180',
      5 => '!90',
      7 => '!270'
    }.freeze

    def self.create_resource_request(digital_object, resource)
      job_type = job_type_for_resource(resource)
      return if job_type.nil?
      exist_check_conditions = { digital_object_uid: digital_object.uid, status: ['pending', 'in_progress'] }
      return if ResourceRequest.send(job_type).exists?(exist_check_conditions)

      base_resource_request_args = generate_base_resource_request_args(digital_object, resource)
      base_resource_request_args[:create_callback] = proc { |resource_request| create_callback(resource_request, digital_object) }
      ResourceRequest.send(job_type).create!(base_resource_request_args)
    end

    def self.generate_base_resource_request_args(digital_object, resource)
      base_resource_request_args = {
        digital_object_uid: digital_object.uid,
        src_file_location: resource_location_uri(resource),
        options: {}
      }
      base_resource_request_args[:options][:rotation] = exif_orientation_to_rotation(digital_object.exif_orientation) if resource.image?
      base_resource_request_args
    end

    def self.job_type_for_resource(resource)
      job_type_suffix = ['image', 'video', 'audio', 'pdf', 'text_or_office_document'].find { |resource_type| resource.send("#{resource_type}?") }
      return nil if job_type_suffix.nil?

      "access_for_#{job_type_suffix}"
    end

    def self.exif_orientation_to_rotation(exif_orientation)
      EXIF_ORIENTATION_TO_REQUIRED_ROTATION[exif_orientation.to_i] || 0
    end

    def self.src_resource_for_digital_object(digital_object)
      # Try to use service resource, but fall back to main resource
      digital_object.service_resource || digital_object.main_resource
    end

    def self.eligible_object?(digital_object)
      return false unless digital_object.is_a?(::DigitalObject::Asset) # must be an Asset
      return false if digital_object.has_access_resource? # already generated access, so nothing to do
      return false if src_resource_for_digital_object(digital_object).nil? # no source to use
      true
    end
  end
end
