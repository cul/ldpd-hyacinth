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
        self.new(json_var)
      end

      def to_serialized_form
        as_json
      end

      def as_json(_options = {})
        SERIALIZED_FIELDS.map { |field| [field.to_s, self.send(field)] }.to_h
      end
    end
  end
end
