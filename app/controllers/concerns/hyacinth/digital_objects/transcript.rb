module Hyacinth::DigitalObjects::Transcript
  MAX_ALLOWED_TRANSCRIPT_UPLOAD_SIZE = 10_000_000

  def download_transcript
    if @digital_object.is_a?(DigitalObject::Asset)
      send_data @digital_object.transcript, filename: 'transcript.txt'
    else
      render text: @digital_object.digital_object_type.display_label.pluralize + ' do not have a transcript.  Try downloading an Asset transcript instead.', status: 404
    end
  end

  def update_transcript
    if @digital_object.is_a?(DigitalObject::Asset)
      errors = []
      if params[:file].present?
        if (errors = validate_transcript_upload_file(params[:file])).present?
          render json: {
            success: false,
            errors: errors
          }
          return
        end
        @digital_object.transcript = params[:file].tempfile.read
      elsif
        @digital_object.transcript = params[:transcript_text]
      end

      @digital_object.save
    else
      @digital_object.errors.add(:transcript, 'Cannot upload a transcript for an ' + @digital_object.digital_object_type.display_label)
    end

    render json: {
      success: @digital_object.errors.blank?,
      errors: @digital_object.errors
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
