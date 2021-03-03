# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    class Resource
      LOCATION_FIELD = :location
      SERIALIZED_FIELDS = [LOCATION_FIELD, :checksum, :original_file_path, :media_type, :file_size].freeze
      FIELDS = (SERIALIZED_FIELDS + [:is_new]).freeze
      attr_accessor(*FIELDS)

      # The opts hash should only include symbol keys
      def initialize(opts = {})
        opts.each do |opt_name, opt_value|
          raise ArgumentError, "Invalid option: #{opt_name}" unless FIELDS.include?(opt_name.to_sym)
          instance_variable_set("@#{opt_name}", opt_value)
        end
        self.is_new = false if self.is_new.nil?
      end

      def original_filename
        original_file_path ? File.basename(original_file_path) : nil
      end

      def content_exists?
        location && Hyacinth::Config.resource_storage.exists?(location)
      end

      # Yields a readable io object for this resource's content.
      # @yield [io] A readable io object.
      def with_readable
        Hyacinth::Config.resource_storage.with_readable(location) do |io|
          yield io
        end
      end

      def self.from_serialized_form(json_var)
        # we only deserialize existing resources, so they are by definition not new
        self.new(json_var)
      end

      def to_serialized_form
        as_json
      end

      def as_json(_options = {})
        SERIALIZED_FIELDS.map { |field| [field.to_s, self.send(field)] }.to_h
      end

      def image?
        BestType.pcdm_type.for_mime_type(media_type) == 'Image' ||
          BestType.pcdm_type.for_file_name(original_filename) == 'Image'
      end

      def video?
        BestType.pcdm_type.for_mime_type(media_type) == 'Video' ||
          BestType.pcdm_type.for_file_name(original_filename) == 'Video'
      end

      def audio?
        BestType.pcdm_type.for_mime_type(media_type) == 'Audio' ||
          BestType.pcdm_type.for_file_name(original_filename) == 'Audio'
      end

      def pdf?
        media_type == 'application/pdf' || original_filename.ends_with?('.pdf')
      end

      def text_or_office_document?
        media_type.match?(/text|msword|ms-word|officedocument|powerpoint|excel|iwork/)
      end
    end
  end
end
