module Hyacinth::DigitalObjects::Transcript
  def download_transcript
    if @digital_object.is_a?(DigitalObject::Asset)
      if @digital_object.transcript_location.present?
        send_file @digital_object.transcript_location, filename: 'transcript.txt'
      else
        send_data '', filename: 'transcript.txt'
      end
    else
      render text: @digital_object.digital_object_type.display_label.pluralize + ' do not have a transcript.  Try downloading an Asset transcript instead.', status: 404
    end
  end

  def update_transcript
    if @digital_object.is_a?(DigitalObject::Asset)
      if params[:file].present?
        raise 'Got file of size: ' + params[:file].tempfile.size.to_s
      elsif params[:transcript_text]
        raise 'Got text of length ' + params[:transcript_text].length.to_s
      end
    else
      render text: 'Cannot upload a transcript for an ' + @digital_object.digital_object_type.display_label, status: 400
    end
  end
end
