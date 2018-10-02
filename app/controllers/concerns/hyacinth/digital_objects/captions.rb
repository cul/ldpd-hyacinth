module Hyacinth::DigitalObjects::Captions

  def download_captions
    if @digital_object.is_a?(DigitalObject::Asset)
      send_data @digital_object.captions, filename: 'captions.vtt'
    else
      render text: @digital_object.digital_object_type.display_label.pluralize + ' do not have captions.  Try downloading captions for an Asset instead.', status: 404
    end
  end

  def update_captions
    if @digital_object.is_a?(DigitalObject::Asset)
      if captions_params[:captions_text]
        @digital_object.captions = captions_params[:captions_text]
        @digital_object.save
      end
    else
      @digital_object.errors.add(:captions, 'Cannot upload captions for an ' + @digital_object.digital_object_type.display_label)
    end

    render json: {
      success: @digital_object.errors.blank?,
      errors: @digital_object.errors.full_messages
    }
  end

  def delete_captions
    @digital_object.clear_captions_and_reimport_transcript
    @digital_object.save

    render json: {
      success: @digital_object.errors.blank?,
      errors: @digital_object.errors.full_messages
    }
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def captions_params
      params.permit(:captions_text)
    end

end
