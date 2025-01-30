module Hyacinth::DigitalObjects::Downloads
  def download
    if @digital_object.is_a?(DigitalObject::Asset)
      # This endpoint should not support range requests.
      if request.headers['Range'].present?
        render plain: 'This endpoint does not allow range requests (using the http Range header).'
        return
      end

      storage_object = Hyacinth::Storage.storage_object_for(
        @digital_object.fedora_object.datastreams['content'].dsLocation
      )

      if storage_object.is_a?(Hyacinth::Storage::FileObject)
        use_send_file_for_local_file_storage_object(storage_object)
      else
        use_action_controller_live_streaming_for_storage_object(storage_object, response)
      end
    else
      render plain: @digital_object.digital_object_type.display_label.pluralize + ' do not have download URLs.  Try downloading an Asset instead.'
    end
  end

  # private
  def use_send_file_for_local_file_storage_object(storage_object)
    send_file storage_object.path, filename: storage_object.filename, type: storage_object.content_type
  end

  # private
  # Note: This method has issues with downloading small local disk files, so we're using
  # use_send_file_for_local_file_storage_object for local disk files.
  def use_action_controller_live_streaming_for_storage_object(storage_object, resp)
    # NOTE: Content-Length header can't be set for stream.  Even when it is set, Content-Length shows up as "0".
    # resp.headers['Content-Length'] = storage_object.size
    resp.headers['Content-Disposition'] = label_to_content_disposition(storage_object.filename, true)
    # resp.headers['Content-Type'] = 'text/event-stream'
    resp.headers['Content-Type'] = storage_object.content_type
    resp.headers['Last-Modified'] = Time.now.httpdate
    resp.headers['Cache-Control'] = 'no-cache'
    resp.status = :ok

    # The streaming implementation download implementation should be re-evaluated once we move to Rails 8.1.
    # See: https://github.com/rack/rack/issues/1619
    # Specifically: https://github.com/rack/rack/issues/1619#issuecomment-2479907019
    storage_object.read do |chunk|
      # If client disconnects, stop streaming.  This prevents wasteful additional file reading,
      # and for S3 streams it prevents a Aws::S3::Plugins::NonRetryableStreamingError.
      break unless resp.stream.connected?
      resp.stream.write(chunk)

      # Fix for local file downloads hanging when using local Puma rails server. Allow thread to switch as needed
      # during the download.  Also prevents server instance from sleeping forever if client disconnects during download.
      # See: https://gist.github.com/njakobsen/6257887
      # Note: Thread.pass doesn't appear to be necessary when streaming S3 objects. Only local files.
      Thread.pass
    end
  ensure
    # Always close the stream, even if the client disconnects early
    resp.stream.close
  end

  def download_service_copy
    if @digital_object.is_a?(DigitalObject::Asset)
      if @digital_object.fedora_object.datastreams['service'].controlGroup == 'M'
        send_data @digital_object.fedora_object.datastreams['service'].content,
                  filename: @digital_object.fedora_object.datastreams['service'].dsLabel
      else
        send_file @digital_object.service_copy_location, filename: @digital_object.fedora_object.datastreams['service'].dsLabel
      end
    else
      render plain: @digital_object.digital_object_type.display_label.pluralize + ' do not have download URLs.  Try downloading an Asset service copy instead.'
    end
  end

  def download_poster
    if @digital_object.is_a?(DigitalObject::Asset)
        send_file @digital_object.poster_location, filename: @digital_object.fedora_object.datastreams['poster'].dsLabel
    else
      render plain: @digital_object.digital_object_type.display_label.pluralize + ' do not have download URLs.  Try downloading an Asset poster instead.'
    end
  end

  # The download_access_copy action offers the ability to stream files using range requests (for progressive
  # download) because access copies are sometimes played in a video player.
  def download_access_copy
    if @digital_object.is_a?(DigitalObject::Asset)
      access_ds = @digital_object.fedora_object&.datastreams&.fetch('access')
      raise Hyacinth::Exceptions::NotFoundError, "No access copy location available for #{@digital_object.pid}" unless access_ds.dsLocation
      access_file_path = Hyacinth::Utils::UriUtils.location_uri_to_file_path(access_ds.dsLocation)
      raise Hyacinth::Exceptions::NotFoundError, "Access copy file not found at expected location for #{@digital_object.pid}" unless File.exist?(access_file_path)

      label = access_ds.dsLabel.present? ? access_ds.dsLabel.split('/').last : 'file' # Use dsLabel as download label if available
      response.headers["Content-Disposition"] = label_to_content_disposition(label, (params['download'].to_s == 'true'))
      response.headers["Content-Type"] = BestType.mime_type.for_file_name(access_file_path)
      response.headers["Last-Modified"] = Time.now.httpdate

      file_size = File.size(access_file_path)

      # Handle range requests, for progressive download
      response.headers['Accept-Ranges'] = 'bytes' # Inform client that we accept range requests
      from = 0
      to = file_size - 1
      success_status = :ok
      if request.headers['Range'].present?
        # Example Range header value: "bytes=18022400-37581888"
        range_matchdata = request.headers['Range'].match(/bytes=(\d+)-(\d+)*/)
        if range_matchdata
          from = range_matchdata.captures[0].to_i
          if range_matchdata.captures.length > 1 && range_matchdata.captures[1].present?
            to = range_matchdata.captures[1].to_i
          end
          length = (to - from) + 1 # Adding 1 because to and from are zero-indexed
          success_status = :partial_content # override success status because we will only be returning partial content (i.e. a range)
          response.headers["Content-Range"] = "bytes #{from}-#{to}/#{file_size}"
          response.headers["Cache-Control"] = 'no-cache' # don't cache range requests
        end
      end

      content_length = to - from + 1
      response.headers['Content-Length'] = content_length
      response.status = success_status
      response.stream.write IO.binread(access_file_path, content_length, from)
    else
      render plain: @digital_object.digital_object_type.display_label.pluralize + ' do not have download URLs.  Try downloading an Asset instead.'
    end
  ensure
    response.stream.close
  end

  private

    # translate a label into a rfc5987 encoded header value
    # see also http://tools.ietf.org/html/rfc5987#section-4.1
    def label_to_content_disposition(label, attachment = false)
      value = attachment ? 'attachment; ' : 'inline'
      value << "; filename*=utf-8''#{label.gsub(' ', '%20').gsub(',', '%2C')}"
      value
    end
end
