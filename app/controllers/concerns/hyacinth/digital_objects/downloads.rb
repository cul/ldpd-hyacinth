module Hyacinth::DigitalObjects::Downloads
  include ActionController::Live

  def download
    if @digital_object.is_a?(DigitalObject::Asset)
      # This endpoint should not support range requests.
      if request.headers['Range'].present?
        render plain: 'This endpoint does not allow range requests (using the http Range header).'
        return
      end

      storage_object = Hyacinth::Storage.storage_object_for(
        Hyacinth::Utils::PathUtils.ds_location_to_decoded_location_uri(
          @digital_object.fedora_object.datastreams['content'].dsLocation
        )
      )

      response.headers['Content-Length'] = storage_object.size
      response.status = 200
      response.headers['Content-Type'] = storage_object.content_type
      response.headers["Content-Disposition"] = label_to_content_disposition(storage_object.filename, true)
      # Setting the Last-Modified header to fix streaming bug that affects Rails < 7.1 and rack gem 2.2.x?
      # https://github.com/rack/rack/issues/1619#issuecomment-1510031078
      response.headers["Last-Modified"] = Time.now.httpdate
      storage_object.read do |chunk|
        response.stream.write(chunk)
        # Prevent server instance from sleeping forever if client disconnects during download.
        # See: https://gist.github.com/njakobsen/6257887
        # A value of 0.1 seems to be more reliable than smaller values.
        sleep 0.1
      end
      puts "Done writing"
    else
      render plain: @digital_object.digital_object_type.display_label.pluralize + ' do not have download URLs.  Try downloading an Asset instead.'
    end
  ensure
    # Always close the stream, even if the client disconnects early.
    response.stream.close
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
      access_file_path = Hyacinth::Utils::PathUtils.ds_location_to_filesystem_path(access_ds.dsLocation)
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
