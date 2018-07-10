module DigitalObject::Assets::Captions
  extend ActiveSupport::Concern

  def captions_location
    raise 'Missing UUID for ' + self.pid if self.uuid.nil? # TODO: Get rid of this once all objects have UUIDs
    File.join(Hyacinth::Utils::PathUtils.data_directory_path_for_uuid(self.uuid), 'captions.vtt')
  end

  def captions
    @captions ||= begin
      content = File.exist?(self.captions_location) ? IO.read(self.captions_location) : ''
      content.present? ? content : begin
        # Default starter VTT content. Title, date, and identifier are required by the Synchronizer Widget
        "WEBVTT\n" \
        "\n" \
        "NOTE\n" \
        "This is informative interview-level metadata that is not editable in the synchronizer\n" \
        "Title: Title may be changed or corrected.\n" \
        "Date: Date might be changed or corrected.\n" \
        "Identifier: #{self.uuid}\n" \
        "\n"
      end
    end
  end

  def captions=(content)
    @captions_changed = true
    @captions = content
  end

  def captions_changed?
    instance_variable_defined?('@captions_changed') && @captions_changed
  end
end
