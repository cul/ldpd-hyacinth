class UpdateImageServiceJob < ActiveJob::Base
  queue_as Hyacinth::Queue::IMAGE_SERVICE

  def perform(digital_object_pid)
    asset = DigitalObject::Base.find_by_pid(digital_object_pid)
    return unless eligible_asset?(asset)

    RestClient.put(
      "#{IMAGE_SERVER_CONFIG[:url]}/api/v1/resources/#{asset.pid}",
      payload_for_image_service_update_request(asset),
      Authorization: "Bearer #{IMAGE_SERVER_CONFIG[:token]}"
    )
  rescue RestClient::BadRequest => e
    Rails.logger.error('Received Bad Request response from the image server: ' + JSON.parse(e.http_body)['errors'].inspect)
  # rescue RestClient::InternalServerError => e
  #   Rails.logger.error('Received Internal Server Error response from the image server: ' + JSON.parse(e.http_body)['errors'].inspect)
  rescue Errno::ECONNREFUSED
    # Silently fail because the image server is currently unavailable and there is nothing we can do.
  end

  def payload_for_image_service_update_request(asset)
    {
      resource: {
        source_uri: image_source_uri_for_digital_object(asset),
        featured_region: asset.featured_region,
        # Supply pcdm type for MAIN resource (not access / poster)
        pcdm_type: asset.pcdm_type,
        has_view_limitation: asset.restricted_size_image
      }
    }
  end

  def image_source_uri_for_digital_object(asset)
    return nil unless asset.is_a?(DigitalObject::Asset)
    # If ALL derivative processing has not completed yet, we do not want to send a source_uri
    # value to the image service.  This check prevents a situation where an asset may have
    # successfully generated an access copy, but that access copy has not yet gone through
    # automatic featured region detection.
    return nil if asset.perform_derivative_processing
    return Addressable::URI.encode("file://#{asset.poster_location}") unless asset.poster_location.nil?
    return nil if asset.access_copy_location.nil?
    # Note that in the line below
    return Addressable::URI.encode("file://#{asset.access_copy_location}") if
      BestType.pcdm_type.for_file_name(asset.access_copy_location) == BestType::PcdmTypeLookup::IMAGE
    nil
  end

  def eligible_asset?(asset)
    # If the digital object was not found, that means the object was deleted some time
    # since this job was queued.  So we'll return immediately.
    return false if asset.nil?

    # Non-assets are not eligible
    return false unless asset.is_a?(DigitalObject::Asset)

    true
  end
end
