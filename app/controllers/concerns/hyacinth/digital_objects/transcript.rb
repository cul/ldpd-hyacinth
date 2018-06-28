module Hyacinth::DigitalObjects::Transcript

  def download_transcript
    if @digital_object.is_a?(DigitalObject::Asset)
      send_data @digital_object.transcript, filename: 'transcript.txt'
    else
      render text: @digital_object.digital_object_type.display_label.pluralize + ' do not have a transcript.  Try downloading an Asset transcript instead.', status: 404
    end
  end

  def update_transcript
    if @digital_object.is_a?(DigitalObject::Asset)
      form_object = Hyacinth::FormObjects::TranscriptUpdateFormObject.new(params)
      if form_object.errors.present?
        render json: {
          success: false,
          errors: form_object.error_messages_without_error_keys
        }
        return
      end

      @digital_object.transcript = form_object.transcript_content
      @digital_object.save
    else
      @digital_object.errors.add(:transcript, 'Cannot upload a transcript for an ' + @digital_object.digital_object_type.display_label)
    end

    render json: {
      success: @digital_object.errors.blank?,
      errors: @digital_object.errors
    }
  end


end
