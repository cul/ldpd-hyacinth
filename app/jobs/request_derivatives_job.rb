class RequestDerivativesJob < ActiveJob::Base
  queue_as Hyacinth::Queue::REQUEST_DERIVATIVES

  def perform(digital_object_pid)
    asset = DigitalObject::Base.find_by_pid(digital_object_pid)
    return unless eligible_asset?(asset)

    requested_derivatives = required_derivatives_for_asset(asset)
    return if requested_derivatives.empty?

    if requested_derivatives.present?
      RestClient.post(
        "#{DERIVATIVE_SERVER_CONFIG['url']}/api/v1/derivative_requests.json",
        payload_for_derivative_request(asset, requested_derivatives),
        Authorization: "Bearer #{DERIVATIVE_SERVER_CONFIG['token']}"
      )
    end
  rescue RestClient::BadRequest => e
    Rails.logger.error('Received Bad Request response from the derivative server: ' + JSON.parse(e.http_body)['errors'].inspect)
  rescue Errno::ECONNREFUSED
    # Silently fail because the derivative server is currently unavailable and there is nothing we can do.
  end

  def payload_for_derivative_request(asset, requested_derivatives)
    {
      derivative_request: {
        identifier: asset.pid,
        delivery_target: 'hyacinth2',
        adjust_orientation: asset.fedora_object.orientation,
        main_uri: Addressable::URI.encode("file://#{asset.filesystem_location}"),
        requested_derivatives: requested_derivatives,
        # access_uri can be nil, if no access copy currently exists
        access_uri: asset.access_copy_location.nil? ? nil : Addressable::URI.encode("file://#{asset.access_copy_location}"),
        # poster_uri can be nil, if no poster currently exists
        poster_uri: asset.poster_location.nil? ? nil : Addressable::URI.encode("file://#{asset.poster_location}")
      }
    }
  end

  def eligible_asset?(asset)
    # If the digital object was not found, that means the object was deleted some time
    # since this job was queued.  So we'll return immediately.
    return false if asset.nil?

    # Non-assets are not eligible
    return false unless asset.is_a?(DigitalObject::Asset)

    # If this asset has derivative processing disabled, then it is not eligible
    return false unless asset.perform_derivative_processing

    true
  end

  def required_derivatives_for_asset(asset)
    required_derivatives = []
    # We attempt to generate an access copy for all asset types
    required_derivatives << 'access' if asset.access_copy_location.nil?
    # Note: Image assets do not need a poster image
    required_derivatives << 'poster' if asset.poster_location.nil? && asset.dc_type != 'StillImage'
    # Get featured region
    required_derivatives << 'featured_region' if asset.featured_region.nil?
    required_derivatives
  end
end
