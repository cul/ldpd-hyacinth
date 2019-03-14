module DigitalObjectConcerns::SaveBehavior
  extend ActiveSupport::Concern

  # This method is like the other #save method, but it raises an error if the save fails.
  def save!(opts = {})
    raise Hyacinth::Exceptions::NotSaved, 'DigitalObject could not be saved. Check digital_object#errors for details.' unless (result = save(opts))
    result
  end

  # Saves this object, persisting all data to permanent storage and reindexing for search.
  # This method will also perform a publish if this object's @publish flag is set to true. TODO: Actually make publishing work.
  # @param opts [Hash] A hash of options. Options include:
  #             :lock [boolean] Whether or not to lock on this object during saving.
  #                             You generally want this to be true, unless you're establishing a lock on this object
  #                             outside of the save call for another reason. Defaults to true.
  #             :allow_structured_child_addition_or_removal [boolean] Whether or not to allow the addition or removal of
  #                             uids to the structured_children object. Defaults to false. Note: It's always fine to rearrange
  #                             existing uids in the structured_children object, but adding/removing uids can lead to parent-child
  #                             out-of-sync issues if we're not explicit about when we allow adding/removing.
  def save(opts = {})
    if self.new_record?
      self.uid = self.mint_uid # generate a new uid for this object
      self.digital_object_record.uid = self.uid # assign that uid to this object's digital_object_record
      self.digital_object_record.metadata_location_uri = Hyacinth.config.metadata_storage.generate_new_location_uri(self.digital_object_record.uid)
    end

    # run validations
    return false unless self.valid?

    # If we modify the child lists for any removed or added parent objects,
    # we'll keep track of these changes in the hash below so we can revert if necessary.
    digital_objects_to_child_states_for_modified_parent_objects = {}

    # If this object has already been saved, we'll be loading the persisted version for comparison and potential reversion in case of failure
    persisted_version_of_digital_object = nil

    begin
      # Always lock during save unless opts[:lock] explicitly tells us not to.
      # Note: In the line below, self.uid will be nil for new objects and this lock line will simply yield without locking on anything, which is fine.
      Hyacinth.config.lock_adapter.with_lock(opts.fetch(:lock, true) ? self.uid : nil) do |lock_object|
        if self.persisted?
          # If this is an existing record, grab a copy of the currently-persisted
          # version in case we need to revert anything, and so we can check the
          # optimistic_lock_token
          persisted_version_of_digital_object = DigitalObject::Base.find(self.uid)

          # If the persisted version has a different optimistic_lock_token than
          # this instance, raise an error because we're out of sync and don't want
          # to risk overwriting changes made by other process.
          reject_invalid_optimistic_lock_token!(persisted_version_of_digital_object.optimistic_lock_token)

          # In order to keep parent-child relationships from getting out of sync -- because when we add a new
          # parent to an object, we also add that object as a new child for the parent -- we only allow
          # addition or removal of uids in structured_children when explicitly granted (via
          # the allow_structured_child_addition_or_removal opt). Rearrangement (without new uid addition or removal)
          # is always fine, and does not require this explicit opt. The method below raises an exception if an unallowed
          # add/remove change has been detected in structured_children.
          reject_unallowed_structured_child_addition_or_removal!(
            opts[:allow_structured_child_addition_or_removal],
            persisted_version_of_digital_object.flat_child_uid_set
          )

          # TODO: Probably delete commented out code below in favor of @parent_uids_to_add and @parent_uids_to_remove
          # # We can determine whether any parent digital objects were added or
          # # removed by comparing this object to its persisted version.
          # added_parent_uids = self.parent_uids - persisted_version_of_digital_object.parent_uids
          # removed_parent_uids = persisted_version_of_digital_object.parent_uids - self.parent_uids
        end

        # Establish a lock on any added or removed parent objects (because we'll be modifying their structured child lists)
        Hyacinth.config.lock_adapter.with_multilock(@parent_uids_to_add + @parent_uids_to_remove) do |parent_lock_objects|
          # Handle new imports
          # TODO: make sure to renew the lock in case checksum generation or file copying take a long time
          self.resource_attributes.map do |resource_name, resource|
            resource.process_import_if_present(self.uid, resource_name)
          end

          # We're starting a transaction here so that we can revert the creation
          # of a new DigitalObjectRecord if this is a new DigitalObject, or so that
          # we'll revert the optimistic_lock_token update if this is an existing
          # DigitalObject.
          DigitalObjectRecord.transaction do
            # Save metadata
            # Note: This step must be done after file imports because imports affect metadata.
            Hyacinth.config.metadata_storage.write(self.digital_object_record.metadata_location_uri, JSON.generate(self.to_serialized_form))

            # Modify child lists for any added parents
            @parent_uids_to_add.each do |parent_uid|
              dobj = DigitalObject::Base.find(parent_uid)
              children_snapshot = dobj.deep_copy_of_structured_children # take snapshot of state
              dobj.append_child_uid(self.uid)
              if dobj.save(lock: false, allow_structured_child_addition_or_removal: true)
                # If save was successful, store children snapshot in case we need to revert
                digital_objects_to_child_states_for_modified_parent_objects[dobj] = children_snapshot
              end
            end

            # Modify child lists for any removed parents
            @parent_uids_to_remove.each do |parent_uid|
              dobj = DigitalObject::Base.find(parent_uid)
              children_snapshot = dobj.deep_copy_of_structured_children # take snapshot of state
              dobj.remove_child_uid(self.uid)
              if dobj.save(lock: false, allow_structured_child_addition_or_removal: true)
                # If save was successful, store children snapshot in case we need to revert
                digital_objects_to_child_states_for_modified_parent_objects[dobj] = children_snapshot
              end
            end

            # After successful updating of parents for additions and removal, update this object's parent_uids.
            # Remember that self.parent_uids is an immutable (i.e. frozen) set, so we'll be replacing it with
            # a new Set representing the new state.
            self.parent_uids = (self.parent_uids - @parent_uids_to_remove + @parent_uids_to_add).freeze

            # If all earlier steps were successful and we made it here, clean up import data.
            # We do this at the end so that if any earlier processes fail,
            # we still have the import data and can undo file imports of type :copy.
            # Also, this clearing step is simple and extremely unlikely to fail for any reason.
            clear_resource_import_data

            # Clear temporary values from add/remove variables
            @parent_uids_to_add = Set.new
            @parent_uids_to_remove = Set.new

            # Index this object for search
            Hyacinth.config.search_adapter.index(self)

            # Finally, update the optimistic lock token as part of the save, and save the digital_object_record
            self.digital_object_record.optimistic_lock_token = self.mint_optimistic_lock_token
            self.digital_object_record.save
          end
        end
      end
      true
    rescue Exception => e
      if self.new_record?
        ### For new record ###

        # Clear newly-minted UID (we'll mint a new one during the next save)
        self.uid = nil
        self.digital_object_record.uid = nil

        # Delete the metadata written to storage if it was written
        if self.digital_object_record.metadata_location_uri
          Hyacinth.config.metadata_storage.delete(
            self.digital_object_record.metadata_location_uri
          ) if Hyacinth.config.metadata_storage.exists?(
            self.digital_object_record.metadata_location_uri
          )
        end
      else
        ### For existing record ###

        # Revert persisted metadata to the previous version
        Hyacinth.config.metadata_storage.write(
          self.digital_object_record.metadata_location_uri,
          JSON.generate(persisted_version_of_digital_object.to_serialized_form)
        )
      end

      ### For all records, new or existing ###

      # Delete any successful imports of type :copy (i.e. revert the copy operation)
      self.resource_attributes.map do |resource_name, resource|
        resource.undo_last_successful_import_if_copy
      end

      # Revert parent object relationship changes
      raised_exceptions_during_child_reversion = []
      digital_objects_to_child_states_for_modified_parent_objects.each do |dobj, structured_children_state|
        dobj.structured_children = structured_children_state
        begin
          dobj.save(lock: false, allow_structured_child_addition_or_removal: true)
        rescue StandardError => error_during_reversion
          # If any saves fail, we still want to make sure that we revert the other
          # object child states, but we'll store the error message in this object's errors.
          raised_exceptions_during_child_reversion << error_during_reversion
          errors.add(:parents, "#{error_during_reversion.class}: #{error_during_reversion.message}")
          next
        end
      end

      # Add useful error messages for the client
      if e.is_a?(ActiveRecord::RecordNotUnique)
        errors.add(:uid, "Saving failed becasue a duplicate UID was generated #{self.uid}")
      elsif e.is_a?(Hyacinth::Exceptions::UnableToObtainLockError)
        errors.add(:lock_error, e.message)
      else
        # Re-raise any other unhandled error
        raise e
      end
      false
    end
  end

  # Converts a DigitalObject's structured_children data and turns it into a flat list of child pids
  def flat_child_uid_set
    set = Set.new
    return set if self.structured_children.blank?
    return set if self.structured_children['structure'].blank?

    unless self.structured_children['type'] == 'sequence'
      raise Hyacinth::Exceptions::UnsupportedType, "At the moment, #flat_child_uid_set only supports structures of type 'sequence'. Received unexpected type: #{self.structured_children['type'].inspect}"
    end

    set.merge(structured_children['structure'])
    set
  end

  def reject_unallowed_structured_child_addition_or_removal!(allow_structured_child_addition_or_removal, previous_state_flat_child_uid_set)
    # if changes are allowed, simply return
    return if allow_structured_child_addition_or_removal

    # If changes aren't allowed, we need to compare the unique list of pids
    # from the previous state to the current state.
    if self.flat_child_uid_set != previous_state_flat_child_uid_set
      raise UnallowedStructuredChildUidsModificationError, 'Could not modify structured children. Children may have been modified by another process. Current attempt could potentially lead to an out-of-sync parent-child situation.'
    end
  end

  def reject_invalid_optimistic_lock_token!(expected_optimistic_lock_token)
    if self.optimistic_lock_token != expected_optimistic_lock_token
      raise Hyacinth::DigitalObject::StaleObjectError,
        "DigitalObject #{self.uid} has been updated by another process. Please reload and apply your changes again."
    end
  end

  def deep_copy_of_structured_children
    Marshal.load(Marshal.dump(self.structured_children))
  end

  def mint_uid
    SecureRandom.uuid
  end

  def mint_optimistic_lock_token
    SecureRandom.uuid
  end

  def clear_resource_import_data
    self.resource_attributes.map do |resource_name, resource|
      resource.clear_import_data
    end
  end
end
