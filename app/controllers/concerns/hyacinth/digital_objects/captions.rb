module Hyacinth::DigitalObjects::Captions

  def download_captions
    if @digital_object.is_a?(DigitalObject::Asset)
      send_data @digital_object.captions, filename: 'captions.vtt'
    else
      render plain: @digital_object.digital_object_type.display_label.pluralize + ' do not have captions.  Try downloading captions for an Asset instead.', status: 404
    end
  end

  def update_captions
    form_object = Hyacinth::FormObjects::CaptionsUpdateFormObject.new(captions_params)
    if @digital_object.is_a?(DigitalObject::Asset)
      if form_object.valid?
        @digital_object.captions = form_object.captions_content
        @digital_object.save
      else
        render json: {
          success: false,
          errors: form_object.errors.full_messages
        }
        return
      end
    else
      @digital_object.errors.add(:captions, 'Cannot upload captions for an ' + @digital_object.digital_object_type.display_label)
    end

    render json: {
      success: @digital_object.errors.blank?,
      errors: @digital_object.errors.full_messages
    }
  end

  def download_synchronized_transcript
    if @digital_object.is_a?(DigitalObject::Asset)
      send_data @digital_object.synchronized_transcript, filename: 'synchronized_transcript.vtt'
    else
      render plain: @digital_object.digital_object_type.display_label.pluralize + ' do not have synchronized transcripts.  Try downloading from an Asset instead.', status: 404
    end
  end

  def update_synchronized_transcript
    if @digital_object.is_a?(DigitalObject::Asset)
      if synchronized_transcript_params[:synchronized_transcript_text]
        @digital_object.synchronized_transcript = synchronized_transcript_params[:synchronized_transcript_text]
        @digital_object.save
      end
    else
      @digital_object.errors.add(:synchronized_transcript, 'Cannot upload synchronized_transcript for an ' + @digital_object.digital_object_type.display_label)
    end

    render json: {
      success: @digital_object.errors.blank?,
      errors: @digital_object.errors.full_messages
    }
  end

  def clear_synchronized_transcript_and_reimport_transcript
    @digital_object.clear_synchronized_transcript_and_reimport_transcript
    @digital_object.save

    render json: {
      success: @digital_object.errors.blank?,
      errors: @digital_object.errors.full_messages
    }
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def captions_params
      params.permit(:captions_vtt, :file)
    end

    def synchronized_transcript_params
      params.permit(:synchronized_transcript_text)
    end

end
