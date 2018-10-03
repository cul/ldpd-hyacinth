module DigitalObject::Assets::IndexDocument
  extend ActiveSupport::Concern

  def index_document_location
    raise 'Missing UUID for ' + self.pid if self.uuid.nil? # TODO: Get rid of this once all objects have UUIDs
    File.join(Hyacinth::Utils::PathUtils.data_directory_path_for_uuid(self.uuid), 'index_document.vtt')
  end

  def index_document
    @index_document ||= begin
      content = File.exist?(self.index_document_location) ? IO.read(self.index_document_location) : ''
      content.present? ? content : default_index_document_vtt
    end
  end

  def index_document=(content)
    @index_document_changed = true
    @index_document = content
  end

  def index_document_changed?
    instance_variable_defined?('@index_document_changed') && @index_document_changed
  end

  def default_index_document_vtt
    # Default starter VTT content
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
