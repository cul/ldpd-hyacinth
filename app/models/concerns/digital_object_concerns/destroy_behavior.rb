module DigitalObjectConcerns
  module DestroyBehavior
    extend ActiveSupport::Concern

    # This method is like the other #save method, but it raises an error if the save fails.
    def destroy!(opts = {})
      return true if destroy(opts)
      raise Hyacinth::Exceptions::NotDestroyed, "DigitalObject could not be destroyed. Errors: #{self.errors.full_messages}"
    end

    # Saves this object, persisting all data to permanent storage and reindexing for search.
    # @param opts [Hash] A hash of options. Options include:
    #             :lock [boolean] Whether or not to lock on this object during delete.
    #                             You generally want this to be true, unless you're establishing a lock on this object
    #                             outside of the save call for another reason. Defaults to true.
    #             :update_index [boolean] Whether or not to update the search index after delete.
    #             :user [User] User who is performing the save operation.
    def destroy(opts = {})
      delete_result = false
      run_callbacks :destroy do
        delete_result = delete_impl(opts)
      end
      delete_result
    end

    def delete_impl(opts = {})
      # Always lock during save unless opts[:lock] explicitly tells us not to.
      # In the line below, self.uid will be nil for new objects and this lock
      # line will simply yield without locking on anything, which is fine.
      Hyacinth.config.lock_adapter.with_lock(opts.fetch(:lock, true) ? self.uid : nil) do |_lock_object|
        @parent_uids_to_remove.merge(parent_uids)
        @parent_uids_to_add.clear
        self.handle_parent_changes do
          # Modify DigitalObjectRecord last, since creating it switches new_record? to false,
          # and optimistic_lock_token should change as part of a successful save.
          self.digital_object_record.optimistic_lock_token = self.mint_optimistic_lock_token

          # remove metadata storage
          self.remove_from_metadata_storage
          all_targets = self.projects.map do |project|
            project.publish_targets.map(&:string_key)
          end.flatten.uniq
          self.set_pending_publish_entries({ 'publish_to' => [], 'unpublish_from' => all_targets })
          # if everything worked, destroy digital object record
          self.digital_object_record.destroy!
        end
      end
      self.errors.blank?
    end

    def remove_from_metadata_storage
      Hyacinth.config.metadata_storage.delete(self.digital_object_record.metadata_location_uri)
    end
  end
end
