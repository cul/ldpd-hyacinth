module DigitalObjectConcerns
  module SaveBehavior
    extend ActiveSupport::Concern

    include DigitalObjectConcerns::SaveBehavior::SaveLockValidations
    include DigitalObjectConcerns::SaveBehavior::MetadataStorage
    include DigitalObjectConcerns::SaveBehavior::Minters
    include DigitalObjectConcerns::SaveBehavior::ResourceImports

    # This method is like the other #save method, but it raises an error if the save fails.
    def save!(opts = {})
      raise Hyacinth::Exceptions::NotSaved, "DigitalObject could not be saved. Errors: #{self.errors.full_messages}" unless save(opts)
      true
    end

    # Saves this object, persisting all data to permanent storage and reindexing for search.
    # This method will also perform a publish if this object's @publish flag is set to true. TODO: Actually make publishing work.
    # @param opts [Hash] A hash of options. Options include:
    #             :user [boolean] User who is performing the save operation.
    #             :lock [boolean] Whether or not to lock on this object during saving.
    #                             You generally want this to be true, unless you're establishing a lock on this object
    #                             outside of the save call for another reason. Defaults to true.
    #             :allow_structured_child_addition_or_removal [boolean] Whether or not to allow the addition or removal of
    #                             uids to the structured_children object. Defaults to false. Note: It's always fine to rearrange
    #                             existing uids in the structured_children object, but adding/removing uids can lead to parent-child
    #                             out-of-sync issues if we're not explicit about when we allow adding/removing.
    def save(opts = {})
      run_callbacks :validation do
        self.valid?
      end

      return false if self.errors.present?

      run_callbacks :save do
        save_impl(opts)
      end

      self.errors.empty?
    end

    def save_impl(opts = {})
      current_datetime = DateTime.current

      # Always lock during save unless opts[:lock] explicitly tells us not to.
      # In the line below, self.uid will be nil for new objects and this lock
      # line will simply yield without locking on anything, which is fine.
      Hyacinth.config.lock_adapter.with_lock(opts.fetch(:lock, true) ? self.uid : nil) do |lock_object|
        # Establish a lock on any added or removed parent objects because we'll be modifying their structured child lists.
        Hyacinth.config.lock_adapter.with_multilock(@parent_uids_to_add + @parent_uids_to_remove) do |parent_lock_objects|

          # Run certain validations that must happen within the save lock
          run_save_lock_validations(opts[:allow_structured_child_addition_or_removal])
          return false if self.errors.present?

          before_save_copy = self.deep_copy

          # Step 1 (process_metadata_and_assets / handle_metadata_and_asset_change_failure): Create or update object metadata, and handle resource imports.
          begin
            self.generate_uid_and_metadata_location_uri_if_new_record
            self.handle_resource_imports
            self.updated_at = current_datetime
            self.created_at = current_datetime if self.created_at.blank?

            # Do DigitalObjectRecord changes as last step in order to properly set new_record/persisted (and within a transaction)
            DigitalObjectRecord.transaction do
              self.digital_object_record.optimistic_lock_token = self.mint_optimistic_lock_token
              raise Hyacinth::Exceptions::Rollback unless self.digital_object_record.save
            end
          rescue StandardError => e
            # Revert any successful imports of type :copy (i.e. by deleting the copies)
            self.resource_attributes.map do |resource_name, resource|
              resource.undo_last_successful_import_if_copy
            end

            if self.new_record? && self.metadata_exists?
              # Need to delete any written metadata since creation of this new record failed.
              Hyacinth.config.metadata_storage.delete(self.digital_object_record.metadata_location_uri)
            end

            # Revert object
            self.deep_copy_instance_variables_from(before_save_copy)

            if e.is_a?(Hyacinth::Exceptions::Rollback)
              # This exception was only intended to trigger a rollback.
              # The errors object should contain information about what went wrong.
              return false
            else
              # Unhandled exception.
              raise e
            end
          end

          # At this point, always write object to metadata store, just in case
          # any unhandled error arises. This is especially important for new
          # object creation, since we don't want to half-create a new object
          # and leave things in an inconsistent state.
          self.write_to_metadata_storage

          # After successful write to metadata storage,
          # clear resource import data because we're done
          # processing imports.
          clear_resource_import_data


          # Step 2 (process_parent_changes / handle_parent_change_failure): Handle newly added or removed parent objects
          if self.parents_changed?
            before_parent_addition_copy = self.deep_copy
            begin
              successful_parent_additions = Set.new
              successful_parent_removals = Set.new
              failed_parent_additions = Set.new
              failed_parent_removals = Set.new

              @parent_uids_to_add.each do |parent_uid|
                dobj = DigitalObject::Base.find(parent_uid)
                dobj.append_child_uid(self.uid)
                if dobj.save(lock: false, allow_structured_child_addition_or_removal: true)
                  successful_parent_additions << parent_uid
                else
                  failed_parent_additions << parent_uid
                  Rails.logger.error("Failed to add #{self.uid} to parent #{dobj.uid} because of the following parent object errors: #{dobj.errors.full_messages.join(", ")}")
                end
              end

              # Modify child lists for any removed parents
              @parent_uids_to_remove.each do |parent_uid|
                dobj = DigitalObject::Base.find(parent_uid)
                dobj.remove_child_uid(self.uid)
                if dobj.save(lock: false, allow_structured_child_addition_or_removal: true)
                  successful_parent_removals << parent_uid
                else
                  failed_parent_removals << parent_uid
                  Rails.logger.error("Failed to remove #{self.uid} from parent #{dobj.uid} because of the following parent object errors: #{dobj.errors.full_messages.join(", ")}")
                end
              end

              if failed_parent_additions.present? || failed_parent_removals.present?
                raise Hyacinth::Exceptions::Rollback
              else
                # All parent change operations succeeded, so we can reset @parent_uids_to_add and @parent_uids_to_remove.
                @parent_uids_to_add.clear
                @parent_uids_to_remove.clear
              end
            rescue StandardError => e
              # Revert this object's properties
              self.deep_copy_instance_variables_from(before_parent_addition_copy)
              # Set parent_uids to the set of successfully changed parents.
              self.parent_uids = (self.parent_uids - successful_parent_removals + successful_parent_additions).freeze
              # Write changes to metadata storage
              self.write_to_metadata_storage

              self.errors.add(:add_parents, "Failed to add the following parents: #{failed_parent_additions.join(", ")}. See error log for more details.") if failed_parent_additions.present?
              self.errors.add(:remove_parents, "Failed to remove the following parents: #{failed_parent_removals.join(", ")}. See error log for more details.") if failed_parent_removals.present?

              if e.is_a?(Hyacinth::Exceptions::Rollback)
                # This exception was only intended to trigger a rollback.
                # The errors object should contain information about what went wrong.
                return false
              else
                # Unhandled exception.
                raise e
              end
            end
          end

          # Step 3 (handle_preservation / handle_preservation_failure): Persist to preservation
          if should_preserve?
            before_preserve_copy = self.deep_copy
            begin
              mint_reserved_doi_if_doi_blank
              self.preserved_at = current_datetime
              if self.first_preserved_at.blank?
                self.first_preserved_at = current_datetime
              end
              if should_publish? && self.first_published_at.blank?
                self.first_published_at = current_datetime
              end
              # Set publish entries to intended targets, assuming successful
              # publish in the next step. (We'll correct these values if publish fails.)
              # Our publish system requires that publish targets are stored in preservation data
              # before publish, since our external systems reindex from preservation storage data.
              self.publish_entries = self.publish_entries.dup.tap do |new_publish_entries|
                self.unpublish_from.each do |publish_target_string_key|
                  new_publish_entries.delete(publish_target_string_key)
                end
                self.publish_to.each do |publish_target_string_key|
                  Hyacinth::PublishEntry.new(published_at: current_datetime, published_by: opts[:user])
                end
                new_publish_entries.freeze
              end
              raise Hyacinth::Exceptions::Rollback unless Hyacinth.config.preservation_persistence.preserve(self)
            rescue StandardError => e
              # Revert this object's properties
              self.deep_copy_instance_variables_from(before_preserve_copy)

              # Write changes to metadata storage
              self.write_to_metadata_storage

              self.errors.add(:preservation, "A preservation error occurred. See error log for more details.")

              # Attempt to re-preserve the previous state.
              Hyacinth.config.preservation_persistence.preserve(self)

              if e.is_a?(Hyacinth::Exceptions::Rollback)
                # This exception was only intended to trigger a rollback.
                # The errors object should contain information about what went wrong.
                return false
              else
                # Unhandled exception.
                raise e
              end
            end
          end

          # Step 4 (handle_publish / handle_publish_failure): Persist to preservation
          if should_publish?
            before_publish_copy = self.deep_copy
            begin
              successful_publish_string_keys = []
              successful_unpublish_string_keys = []
              failed_publish_string_keys = []
              failed_unpublish_string_keys = []

              # For efficiency, use one query to get all publish targets that
              # we'll need in one query.
              publish_target_string_keys_to_publish_targets = PublishTarget.where(
                string_key: (self.publish_to + self.unpublish_from + self.publish_entries.keys).uniq
              ).map do |publish_target|
                [publish_target.string_key, publish_target]
              end.to_h

              # Look at the set of current publish target entries (which have
              # already been added to include)
              highest_priority_publish_entry_string_key = select_highest_priority_publish_entry(self.publish_entries, publish_target_string_keys_to_publish_targets)

              # Attempt to publish and unpublish
              self.publish_to.each do |publish_target_string_key|
                if publish_target_string_keys_to_publish_targets[publish_target_string_key].publish(self, publish_target_string_key == highest_priority_publish_entry_string_key)
                  successful_publish_string_keys << publish_target_string_key
                else
                  failed_publish_string_keys << publish_target_string_key
                  Rails.logger.error("Failed to publish #{self.uid} to #{publish_target_string_key} because of the following errors: #{errors.join(", ")}")
                end
              end

              self.unpublish_from.each do |publish_target_string_key|
                if publish_target_string_keys_to_publish_targets[publish_target_string_key].unpublish(self)
                  successful_unpublish_string_keys << publish_target_string_key
                else
                  failed_unpublish_string_keys << publish_target_string_key
                  Rails.logger.error("Failed to unpublish #{self.uid} to #{publish_target_string_key} because of the following errors: #{errors.join(", ")}")
                end
              end

              if failed_publish_string_keys.present? || failed_unpublish_string_keys.present?
                raise Hyacinth::Exceptions::Rollback
              else
                # All publish and unupublish operations succeeded, so we can reset publish_to and publish_from.
                self.publish_to.clear
                self.unpublish_from.clear
              end
            rescue StandardError => e
              # Revert this object's properties
              self.deep_copy_instance_variables_from(before_publish_copy)

              # Revert first_published_at and publish_entries to the before_preserve_copy
              # (because we added publish data during the preserve step).
              self.deep_copy_metadata_attributes_from(before_preserve_copy, :first_published_at, :publish_entries)

              # Set publish_entries to the set of successfully changed publish entries.
              self.publish_entries = self.publish_entries.dup.tap do |new_publish_entries|
                successful_unpublish_string_keys.each do |publish_target_string_key|
                  new_publish_entries.delete(publish_target_string_key)
                end
                successful_publish_string_keys.each do |publish_target_string_key|
                  Hyacinth::PublishEntry.new(published_at: current_datetime, published_by: opts[:user])
                end
                new_publish_entries.freeze
              end

              # If we actually did successfully publish to at least one publish
              # target, set first_published_at if not set (it might have been
              # unset as part of the reversion if this was a first-time publish).
              if successful_publish_string_keys.present? && self.first_published_at.blank?
                self.first_published_at = current_datetime
              end

              # Write changes to metadata storage
              self.write_to_metadata_storage

              # Attempt to re-preserve reverted version
              Hyacinth.config.preservation_persistence.preserve(self)

              self.errors.add(:add_parents, "Failed to publish to the following targets: #{failed_publish_string_keys.join(", ")}. See errors log for details.") if failed_publish_string_keys.present?
              self.errors.add(:add_parents, "Failed to unpublish from the following targets: #{failed_unpublish_string_keys.join(", ")}. See errors log for details.") if failed_unpublish_string_keys.present?

              # Attempt to re-publish to the successfully-published-to publish
              # targets so they reindex with the just-correcred preservation data.
              self.publish_to.each do |publish_target_string_key|
                publish_target_string_keys_to_publish_targets[publish_target_string_key].publish(self, publish_target_string_key == highest_priority_publish_entry_string_key)
              end

              if e.is_a?(Hyacinth::Exceptions::Rollback)
                # This exception was only intended to trigger a rollback.
                # The errors object should contain information about what went wrong.
                return false
              else
                # Unhandled exception.
                raise e
              end
            end
          end

          # If we made it here, everything worked! Time to write to metadata storage again.
          self.write_to_metadata_storage
        end
      end

      # Assuming we got here, there shouldn't be any errors on the object.
      # Raise an error if there are though, since that would indicate a
      # problem in our code.
      if self.errors.present?
        raise Hyacinth::Exceptions::UnexpectedErrors, "Save proccess appeared to succeed, but found errors on digital object: #{self.errors.full_messages}"
      end

      true
    end

    # Given a publish entries Hash, returns the string key of the publish target with the highest
    # doi priority, ignoring any publish targets that have an is_valid_doi_location value of false.
    # @param pub_entries [Hash] A Hash of publish target string keys to publish entries.
    # @param publish_target_string_keys_to_publish_targets [Hash] A Hash of publish target string keys to PublishTarget instances
    # @return [String] The string_key of the highest priority publish entry,
    # or nil if none of the publish targets meet the requirements necessary to
    # be considered for prioritization.
    def select_highest_priority_publish_entry(pub_entries, publish_target_string_keys_to_publish_targets)
      pub_entries.keys.select do |publish_target_string_key|
        publish_target_string_keys_to_publish_targets[publish_target_string_key].is_valid_doi_location
      end.max_by do |publish_target_string_key|
        publish_target_string_keys_to_publish_targets[publish_target_string_key].doi_priority
      end
    end
  end
end
