module DigitalObject::Assets::Captions
  extend ActiveSupport::Concern

  def captions_location
    raise 'Missing UUID for ' + self.pid if self.uuid.nil? # TODO: Get rid of this once all objects have UUIDs
    File.join(Hyacinth::Utils::PathUtils.data_directory_path_for_uuid(self.uuid), 'captions.vtt')
  end

  def captions
    @captions ||= begin
      content = File.exist?(self.captions_location) ? IO.read(self.captions_location) : ''
      content.present? ? content : ""
    end
  end

  def captions=(content)
    @captions_changed = true
    20.times { puts "captions=#{content.length} characters" }
    @captions = encoded_string(content)
  end

  def captions_changed?
    instance_variable_defined?('@captions_changed') && @captions_changed
  end

  def synchronized_transcript_location
    raise 'Missing UUID for ' + self.pid if self.uuid.nil? # TODO: Get rid of this once all objects have UUIDs
    File.join(Hyacinth::Utils::PathUtils.data_directory_path_for_uuid(self.uuid), 'synchronized_transcript.vtt')
  end

  def synchronized_transcript
    @synchronized_transcript ||= begin
      content = File.exist?(self.synchronized_transcript_location) ? IO.read(self.synchronized_transcript_location) : ''
      content.present? ? content : default_synchronized_transcript_vtt
    end
  end

  def synchronized_transcript=(content)
    @synchronized_transcript_changed = true
    @synchronized_transcript = encoded_string(content)
  end

  def synchronized_transcript_changed?
    instance_variable_defined?('@synchronized_transcript_changed') && @synchronized_transcript_changed
  end

  # clears out any custom captions and reimports the current version of the
  # plain text transcript as the basis for new captions
  def clear_synchronized_transcript_and_reimport_transcript
    send(:'synchronized_transcript=', default_synchronized_transcript_vtt)
  end

  # return the plain text transcript as a VTT caption document
  def default_synchronized_transcript_vtt
    # Default starter VTT content. Title, date, and identifier are required by the Synchronizer Widget
    "WEBVTT\n" \
      "\n" \
      "NOTE\n" \
      "This is informative interview-level metadata that is not editable in the synchronizer\n" \
      "Title: Title may be changed or corrected.\n" \
      "Date: Date might be changed or corrected.\n" \
      "Identifier: #{self.uuid}\n" \
      "\n" +
      (self.transcript.present? ? "00:00:00.000 --> 00:01:00.000\n#{self.transcript}" : '')
  end
end
