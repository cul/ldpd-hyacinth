# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    class ResourceImport
      DOWNLOAD_BUFFER_BYTE_SIZE = 5.megabytes

      REQUIRED_FIELDS = [:method, :location].freeze
      FIELDS = (REQUIRED_FIELDS + [:checksum, :original_file_path, :media_type, :file_size]).freeze
      attr_accessor(*FIELDS)

      COPY = 'copy'
      TRACK = 'track'
      FIXTURE_FILE = 'fixture_file'
      VALID_IMPORT_METHODS = [COPY, TRACK, FIXTURE_FILE].freeze

      VALID_CHECKSUM_REGEX = /sha256:([a-f0-9]{64})/.freeze

      # The opts hash should only include symbol keys.
      # The :checksum value, if provided, should be of the format:
      # "sha256:50d858e0985ecc7f60418aaf0cc5ab587f42c2570a884095a9e8ccacd0f6545c"
      def initialize(opts)
        opts.each do |opt_name, opt_value|
          raise ArgumentError, "Invalid option: #{opt_name}" unless FIELDS.include?(opt_name.to_sym)
          instance_variable_set("@#{opt_name}", opt_value)
        end

        @location = ActiveStorage::Blob.find_signed(location.sub('blob://', '')) if @location.is_a?(String) && @location.start_with?('blob://')
      end

      def valid?
        REQUIRED_FIELDS.each do |field|
          return false if send(field).blank?
        end
        return false unless VALID_IMPORT_METHODS.include?(self.method)
        true
      end

      def location_is_active_storage_blob?
        location.present? && location.is_a?(ActiveStorage::Blob)
      end

      def download
        if location_is_active_storage_blob?
          # To limit memory usage, don't allow ActiveStorage download to return the entire object.
          # Force block usage.
          location.download { |chunk| yield chunk }
        else
          # To limit memory usage, only read small chunks of the file.
          open(location, 'rb') do |io|
            while (chunk = io.read(DOWNLOAD_BUFFER_BYTE_SIZE))
              yield chunk
            end
          end
        end
      end

      def method_copy?
        method == COPY
      end

      # Extracts checksum hex value from the checksum field
      def hexgidest_from_checksum
        hexdigest = checksum.present? ? checksum : nil
        if hexdigest.present?
          if (match_data = hexdigest.match(VALID_CHECKSUM_REGEX))
            hexdigest = match_data[1]
          else
            raise Hyacinth::Exceptions::InvalidChecksumFormatError, "Invalid checksum format supplied for import (#{hexdigest}). "\
              "Must match format: #{VALID_CHECKSUM_REGEX.inspect}"
          end
        end
        hexdigest
      end

      def media_type_for_filename
        BestType.mime_type.for_file_name(preferred_filename)
      end

      def preferred_filename
        File.basename(preferred_original_file_path)
      end

      # Returns the best original_file_path value, based on available data
      def preferred_original_file_path
        return original_file_path if original_file_path.present?
        return location.filename.to_s if location_is_active_storage_blob?
        location
      end
    end
  end
end
