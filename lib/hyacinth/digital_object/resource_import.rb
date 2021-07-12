# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    class ResourceImport
      DOWNLOAD_BUFFER_BYTE_SIZE = 5.megabytes

      REQUIRED_FIELDS = [:method, :location].freeze
      FIELDS = (REQUIRED_FIELDS + [:checksum, :original_file_path, :media_type, :file_size]).freeze
      attr_reader(*FIELDS)

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

        if @method == FIXTURE_FILE
          # The FIXTURE_FILE import method is actually a copy from a relative path (the fixture directory)
          @method = COPY
          @location = Rails.root.join('spec', 'fixtures', 'files', @location).to_s
        elsif @location.is_a?(String) && @location.start_with?('blob://')
          @location = ActiveStorage::Blob.find_signed(location.sub('blob://', ''))
        end

        # TODO: Eventually add support for a path-relative import directory for users. This will be similar to how the FIXTURE FILE method works.
      end

      def valid?
        REQUIRED_FIELDS.each do |field|
          return false if send(field).blank?
        end
        return false unless VALID_IMPORT_METHODS.include?(self.method)
        true
      end

      def location_is_readable?
        # It's generally safe to assume an ActiveStorage blob is readable.
        return true if location_is_active_storage_blob?
        # Check readability of file at given path
        return File.readable?(location) if location.start_with?('/')
        # If the location is a URL, try a head request to determine readability
        if location.match?(/^https*:\/\//)
          begin
            return Faraday.head(location, request: { timeout: 5 }).status == 200
          rescue Faraday::ConnectionFailed
            return false
          end
        end

        false
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
