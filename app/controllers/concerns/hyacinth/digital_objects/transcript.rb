module Hyacinth::DigitalObjects::Transcript

  def download_transcript
    if @digital_object.is_a?(DigitalObject::Asset)
      send_data @digital_object.transcript, filename: 'transcript.txt'
    else
      render text: @digital_object.digital_object_type.display_label.pluralize + ' do not have a transcript.  Try downloading an Asset transcript instead.', status: 404
    end
  end

  def update_transcript
    form_object = Hyacinth::FormObjects::TranscriptUpdateFormObject.new(transcript_params)
    if @digital_object.is_a?(DigitalObject::Asset)
      if form_object.valid?
        @digital_object.transcript = form_object.transcript_content
        @digital_object.save
      else
        render json: {
          success: false,
          errors: form_object.errors.full_messages
        }
        return
      end
    else
      @digital_object.errors.add(:transcript, 'Cannot upload a transcript for an ' + @digital_object.digital_object_type.display_label)
    end

    render json: {
      success: @digital_object.errors.blank?,
      errors: @digital_object.errors.full_messages
    }
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def transcript_params
      params.permit(:file, :transcript_text)
    end

end
