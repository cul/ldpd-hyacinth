# frozen_string_literal: true

module DigitalObjectConcerns
  module PurgeBehavior
    extend ActiveSupport::Concern
    # Purges this object, performing cleanup in such a way that it's as if the object never existed.
    # A purge operation runs a destroy and all destroy callbacks, and then erases the object's
    # DigitalObjectRecord, metadata, and writable resources (but tracked resources are not deleted).
    #
    # Purge is not reversible.
    # @param opts [Hash] A hash of options. Options include:
    #             :lock [boolean] Whether or not to lock on this object during purge.
    #                             You generally want this to be true, unless you're establishing a lock on
    #                             this object outside of the save call for another reason. Defaults to true.
    #             :user [User] User who is performing the purge operation.
    def purge!(opts = {})
      destroy!(opts)
      run_callbacks :purge do
        purge_impl(opts)
      end
    end

    def purge_impl(opts = {})
      # Always lock during delete unless opts[:lock] explicitly tells us not to.
      # In the line below, self.uid will be nil for new objects and this lock
      # line will simply yield without locking on anything, which is fine.
      Hyacinth::Config.lock_adapter.with_lock(opts.fetch(:lock, true) ? self.uid : nil) do |_lock_object|
        # remove from metadata storage
        self.purge_metadata(@digital_object_record.metadata_location_uri)
        self.resources.keys.map { |resource_name| self.delete_resource(resource_name) }

        # destroy digital object record
        self.digital_object_record.destroy!
      end

      return true if @errors.blank?
      raise Hyacinth::Exceptions::PurgeError, "DigitalObject may not have been fully purged. Errors: #{self.errors.full_messages}"
    end

    def purge_metadata(location_uri)
      Hyacinth::Config.metadata_storage.delete(location_uri)
    end
  end
end
