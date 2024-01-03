module Hyacinth::DigitalObjects::IndexDocument

  def download_index_document
    if @digital_object.is_a?(DigitalObject::Asset)
      send_data @digital_object.index_document, filename: 'index_document.txt'
    else
      render plain: @digital_object.digital_object_type.display_label.pluralize + ' do not have a index document.  Try downloading an Asset index document instead.', status: 404
    end
  end

  def update_index_document
    if @digital_object.is_a?(DigitalObject::Asset)
      if index_document_params[:index_document_text]
        @digital_object.index_document = index_document_params[:index_document_text]
        @digital_object.save
      end
    else
      @digital_object.errors.add(:index_document, 'Cannot upload an index document for an ' + @digital_object.digital_object_type.display_label)
    end

    render json: {
      success: @digital_object.errors.blank?,
      errors: @digital_object.errors.full_messages
    }
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def index_document_params
      params.permit(:index_document_text)
    end

end
