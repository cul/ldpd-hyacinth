module Hyacinth::DigitalObjects::Downloads
  include ActionController::Live
  def download
    if @digital_object.is_a?(DigitalObject::Asset)
      if @digital_object.fedora_object.datastreams['content'].controlGroup == 'M'
        send_data @digital_object.fedora_object.datastreams['content'].content,
                  filename: @digital_object.fedora_object.datastreams['content'].dsLabel
      else
        send_file @digital_object.filesystem_location, filename: @digital_object.original_filename
      end
    else
      render text: @digital_object.digital_object_type.display_label.pluralize + ' do not have download URLs.  Try downloading an Asset instead.'
    end
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
      render text: @digital_object.digital_object_type.display_label.pluralize + ' do not have download URLs.  Try downloading an Asset service copy instead.'
    end
  end

  def download_poster
    if @digital_object.is_a?(DigitalObject::Asset)
        send_file @digital_object.poster_location, filename: @digital_object.fedora_object.datastreams['poster'].dsLabel
    else
      render text: @digital_object.digital_object_type.display_label.pluralize + ' do not have download URLs.  Try downloading an Asset poster instead.'
    end
  end

  # download_access_copy offers the ability to stream files using range requests
  # because access copies are sometimes played in a video player
  def download_access_copy
    if @digital_object.is_a?(DigitalObject::Asset)
      # Support range requests for progressive download

      response.headers["Last-Modified"] = Time.now.httpdate
      ds_parms = { pid: @digital_object.pid, dsid: 'access' }

      # Get connection to Fedora
      repo = ActiveFedora::Base.connection_for_pid(ds_parms[:pid])
      ds = Cul::Hydra::Fedora.ds_for_opts(ds_parms)

      # Get size, label and mimetype for this datastream
      size = params[:file_size] || params['file_size']
      size ||= ds.dsSize
      if size.blank? || size == 0
        # Get size of this datastream if we haven't already.  Note: dsSize property won't work for external datastreams
        # From: https://github.com/samvera/rubydora/blob/1e6980aa1ae605677a5ab43df991578695393d86/lib/rubydora/datastream.rb#L423-L428
        repo.datastream_dissemination(ds_parms.merge(method: :head)) do |resp|
          if content_length = resp['Content-Length']
            size = content_length.to_i
          else
            size = resp.body.length
          end
        end
      end
      label = ds.dsLabel.present? ? ds.dsLabel.split('/').last : 'file'
      if label
        response.headers["Content-Disposition"] = label_to_content_disposition(label, (params['download'].to_s == 'true'))
      end
      response.headers["Content-Type"] = ds.mimeType

      # Handle range requests
      response.headers['Accept-Ranges'] = 'bytes' # Inform client that we accept range requests
      length = size # no length specified by default
      content_headers_for_fedora = {}
      success = 200
      if request.headers['Range'].present?
        # Example Range header value: "bytes=18022400-37581888"
        range_matchdata = request.headers['Range'].match(/bytes=(\d+)-(\d+)*/)
        if range_matchdata
          from = range_matchdata.captures[0].to_i
          to = size - 1 # position for full size assumed by default
          if range_matchdata.captures.length > 1 && range_matchdata.captures[1].present?
            to = range_matchdata.captures[1].to_i
          end
          length = (to - from) + 1 # Adding 1 because to and from are zero-indexed
          success = 206
          content_headers_for_fedora = { 'Range' => "bytes=#{from}-#{to}" }
          response.headers["Content-Range"] = "bytes #{from}-#{to}/#{size}"
          response.headers["Cache-Control"] = 'no-cache'
        end
      end

      response.headers["Content-Length"] = length.to_s
      response.status = success

      # Rails 4 Streaming method
      repo.datastream_dissemination(ds_parms.merge(headers: content_headers_for_fedora)) do |resp|
        begin
          total = 0
          resp.read_body do |seg|
            total += seg.length
            response.stream.write seg
          end
        ensure
          response.stream.close
        end
      end

      # TODO: For externally managed files, eventually do a file read instead of a fedora stream
      # response.stream.write IO.binread(@digital_object.filesystem_location, length, from)
    else
      render text: @digital_object.digital_object_type.display_label.pluralize + ' do not have download URLs.  Try downloading an Asset instead.'
    end
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
