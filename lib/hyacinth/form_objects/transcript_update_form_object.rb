module Hyacinth
  module FormObjects
    class TranscriptUpdateFormObject < Hyacinth::FormObjects::FormObject
      validate :validate_presence_of_file_or_transcript_text
      validate :validate_encoding
      validate :validate_file, if: -> { file.present? }

      attr_accessor :file, :transcript_text

      MAX_ALLOWED_TRANSCRIPT_UPLOAD_SIZE = 10_000_000

      def transcript_content
        if file.present?
          strip_utf8_bom(file.tempfile.read)
        else
          strip_utf8_bom(transcript_text)
        end
      end

      def validate_presence_of_file_or_transcript_text
        if file.nil? && transcript_text.nil?
          errors.add(:base, 'Missing transcript content. Expected transcript data in either :file or :transcript_text params.')
        end
      end

      def validate_file
        # validate file size
        size = file.tempfile.size
        errors.add(:base, "Transcript file too large. Must be smaller than #{MAX_ALLOWED_TRANSCRIPT_UPLOAD_SIZE / 1_000_000} MB.") if size > MAX_ALLOWED_TRANSCRIPT_UPLOAD_SIZE # 10MB

        # validate mime type
        mime_type = BestType.mime_type.for_file_name(file.original_filename)
        errors.add(:base, "Only plain text files are allowed (detected MIME type #{mime_type}).") unless mime_type == 'text/plain'
      end

      def validate_encoding
        errors.add(:base, 'Transcript must be valid UTF-8') unless Hyacinth::Utils::StringUtils.string_valid_utf8?(transcript_content)
      end
    end
  end
end
