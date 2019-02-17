module DigitalObject
  # DigitalObject::Base class is an abstract class that should not
  # be instantiated. Instead, it should be subclassed (Item, Asset, etc).
  class Base
    include Hyacinth::DigitalObject::MetadataAttributes
    include Hyacinth::DigitalObject::ResourceAttributes
    include DigitalObjectConcerns::DigitalObjectDataSetters

    # Simple attributes
    metadata_attribute :uid, Hyacinth::DigitalObject::TypeDef::String.new
    metadata_attribute :doi, Hyacinth::DigitalObject::TypeDef::String.new
    metadata_attribute :digital_object_type, Hyacinth::DigitalObject::TypeDef::String.new
    metadata_attribute :state, Hyacinth::DigitalObject::TypeDef::String.new.default(-> { 'active' })
    # Modification Info Attributes
    metadata_attribute :created_by, Hyacinth::DigitalObject::TypeDef::User.new
    metadata_attribute :updated_by, Hyacinth::DigitalObject::TypeDef::User.new
    metadata_attribute :last_published_by, Hyacinth::DigitalObject::TypeDef::User.new
    metadata_attribute :created_at, Hyacinth::DigitalObject::TypeDef::DateTime.new.default(-> { DateTime.now })
    metadata_attribute :updated_at, Hyacinth::DigitalObject::TypeDef::DateTime.new.default(-> { DateTime.now })
    metadata_attribute :published_at, Hyacinth::DigitalObject::TypeDef::DateTime.new
    metadata_attribute :first_published_at, Hyacinth::DigitalObject::TypeDef::DateTime.new
    metadata_attribute :persisted_to_preservation_at, Hyacinth::DigitalObject::TypeDef::DateTime.new
    metadata_attribute :first_persisted_to_preservation_at, Hyacinth::DigitalObject::TypeDef::DateTime.new
    # Complex Attributes
    metadata_attribute :group, Hyacinth::DigitalObject::TypeDef::Group.new
    metadata_attribute :projects, Hyacinth::DigitalObject::TypeDef::Projects.new.default(-> { Array.new })
    metadata_attribute :publish_targets, Hyacinth::DigitalObject::TypeDef::PublishTargets.new.default(-> { Array.new })
    metadata_attribute :parent_uids, Hyacinth::DigitalObject::TypeDef::JsonSerializableSet.new.default(-> { Set.new })
    metadata_attribute :structured_child_uids, Hyacinth::DigitalObject::TypeDef::JsonSerializableHash.new.default(-> { Hash.new })
    metadata_attribute :dynamic_field_data, Hyacinth::DigitalObject::TypeDef::JsonSerializableHash.new.default(-> { Hash.new })
    metadata_attribute :preservation_persistence_data, Hyacinth::DigitalObject::TypeDef::JsonSerializableHash.new.default(-> { Hash.new })

    attr_reader :digital_object_record
    attr_accessor :optimistic_lock_token
    delegate :new_record?, :persisted?, to: :digital_object_record

    # Creates a new DigitalObject with default values for all fields
    def initialize
      raise NotImplementedError, 'Cannot instantiate DigitalObject::Base. Instantiate a subclass instead.' if self.class == DigitalObject::Base
      self.digital_object_type = Hyacinth.config.digital_object_types.class_to_key(self.class)
      @digital_object_record = DigitalObjectRecord.new
      @optimistic_lock_token = nil
    end

    def to_digital_object_data
      {}.tap do |digital_object_data|
        # serialize metadata_attributes
        self.metadata_attributes.map do |metadata_attribute_name, type_def|
          digital_object_data[metadata_attribute_name.to_s] = type_def.to_json_var(self.send(metadata_attribute_name))
        end
        # serialize resource_attributes
        self.resource_attributes.map do |resource_attribute_name, resource|
          digital_object_data['resources'] ||= {}
          digital_object_data['resources'][resource_attribute_name.to_s] = resource.as_json
        end
      end
    end

    # Saves this object, persisting all data to permanent storage and reindexing for search.
    # This method will also perform a publish if this object's @publish flag is set to true. TODO: Actually make publishing work.
    # @param opts [Hash] A hash of options. Options include:
    #             :lock [boolean] Whether or not to lock on this object during saving.
    #                             You generally want this to be true, unless you're establishing a lock on this object
    #                             outside of the save call for another reason. Defaults to true.
    #             :allow_structured_child_addition_or_removal [boolean] Whether or not to allow the addition or removal of
    #                             uids to the structured_child_uids object. Defaults to false. Note: It's always fine to rearrange
    #                             existing uids in the structured_child_uids object, but adding/removing uids can lead to parent-child
    #                             out-of-sync issues if we're not careful about when we allow adding/removing.
    def save(opts)
      # run validations
      return false unless self.valid?

      begin
        # Always lock during save unless opts[:lock] explicitly tells us not to.
        # Note: In the line below, self.uid will be nil for new objects and this lock line will simply yield without locking on anything, which is fine.
        Hyacinth.config.lock_adapter.with_lock(opts.fetch(:lock, true) ? self.uid : nil) do |lock_object|
          if persisted?
            # If this is an existing record, grab a copy of the currently-persisted
            # version in case we need to revert anything, and so we can check the
            # optimistic_lock_token
            persisted_version_of_digital_object = self.find(self.uid)

            # If the persisted version has a different optimistic_lock_token than
            # this instance, raise an error because we're out of sync and don't want
            # to risk overwriting changes made by other process.
            if self.optimistic_lock_token != persisted_version_of_digital_object.optimistic_lock_token
              raise Hyacinth::DigitalObject::StaleObjectError, "DigitalObject #{self.uid} has been updated by another process. Please reload and apply your changes again."
            end
          end

          # In order to keep parent-child relationships from getting out of sync -- because when we add a new
          # parent to an object, we also add that object as a new child for the parent -- we only allow
          # addition or removal of uids in structured_child_uids when explicitly granted (via
          # the allow_structured_child_addition_or_removal). Rearrangement (without new uid addition or removal)
          # is always fine. The method below raises an exception if an unallowed change has been detected in structured_child_uids.
          raise_error_if_unallowed_structured_child_change_detected!(opts[:allow_structured_child_addition_or_removal], persisted_version_of_digital_object.flat_child_uid_list)

          # We can determine whether any parent digital objects were added or
          # removed by comparing this object to its persisted version.
          added_parent_uids = self.parent_uids - persisted_version_of_digital_object.parent_uids
          removed_parent_uids = persisted_version_of_digital_object.parent_uids - self.parent_uids

          # Establish a lock on any added or removed parent objects (because we'll be modifying them)
          added_or_removed_parent_uids = (added_parent_uids + removed_parent_uids)
          Hyacinth.config.lock_adapter.with_multilock(added_or_removed_parent_uids) do |parent_lock_objects|
            # Perform a test save operation on all added or removed parent objects in case any of them are
            # in a weird state and are un-saveable. If we can't save the parent objects, then adding or removing
            # parents to this child will lead to an inconsistent state. Performing a test save on the added/removed
            # parents greatly increases our chances of being able to propagate our parent-child changes as intended.
            # TODO: See how this performs in real-world scenarios. I'd prefer not to re-save all parents here and
            # then again later in this method, though an early failure here does save us a lot of trouble.
            added_or_removed_parent_uids.each { |digital_object_uid| DigitalObject::Base.find(digital_object_uid).save }

            # Handle new imports
            # TODO: make sure to renew the lock in case checksum generation or file copying take a long time
            self.resources.map do |resource_name, resource|
              resource.process_import_if_present
            end

            # We're starting a transaction here so that we can revert the creation
            # of a new DigitalObjectRecord if this is a new DigitalObject, or so that
            # we'll revert the optimistic_lock_token update if this is an existing
            # DigitalObject.
            DigitalObjectRecord.transaction do
              if new_record?
                self.digital_object_record.uid = SecureRandom.uuid # generate a new uid for this object
                self.digital_object_record.metadata_location_uri = Hyacinth.config.metadata_storage.generate_new_location_uri(digital_object_record.uid)
              end

              # update the optimistic lock token as part of the save
              self.digital_object_record.optimistic_lock_token = SecureRandom.uuid
              self.digital_object_record.save

              # Save metadata
              # Note: This step must be done after file imports because imports affect metadata.
              Hyacinth.config.metadata_storage.write(self.digital_object_record.metadata_location_uri, JSON.generate(self.to_digital_object_data))

              # If everything went well and we made it to this point, assign self.uid
              self.uid = self.digital_object_record.uid

              # store previous structured_child_uids states in case we need to revert
              previous_parent_structured_child_uids_states = {}

              # Add this successfully-created object's to its new parents (if applicable)
              added_parent_uids.each do |added_parent_uid|
                dobj = DigitalObject::Base.find(added_parent_uid)
                previous_parent_structured_child_uids_states[dobj] = dobj.structured_child_uids # take snapshot of state
                dobj.append_child_digital_object_uid(self.uid)
                dobj.save(lock: false, allow_structured_child_addition_or_removal: true)
              end

              # Remove this object from its old parents (if applicable)
              removed_parent_uids.each do |removed_parent_uid|
                dobj = DigitalObject::Base.find(removed_parent_uid)
                previous_parent_structured_child_uids_states[dobj] = dobj.structured_child_uids # take snapshot of state
                dobj.remove_child_digital_object_uid(self.uid)
                dobj.save(lock: false, allow_structured_child_addition_or_removal: true)
              end

              # Index this object for search
              Hyacinth.config.search_adapter.index(self.uid, self)

              # If all earlier steps were successful and we made it here, clean up import data.
              # We do this at the end so that if any earlier processes fail,
              # we still have the import data and can undo file imports of type :copy.
              # Also, this clearing step is simple and extremely unlikely to fail for any reason.
              self.resources.map do |resource_name, resource|
                resource.clear_import_data
              end
            end
          end
        end
        return true
      rescue Exception => e
        if new_record?
          ### For new records ###

          # Clear newly-minted UID (we'll mint a new one during the next save)
          self.uid = nil
          self.digital_object_record.uid = nil

          # Delete the metadata written to storage if it was written
          Hyacinth.config.metadata_storage.delete(
            digital_object_record.metadata_location_uri
          ) if Hyacinth.config.metadata_storage.exists?(
            digital_object_record.metadata_location_uri
          )

        else
          ### For existing records ###

          # Revert persisted metadata to the previous version
          Hyacinth.config.metadata_storage.write(
            self.digital_object_record.metadata_location_uri,
            JSON.generate(persisted_version_of_digital_object.to_digital_object_data)
          )
        end

        ### For all records, new or existing ###

        # Delete any imports of type :copy (i.e. revert the copy operation)
        self.resources.map do |resource_name, resource|
          resource.undo_last_import_if_copy
        end

        # Revert parent object relationship changes
        previous_parent_structured_child_uids_states.each do |dobj, structured_child_uids_state|
          dobj.structured_child_uids = structured_child_uids_state
          dobj.save(lock: false, allow_structured_child_addition_or_removal: true)
        end

        # Add useful error messages for the client
        if e.is_a?(ActiveRecord::RecordNotUnique)
          errors.add(:uid, "Saving failed becasue a duplicate UID was generated #{self.uid}")
        elsif e.is_a?(Hyacinth::Exceptions::UnableToObtainLockError)
          errors.add(:lock_error, e.message)
        end

        return false
      end
    end

    def raise_error_if_unallowed_structured_child_change_detected!(allow_structured_child_addition_or_removal, previous_state_flat_child_uid_list)
      # if changes are allowed, simply return
      return if allow_structured_child_addition_or_removal

      # If changes aren't allowed, we need to compare the unique list of pids
      # from the previous state to the current state.
      if Set.new(self.flat_child_uid_list) != previous_state_flat_child_uid_list
        raise UnallowedStructuredChildUidsModificationError, 'Could not modify structured children. Children may have been modified by another process. Current attempt could potentially lead to an out-of-sync parent-child situation.'
      end
    end

    def self.find(uid)
      # Important note: We don't want to do a lock when finding. That would
      # mess up other code that assumes no locking during find operations.
      # The optimistic_lock_token exists so that we don't need to lock on find
      # operations. We can find any time we want, but when we save we'll be
      # notified if another person saved and made our object instance stale.
      digital_object_record = DigitalObjectRecord.find_by(uid: uid)
      digital_object_data = JSON.parse(Hyacinth.config.metadata_storage.read(digital_object_record.metadata_location_uri))
      digital_object = Hyacinth.config.digital_object_types.key_to_class(digital_object_data['digital_object_type'])
      # set metadata_attributes
      digital_object.metadata_attributes.map do |metadata_attribute_name, type_def|
        digital_object.send(metadata_attribute_name + '=', type_def.attribute_from_digital_object_data(digital_object_data[metadata_attribute_name.to_s]))
      end
      # build resource objects
      digital_object.resources.map do |resource_name, resource|
        digital_object.send(resource_name + '=', Hyacinth::DigitalObject::Resource.from_json(digital_object_data['resources'][resource_name]))
      end
      # set digital_object_record
      digital_object.instance_variable_set('@digital_object_record', digital_object_record)
      # set optimistic_lock_token
      digital_object.instance_variable_set('@optimistic_lock_token', digital_object_record.optimistic_lock_token)
      # return built object
      digital_object
    rescue ActiveRecord::RecordNotFound
      raise Hyacinth::Exceptions::DigitalObjectNotFoundError, "Could not find DigtalObject with uid #{uid}"
    end

    # A powerful method that can set many of this object's properties in one go, based on the given digital_object_data hash.
    # This method will raise errors if it is given invalid data (e.g. references to projects or publish targets that don't exist),
    # so be ready to handle those exceptions. All of the deliberately-thrown exceptions will extend Hyacinth::Exceptions::HyacinthError.
    # @param digital_object_data [Hash] A hash of data used to update many of this object's properties.
    # @param merge_dynamic_fields [boolean] If true, merges given dynamic_field_data Hash into into existing dynamic_field_data.
    #        If false, replaces existing dynamic_field_data with new dynamic_field_data Hash.
    def set_set_digital_object_data(new_digital_object_data, merge_dynamic_fields)
      # Note: You can optionally include an optimistic_lock_token in the digital_object_data
      # if you want the save operation to fail if the object has been modified by another process.
      # TODO: Make sure to include an optimistic_lock_token in the Hyacinth UI editor save submissions
      # so that users will know to refresh the page and redo changes if another user or process made changes
      # while they had the editing screen open.
      set_optimistic_lock_token(new_digital_object_data)
      set_dynamic_field_data(new_digital_object_data, merge_dynamic_fields)
      set_state(new_digital_object_data)
      set_admin_set(new_digital_object_data)
      set_projects(new_digital_object_data)
      set_publish_targets(new_digital_object_data)
      set_parent_uids(new_digital_object_data)
      set_resources(new_digital_object_data)
    end

  end
end
