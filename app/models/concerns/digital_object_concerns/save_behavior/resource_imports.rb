# frozen_string_literal: true

module DigitalObjectConcerns
  module SaveBehavior
    module ResourceImports
      extend ActiveSupport::Concern

      VALID_CHECKSUM_REGEX = /sha256:([a-f0-9]{64})/.freeze

      # @param lock_object [LockObject] A lock object can be optionally passed in
      # so that an external lock can be extended while the resource import occurs.
      # Imports can take a long time, so an externally-established lock may
      # expire if not renewed within a resource import.
      # Note that this method will undo any file copy operations if the passed-in block
      # raises an error.
      def process_resource_imports(lock_object = nil)
        self.resource_import_attributes.each do |resource_import_name|
          process_resource_import(lock_object, resource_import_name)
        end
        yield
        # If everything went well, then clear the file imports
        clear_resource_imports
      rescue StandardError => e
        # The import failed, so we want to undo all file copy operations that occurred
        undo_new_resource_file_copies
        raise e # pass along the exception to trigger object rollback
      end

      # Processes the data for the resource_import at key resource_import_name (e.g. 'access') and
      # upon success assigns a new resource at key resource_import_name.
      def process_resource_import(lock_object, resource_import_name)
        resource_import = self.resource_imports[resource_import_name]
        return if resource_import.nil? # nothing to import for this resource

        # Immediately assign this resource, with location, to resources hash, even though we
        # still need to add a couple of other properties to it later in the method.
        # This will enable copy undo to work properly in later code.
        self.resources[resource_import_name] = new_resource_for_import(resource_import, resource_import_name)

        # Next we're going to do a checksum comparison, if a checksum was given.
        # We want to fail quickly if an invalid checksum was given, so we'll check the given
        # value first.
        provided_hexdigest = hexgidest_from_import_checksum(resource_import)
        provided_file_size = resource_import.file_size.present? ? resource_import.file_size : nil

        hexdigest, file_size = analyze_and_optionally_copy_resource_import(resource_import, self.resources[resource_import_name], lock_object)

        # If checksum was provided, let's compare it to our calculated value
        validate_provided_hexdigest!(provided_hexdigest, hexdigest)

        # If file size was provided, let's compare it to our calculated file size
        validate_provided_file_size!(provided_file_size, file_size)

        # If we got here, everything worked!  Let's convert the checksum to our internally-stored
        # URN format and assign it and the file_size to the newly-created resource object.
        self.resources[resource_import_name].checksum = "urn:sha256:#{hexdigest}"
        self.resources[resource_import_name].file_size = file_size
      end

      def new_resource_for_import(resource_import, resource_import_name)
        original_file_path = original_file_path_from_import(resource_import)

        Hyacinth::DigitalObject::Resource.new(
          location: location_from_import(resource_import, resource_import_name),
          original_file_path: original_file_path,
          media_type: media_type_from_import(File.basename(original_file_path)),
          is_new: true # used during rollback
        )
      end

      # Calculates the checksum and file_size for the given resource_import file, and also copies
      # if the resource_import to the given resource location if the resource_import is of type copy.
      # @return [String, Integer] Returns a hex digest of the resource and the file size
      def analyze_and_optionally_copy_resource_import(resource_import, resource, lock_object)
        # Generate the checksum and file size for the file that we'll store
        # (and optionally compare to a provided checksum, if one was provided)
        sha256sum = Digest::SHA256.new
        file_size = 0

        shared_analysis_logic = lambda do |chunk, lock_obj|
          sha256sum.update(chunk)
          file_size += chunk.length
          lock_obj&.extend_lock_if_expires_in_less_than(10.seconds)
        end

        if resource_import.method_copy?
          # If this is a copy operation, analyze AND copy the file at the same time.
          Hyacinth::Config.resource_storage.with_writable(resource.location) do |writable_io|
            resource_import.download do |chunk|
              writable_io << chunk
              shared_analysis_logic.call(chunk, lock_object)
            end
          end
        else
          # If this is a track operation, just analyze.
          resource_import.download { |chunk| shared_analysis_logic.call(chunk, lock_object) }
        end

        [sha256sum.hexdigest, file_size]
      end

      def undo_new_resource_file_copies
        self.resource_attributes.each do |resource_name|
          resource = self.resources[resource_name]
          # As we iterate through current resources, we only want to undo copy for newly-created resources
          next unless resource.is_new

          resource_import = self.resource_imports[resource_name]
          # Only undo a copy for resource imports that WERE a copy, and if the copy actually went through.
          next unless resource_import&.method_copy? && Hyacinth::Config.resource_storage.exists?(resource.location)

          # Delete the copied file
          Hyacinth::Config.resource_storage.delete(resource.location)
        end
      end

      def location_from_import(resource_import, resource_import_name)
        if resource_import.method_copy?
          Hyacinth::Config.resource_storage.generate_new_managed_location_uri(self.uid, resource_import_name)
        else
          if resource_import.location_is_active_storage_blob?
            raise ArgumentError, "Import method #{resource_import.method} is not valid "\
              "for ActiveStorage::Blob locations."
          end
          Hyacinth::Config.resource_storage.generate_new_tracked_location_uri(resource_import.location)
        end
      end

      def original_file_path_from_import(resource_import)
        return resource_import.original_file_path if resource_import.original_file_path.present?
        return resource_import.location.filename.to_s if resource_import.location_is_active_storage_blob?
        resource_import.location
      end

      def media_type_from_import(filename)
        BestType.mime_type.for_file_name(filename)
      end

      # Extracts checksum value from the resource_import data
      def hexgidest_from_import_checksum(resource_import)
        hexdigest = resource_import.checksum.present? ? resource_import.checksum : nil
        if hexdigest.present?
          if (match_data = hexdigest.match(VALID_CHECKSUM_REGEX))
            hexdigest = match_data[1]
          else
            raise "Invalid checksum supplied for import (#{hexdigest}). "\
              "Must match format: #{VALID_CHECKSUM_REGEX.inspect}"
          end
        end
        hexdigest
      end

      # Raises an exception if a non-nil provided_hexdigest is given and it does not match the given hexdigest.
      def validate_provided_hexdigest!(provided_hexdigest, hexdigest)
        return unless provided_hexdigest && hexdigest != provided_hexdigest
        raise ChecksumMismatchError, "Checksum mismatch. Provided checksum (#{provided_hexdigest}) didn't match actual file checksum (#{hexdigest}).  Try file import again."
      end

      # Raises an exception if a non-nil provided_file_size is given and it does not match the given file_size.
      def validate_provided_file_size!(provided_file_size, file_size)
        return unless provided_file_size && provided_file_size != file_size
        raise FileSizeMismatchError, "File size mismatch. Provided file size (#{provided_file_size}) didn't match actual file size (#{file_size}).  Try file import again."
      end

      def clear_resource_imports
        self.resource_import_attributes.each do |resource_import_name|
          self.resource_imports[resource_import_name] = nil
        end
      end
    end
  end
end
