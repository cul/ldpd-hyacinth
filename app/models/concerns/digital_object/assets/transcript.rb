module DigitalObject::Assets::Transcript
  extend ActiveSupport::Concern

  def transcript_location
    raise 'Missing UUID for ' + self.pid if self.uuid.nil? # TODO: Get rid of this once all objects have UUIDs
    File.join(Hyacinth::Utils::PathUtils.data_directory_path_for_uuid(self.uuid), 'transcript.txt')
  end

  def transcript
    @transcript ||= File.exist?(self.transcript_location) ? IO.read(self.transcript_location) : ''
  end

  def transcript=(content)
    @transcript_changed = true
    @transcript = encoded_string(content)
  end

  def transcript_changed?
    instance_variable_defined?('@transcript_changed') && @transcript_changed
  end
end
