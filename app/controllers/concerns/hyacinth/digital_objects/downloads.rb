module Hyacinth::DigitalObjects::Downloads
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

  def download_access_copy
    if @digital_object.is_a?(DigitalObject::Asset)
      if @digital_object.fedora_object.datastreams['access'].controlGroup == 'M'
        send_data @digital_object.fedora_object.datastreams['access'].content,
                  filename: @digital_object.fedora_object.datastreams['access'].dsLabel
      else
        send_file @digital_object.access_copy_location, filename: @digital_object.fedora_object.datastreams['access'].dsLabel
      end
    else
      render text: @digital_object.digital_object_type.display_label.pluralize + ' do not have download URLs.  Try downloading an Asset instead.'
    end
  end
end
