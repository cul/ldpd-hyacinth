module Hyacinth
  module FormObjects
    class TranscriptUpdateFormObject < Hyacinth::FormObjects::FormObject

      MAX_ALLOWED_TRANSCRIPT_UPLOAD_SIZE = 10_000_000

      attr_reader :transcript_content

      def initialize(params)
        super()
        @transcript_content = nil

        if params[:file].present?
          error_messages = validate_transcript_upload_file(params[:file])
          if error_messages.present?
            error_messages.each do |message|
              errors.add(:file, message)
            end
          else
            @transcript_content = params[:file].tempfile.read
          end
        elsif params[:transcript_text].present?
          @transcript_content = params[:transcript_text]
        else
          errors.add(:params, 'Missing transcript content params. Expected transcript data in either :file or :transcript_text params.')
        end
      end

      # validates the given upload file param
      # @return an array of string errors if validation fails
      def validate_transcript_upload_file(file_param)
        error_messages = []
        upload_file_size = file_param.tempfile.size
        upload_file_mime_type = BestType.mime_type.for_file_name(file_param.original_filename)
        error_messages << "Transcript file too large. Must be smaller than #{MAX_ALLOWED_TRANSCRIPT_UPLOAD_SIZE / 1_000_000} MB." if upload_file_size > MAX_ALLOWED_TRANSCRIPT_UPLOAD_SIZE # 10MB
        error_messages << "Only plain text files are allowed (detected MIME type #{upload_file_mime_type})." unless upload_file_mime_type == 'text/plain'
        error_messages
      end

    end
  end
end
