# frozen_string_literal: true

module DigitalObjectConcerns
  module SaveBehavior
    extend ActiveSupport::Concern

    include DigitalObjectConcerns::SaveBehavior::Minters
    include DigitalObjectConcerns::SaveBehavior::ResourceImports
    include DigitalObjectConcerns::SaveBehavior::SaveLockValidations

    # This method is like the other #save method, but it raises an error if the save fails.
    def save!(opts = {})
      return true if save(opts)
      raise Hyacinth::Exceptions::NotSaved, "DigitalObject could not be saved. Errors: #{self.errors.full_messages}"
    end

    # Saves this object, persisting all data to permanent storage and reindexing for search.
    # @param opts [Hash] A hash of options. Options include:
    #             :allow_structured_child_addition_or_removal [boolean] Whether or not to allow the addition or removal of
    #                             uids to the structured_children object. Defaults to false. Note: It's always fine to rearrange
    #                             existing uids in the structured_children object, but adding/removing uids can lead to parent-child
    #                             out-of-sync issues if we're not explicit about when we allow adding/removing.
    #             :lock [boolean] Whether or not to lock on this object during save.
    #                             You generally want this to be true, unless you're establishing a lock on this object
    #                             outside of the save call for another reason. Defaults to true.
    #             :update_index [boolean] Whether or not to update the search index after save.
    #             :user [User] User who is performing the save operation.
    def save(opts = {})
      run_callbacks :validation do
        self.valid?
      end

      return false if self.errors.present?

      save_result = false
      run_callbacks :save do
        save_result = save_impl(opts)
      end
      save_result
    end

    def save_impl(opts = {})
      current_datetime = DateTime.current

      # Always lock during save unless opts[:lock] explicitly tells us not to.
      # In the line below, self.uid will be nil for new objects and this lock
      # line will simply yield without locking on anything, which is fine.
      Hyacinth.config.lock_adapter.with_lock(opts.fetch(:lock, true) ? self.uid : nil) do |lock_object|
        # Run certain validations that must happen within the save lock
        run_save_lock_validations(opts[:allow_structured_child_addition_or_removal])
        return false if self.errors.present?
        before_save_copy = self.deep_copy

        begin
          self.mint_uid_and_metadata_location_uri_if_new_record
          self.update_modification_info(current_datetime, opts[:user])
          # TODO: #114 how should the minted DOI be treated in the event of a failed save (rescued below)
          self.mint_reserved_doi_if_doi_blank
          self.handle_asset_imports(lock_object) do
            self.handle_parent_changes do
              # Modify DigitalObjectRecord last, since creating it switches new_record? to false,
              # and optimistic_lock_token should change as part of a successful save.
              self.digital_object_record.optimistic_lock_token = self.mint_optimistic_lock_token
              self.digital_object_record.save!

              # If everything worked, write to metadata storage
              self.write_to_metadata_storage
              Hyacinth.config.external_identifier_adapter.update(self.doi, self, nil)
            end
          end
          Hyacinth.config.search_adapter.index(self) if opts[:update_index] == true
        rescue StandardError => e
          # Save a copy of the metadata_location_uri in case this was a new record,
          # since we'll need to delete the metadata
          metadata_location_uri_backup = self.digital_object_record.metadata_location_uri

          errors_backup = self.errors # Preserve errors before we revert
          self.deep_copy_instance_variables_from(before_save_copy) # Revert state
          self.errors.clear
          self.errors.merge!(errors_backup) # Reassign errors after reversion

          if new_record?
            # Delete any written data because we're reverting this entire record.
            Hyacinth.config.metadata_storage.delete(metadata_location_uri_backup)
          else
            # Re-write reverted data to metadata storage
            self.write_to_metadata_storage
          end

          # Re-raise exception, unless it's a Hyacinth rollback exception,
          # since rollback indicates a handled error that's encoded in the
          # digital object's errors object.
          raise e unless e.is_a?(Hyacinth::Exceptions::Rollback)
        end
      end
      self.errors.blank?
    end

    def write_to_metadata_storage
      Hyacinth.config.metadata_storage.write(self.digital_object_record.metadata_location_uri, JSON.generate(self.to_serialized_form))
    end

    def update_modification_info(current_datetime, user = nil)
      self.updated_at = current_datetime
      self.created_at = current_datetime if self.created_at.blank?
      self.updated_by = user
      self.created_by = user if self.created_by.blank?
    end

    # @param lock_object [LockObject] A lock object can be optionally passed in
    # so that an external lock can be extended while the resource import occurs.
    # Imports can take a long time, so an externally-established lock may
    # expire if not renewed within a resource import.
    def handle_asset_imports(lock_object = nil)
      self.handle_resource_imports(lock_object)
      yield
      self.clear_resource_import_data
    rescue StandardError => e
      self.resource_attributes.map do |_resource_name, resource|
        resource.undo_last_successful_import_if_copy
      end

      raise e # pass along the exception
    end

    def handle_parent_changes
      unless self.parents_changed?
        yield
        return
      end

      # Establish a lock on any added or removed parent objects because we'll be modifying their structured child lists.
      Hyacinth.config.lock_adapter.with_multilock(@parent_uids_to_add + @parent_uids_to_remove) do |_parent_lock_objects|
        previous_states_for_updated_parents = []

        @parent_uids_to_add.each do |parent_uid|
          dobj = DigitalObject::Base.find(parent_uid)
          parent_before_save_copy = dobj.deep_copy
          dobj.append_child_uid(self.uid)
          if dobj.save(lock: false, allow_structured_child_addition_or_removal: true)
            previous_states_for_updated_parents << parent_before_save_copy
          else
            Rails.logger.error("Failed to add #{self.uid} to parent #{dobj.uid} because of the following parent object errors: #{dobj.errors.full_messages.join(', ')}")
            self.errors.add(:parent_uids, "Failed to add #{self.uid} to parent #{dobj.uid}. See error log for more details.")
            raise Hyacinth::Exceptions::Rollback
          end
        end

        # Modify child lists for any removed parents
        @parent_uids_to_remove.each do |parent_uid|
          dobj = DigitalObject::Base.find(parent_uid)
          parent_before_save_copy = dobj.deep_copy
          dobj.remove_child_uid(self.uid)
          if dobj.save(lock: false, allow_structured_child_addition_or_removal: true)
            previous_states_for_updated_parents << parent_before_save_copy
          else
            Rails.logger.error("Failed to remove #{self.uid} from parent #{dobj.uid} because of the following parent object errors: #{dobj.errors.full_messages.join(', ')}")
            self.errors.add(:parent_uids, "Failed to remove #{self.uid} from parent #{dobj.uid}. See error log for more details.")
            raise Hyacinth::Exceptions::Rollback
          end
        end

        # All parent change operations succeeded, so we can add @parent_uids_to_add and @parent_uids_to_remove and then clear them.
        self.parent_uids = (self.parent_uids - @parent_uids_to_remove + @parent_uids_to_add).freeze
        @parent_uids_to_add.clear
        @parent_uids_to_remove.clear
        yield
      rescue StandardError => e
        # If any parents were successfully updated, we need to revert them
        # to their previous state by re-saving the previous state objects.
        previous_states_for_updated_parents.each(&:save)

        raise e # pass along the exception
      end
    end

    def parents_changed?
      @parent_uids_to_add.present? || @parent_uids_to_remove.present?
    end
  end
end
