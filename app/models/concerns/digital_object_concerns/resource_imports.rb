# frozen_string_literal: true

module DigitalObjectConcerns
  module ResourceImports
    extend ActiveSupport::Concern

    def process_resource_imports
      self.resource_imports.each do |resource_import_name, resource_import|
        process_resource_import(self.latest_lock_object, resource_import_name, resource_import)
      end
    end

    def finalize_resource_imports
      self.resource_attributes.each do |resource_name|
        next if old_resources[resource_name].blank?

        # Delete old resource since we don't need it anymore
        old_resources[resource_name].location.tap do |location|
          Hyacinth::Config.resource_storage.delete(location) if Hyacinth::Config.resource_storage.exists?(location)
        end

        # Clear out old resource entry now that we're done with it
        old_resources[resource_name] = nil

        # Clear out resource import entry now that we're done with it
        resource_imports[resource_name] = nil
      end
    end

    def finalize_deleted_resources
      self.deleted_resources.each do |_key, resource|
        next if resource.nil? || !Hyacinth::Config.resource_storage.deletable?(resource.location)
        Hyacinth::Config.resource_storage.delete(resource.location)
      end
      self.resource_attributes.each do |resource_name|
        self.deleted_resources[resource_name] = nil
      end
    end

    def rollback_resource_imports
      resource_imports.each do |resource_name, resource_import|
        next if resource_import.blank?

        # Delete the file associated with this rolled back resource import.
        # Note: This will be a no-op if the associated adapter doesn't support delete operations (e.g. track adapter).
        resources[resource_name].location.tap do |location|
          Hyacinth::Config.resource_storage.delete(location) if Hyacinth::Config.resource_storage.exists?(location)
        end

        # Restore old resource from backup
        resources[resource_name] = old_resources[resource_name]

        # Clear out old_resource entry
        old_resources[resource_name] = nil
      end
    end

    # Processes the data for the resource_import at key resource_import_name (e.g. 'access') and
    # upon success assigns a new resource at key resource_import_name.
    def process_resource_import(lock_object, resource_import_name, resource_import)
      return if resource_import.nil? # nothing to import for this resource

      new_resource = new_resource_for_import(resource_import, resource_import_name)

      # Next we're going to do a checksum comparison, if a checksum was given.
      # We want to fail quickly if an invalid checksum was given, so we'll check the given value first.
      provided_hexdigest = resource_import.hexgidest_from_checksum
      provided_file_size = resource_import.file_size.present? ? resource_import.file_size : nil

      hexdigest, file_size = analyze_and_optionally_copy_resource_import(resource_import, new_resource, lock_object)

      # If checksum was provided, let's compare it to our calculated value
      validate_provided_hexdigest!(provided_hexdigest, hexdigest)

      # If file size was provided, let's compare it to our calculated file size
      validate_provided_file_size!(provided_file_size, file_size)

      # If we got here, everything worked!  Let's convert the checksum to our internally-stored
      # URN format and assign it and the file_size to the newly-created resource object.
      new_resource.checksum = "sha256:#{hexdigest}"
      new_resource.file_size = file_size

      # Back up current resource value to old_resources hash
      self.old_resources[resource_import_name] = self.resources[resource_import_name]
      # And then assign new resources to resources hash
      self.resources[resource_import_name] = new_resource
    end

    def new_resource_for_import(resource_import, resource_import_name)
      Hyacinth::DigitalObject::Resource.new(
        location: location_from_import(resource_import, resource_import_name),
        original_file_path: resource_import.preferred_original_file_path,
        media_type: resource_import.media_type || resource_import.media_type_for_filename
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
        lock_obj&.extend_lock_if_expires_in_less_than(lock_object.lock_timeout / 2)
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
  end
end
