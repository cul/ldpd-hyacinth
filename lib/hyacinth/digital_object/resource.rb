# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    class Resource
      attr_accessor :import_location, :import_method, :import_checksum,
                    :location, :checksum, :original_filename, :media_type, :file_size

      attr_reader :import_succeeded

      def initialize(opts = {})
        opts.each do |opt_name, opt_value|
          setter_method = "#{opt_name}=".to_sym
          self.send(setter_method, opt_value) if self.respond_to?(setter_method)
        end
        @import_succeeded = false
      end

      def has_valid_import?
        import_location.present? && import_method.present?
      end

      def with_import_file(&block)
        open(import_location, &block)
      end

      # Clears the fields related to an import. This method is generally called
      # after an import has succeeded and the importing process does not intend
      # to roll back that import.
      def clear_import_data
        self.import_location = nil
        self.import_method = nil
        self.import_checksum = nil
      end

      # If a successful import just occurred, it was of type :copy, delete that copied file
      def undo_last_successful_import_if_copy
        if self.import_succeeded && self.import_method == :copy
          Rails.application.config.storage_adapter.delete(location_uri)
        end
      end

      # @param lock_object [LockObject] A lock object can be optionally passed in
      # so that an external lock can be extended while the resource import occurs.
      # Imports can take a long time, so an externally-established lock may
      # expire if not renewed within a resource import.
      def process_import_if_present(object_uid, resource_name, lock_object)
        return unless has_valid_import?

        # Regardless of import type, we need to calculate a checksum for this file.
        # TODO: Consider queueing a checksum generation job here for asynchronous
        # checksum generation, though the downside of that is that we wouldn't be able
        # to verify the checksum of a copied file.  One other option to consider is
        # allowing users to optionally submit checksums as part of the import process,
        # and in those cases we actually could import the file and supplied checksum
        # without doing checksum verification, but queue an asynchronous checksum
        # verification job in the background and only send an alert if that checksum
        # match fails. For now though, we'll keep things simple by just
        # calculating/verifying checksums during import.
        self.checksum = checksum_for_file(self.import_location, lock_object)
        # TODO: Finish checksum code

        if import_method == :track
          # When tracking files, there's no need to write the file.
          self.location = self.import_location
        else
          # Non-tracking import operations require a file copy
          self.with_import_file do |input_file|
            save_location = Hyacinth::Config.resource_storage.generate_new_location_uri(object_uid, resource_name)

            Hyacinth::Config.resource_storage.with_writeable(save_location) do |output_blob|
              IO.copy_stream(input_file, output_blob)
            end
            self.location = save_location
            @import_succeeded = true
          end
        end
      end

      # @param lock_object [LockObject] A lock object can be optionally passed in
      # so that an external lock can be extended while the resource import occurs.
      # Imports can take a long time, so an externally-established lock may
      # expire if not renewed within a resource import.
      def checksum_for_file(file_import_location, lock_object)
        # TODO: Implement this

        # Extend the lock during the checksumming process so that it doesn't expire
        # lock_object.extend_lock # extend lock in case publish is slow
      end

      def self.from_serialized_form(json_var)
        self.new(json_var)
      end

      def to_serialized_form
        as_json
      end

      def as_json(_options = {})
        return {} unless location
        {
          'location' => location,
          'checksum' => checksum,
          'original_filename' => original_filename,
          'media_type' => media_type,
          'file_size' => file_size
        }
      end
    end
  end
end
