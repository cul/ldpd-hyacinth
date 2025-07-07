module Hyacinth
  module FormObjects
    class CaptionsUpdateFormObject < Hyacinth::FormObjects::FormObject
      validate :validate_presence_of_file_or_captions_text
      validate :validate_encoding
      validate :validate_file, if: -> { file.present? }

      attr_accessor :file, :captions_vtt

      MAX_ALLOWED_TRANSCRIPT_UPLOAD_SIZE = 10_000_000

      def captions_content
        if file.present?
          @captions_content ||= file.tempfile.read
        else
          @captions_content ||= captions_vtt
        end
      end

      def valid_webvtt?(content)
        content.blank? || content.start_with?("WEBVTT")
      end

      def validate_presence_of_file_or_captions_text
        if file.nil? && captions_vtt.nil?
          errors.add(:base, 'Missing captions content. Expected transcript data in either :file or :captions_vtt params.')
        else
          errors.add(:base, 'Captions must be WebVTT') unless valid_webvtt?(captions_content)
        end
      end

      def validate_file
        # validate file size
        size = file.tempfile.size
        errors.add(:base, "Transcript file too large. Must be smaller than #{MAX_ALLOWED_TRANSCRIPT_UPLOAD_SIZE / 1_000_000} MB.") if size > MAX_ALLOWED_TRANSCRIPT_UPLOAD_SIZE # 10MB

        # validate mime type
        mime_type = BestType.mime_type.for_file_name(file.original_filename)
        errors.add(:base, "Only WebVTT files are allowed (detected MIME type #{mime_type}).") unless mime_type == 'text/vtt'
      end

      def validate_encoding
        errors.add(:base, 'Captions data must be valid UTF-8') unless Hyacinth::Utils::StringUtils.string_valid_utf8?(captions_content)
      end
    end
  end
end
