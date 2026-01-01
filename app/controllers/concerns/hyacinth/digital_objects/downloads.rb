module Hyacinth::DigitalObjects::Downloads
  def download
    resource_name = params['resource_name']

    unless DigitalObject::Asset::VALID_RESOURCE_TYPES.include?(resource_name)
      render plain: "Invalid resource: #{resource_name}"
      return
    end

    unless @digital_object.is_a?(DigitalObject::Asset)
      render plain: @digital_object.digital_object_type.display_label.pluralize + ' do not have download URLs.  Try downloading an Asset instead.'
    end

    location_uri = @digital_object.location_uri_for_resource(resource_name)
    storage_object = Hyacinth::Storage.storage_object_for(location_uri)

    # Inform client that we accept range requests
    response.headers['Accept-Ranges'] = 'bytes'

    file_size = storage_object.size
    is_range_request = request.headers['Range'].present?
    from, to = byte_range_to_return(request.headers['Range'], file_size)

    Rails.logger.debug("Downloading #{resource_name} copy with range: #{from}-#{to} (full file size = #{file_size})")

    if storage_object.is_a?(Hyacinth::Storage::FileObject) && !is_range_request
      # Rails streaming sometimes runs into issues with full file downloads for small, local disk files,
      # so we'll prefer using send_file for those cases.
      # We can revisit this once we move to Rails 8.1, which fixes some file streaming issues.
      # See: https://github.com/rack/rack/issues/1619
      # Specifically: https://github.com/rack/rack/issues/1619#issuecomment-2479907019
      send_file storage_object.path, filename: storage_object.filename, type: storage_object.content_type
    else
      stream_storage_object(storage_object, response, is_range_request, from, to, file_size)
    end
  end

  # Parses the range header and returns `from` and `to` byte indexes.
  # If the range_header_value is nil or an empty string, this method returns the full file range
  # from byte 0 to byte file_size-1.
  # @return Array<Integer>  An array of length 2, holding the `from` byte index at element 0
  #                         and the `to` byte index at element 1.
  def byte_range_to_return(range_header_value, file_size)
    from = 0
    to = file_size - 1

    if range_header_value.present?
      range_matchdata = range_header_value.match(/bytes=(\d+)-(\d+)*/)
      if range_matchdata
        from = range_matchdata.captures[0].to_i
        if range_matchdata.captures.length > 1 && range_matchdata.captures[1].present?
          to = range_matchdata.captures[1].to_i
        end
      end
    end

    [from, to]
  end

  # private
  # Note: This method has issues with downloading small local disk files, so we're using
  # send_file for local disk files.
  def stream_storage_object(storage_object, resp, is_range_request, from, to, file_size)
    # NOTE: Content-Length header can't be set for stream.  Even when it is set, Content-Length shows up as "0".
    # resp.headers['Content-Length'] = storage_object.size

    resp.headers['Content-Disposition'] = label_to_content_disposition(storage_object.filename, true)
    resp.headers['Content-Type'] = storage_object.content_type
    resp.headers['Last-Modified'] = Time.now.httpdate
    resp.headers['Cache-Control'] = 'no-cache' # don't cache streamed files

    if is_range_request
      response.headers["Content-Range"] = "bytes #{from}-#{to}/#{file_size}"
      resp.status = :partial_content
    else
      resp.status = :ok
    end

    # The streaming implementation download implementation should be re-evaluated once we move to Rails 8.1.
    # See: https://github.com/rack/rack/issues/1619
    # Specifically: https://github.com/rack/rack/issues/1619#issuecomment-2479907019
    storage_object.read_range(from, to) do |chunk|
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

  private

    # translate a label into a rfc5987 encoded header value
    # see also http://tools.ietf.org/html/rfc5987#section-4.1
    def label_to_content_disposition(label, attachment = false)
      value = attachment ? 'attachment; ' : 'inline'
      value << "; filename*=utf-8''#{label.gsub(' ', '%20').gsub(',', '%2C')}"
      value
    end
end
