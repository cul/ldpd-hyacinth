module Hyacinth::DigitalObjects::Transcript
  MAX_ALLOWED_TRANSCRIPT_UPLOAD_SIZE = 10_000_000

  def download_transcript
    if @digital_object.is_a?(DigitalObject::Asset)
      if File.exist?(@digital_object.transcript_location)
        send_file @digital_object.transcript_location, filename: 'transcript.txt'
      else
        send_data '', filename: 'transcript.txt'
      end
    else
      render text: @digital_object.digital_object_type.display_label.pluralize + ' do not have a transcript.  Try downloading an Asset transcript instead.', status: 404
    end
  end

  def update_transcript
    errors = []
    if @digital_object.is_a?(DigitalObject::Asset)
      # Copy transcript file to final transcript location.
      # Lock on digital object so that two processes do not write at
      # the same time.
      @digital_object.db_record.with_lock do
        if params[:file].present?
          errors += validate_transcript_upload_file(params[:file])
          FileUtils.cp(params[:file].tempfile.path, @digital_object.transcript_location) if errors.blank?
        elsif params[:transcript_text]
          IO.write(@digital_object.transcript_location, params[:transcript_text])
        end
      end
    else
      errors << 'Cannot upload a transcript for an ' + @digital_object.digital_object_type.display_label
    end

    render json: {
      success: errors.blank?,
      errors: errors
    }
  end

  # validates the given upload file param
  # @return an array of string errors if validation fails
  def validate_transcript_upload_file(file_param)
    errors = []
    upload_file_size = file_param.tempfile.size
    upload_file_mime_type = BestType.mime_type.for_file_name(file_param.original_filename)
    errors << "Transcript file too large. Must be smaller than #{MAX_ALLOWED_TRANSCRIPT_UPLOAD_SIZE / 1_000_000} MB." if upload_file_size > MAX_ALLOWED_TRANSCRIPT_UPLOAD_SIZE # 10MB
    errors << "Only plain text files are allowed (detected MIME type #{upload_file_mime_type})." unless upload_file_mime_type == 'text/plain'
    errors
  end
end
