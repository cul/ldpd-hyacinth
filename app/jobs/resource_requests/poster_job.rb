# frozen_string_literal: true

module ResourceRequests
  class PosterJob < AbstractJob
    include ResourceRequestJobs::DerivativoJobBehaviors

    queue_as :resource_requests_poster

    def self.create_resource_request(digital_object, resource)
      job_type = job_type_for_resource(resource)
      return if job_type.nil?
      exist_check_conditions = { digital_object_uid: digital_object.uid, status: ['pending', 'in_progress'] }
      return if ResourceRequest.send(job_type).exists?(exist_check_conditions)

      base_resource_request_args = { digital_object_uid: digital_object.uid, src_file_location: resource_location_uri(resource) }
      base_resource_request_args[:additional_creation_commit_callback] = proc { |resource_request| submit_derivativo_request(resource_request, digital_object) }
      ResourceRequest.send(job_type).create!(base_resource_request_args)
    end

    def self.job_type_for_resource(resource)
      job_type_suffix = ['video', 'pdf'].find { |resource_type| resource.send("#{resource_type}?") }
      return nil if job_type_suffix.nil?

      "poster_for_#{job_type_suffix}"
    end

    def self.src_resource_for_digital_object(digital_object)
      digital_object.access_resource
    end

    def self.eligible_object?(digital_object)
      return false unless digital_object.is_a?(::DigitalObject::Asset)
      return false if digital_object.has_poster_resource? # already generated poster, so nothing to do
      return false if digital_object.asset_type == 'Image' # don't want/need to generate posters for images
      return false if src_resource_for_digital_object(digital_object).nil? # no source to use
      true
    end
  end
end
