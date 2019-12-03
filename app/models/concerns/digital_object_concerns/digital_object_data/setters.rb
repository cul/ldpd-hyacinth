# frozen_string_literal: true

module DigitalObjectConcerns
  module DigitalObjectData
    module Setters
      include DigitalObjectConcerns::DigitalObjectData::Setters::Doi
      include DigitalObjectConcerns::DigitalObjectData::Setters::DynamicFieldData
      include DigitalObjectConcerns::DigitalObjectData::Setters::Identifiers
      include DigitalObjectConcerns::DigitalObjectData::Setters::OptimisticLockToken
      include DigitalObjectConcerns::DigitalObjectData::Setters::ParentUids
      include DigitalObjectConcerns::DigitalObjectData::Setters::Preserve
      include DigitalObjectConcerns::DigitalObjectData::Setters::Projects
      include DigitalObjectConcerns::DigitalObjectData::Setters::PendingPublishEntries
      include DigitalObjectConcerns::DigitalObjectData::Setters::Resources
      include DigitalObjectConcerns::DigitalObjectData::Setters::State
      include DigitalObjectConcerns::DigitalObjectData::Setters::StructuredChildren

      # A powerful method that can set many of this object's properties in one go, based on the given digital_object_data hash.
      # This method will raise errors if it is given invalid data (e.g. references to projects or publish targets that don't exist),
      # so be ready to handle those exceptions. All of the deliberately-thrown exceptions will extend Hyacinth::Exceptions::HyacinthError.
      # @param digital_object_data [Hash] A hash of data used to update many of this object's properties.
      # @param merge_dynamic_fields [boolean] If true, merges given dynamic_field_data Hash into into existing dynamic_field_data.
      #        If false, replaces existing dynamic_field_data with new dynamic_field_data Hash.
      def set_digital_object_data(new_digital_object_data, merge_dynamic_fields)
        # Note: You can optionally include an optimistic_lock_token in the digital_object_data
        # if you want the save operation to fail if the object has been modified by another process.
        # TODO: Make sure to include an optimistic_lock_token in the Hyacinth UI editor save submissions
        # so that users will know to refresh the page and redo changes if another user or process made changes
        # while they had the editing screen open.

        set_dynamic_field_data(new_digital_object_data, merge_dynamic_fields)
        set_doi(new_digital_object_data)
        set_identifiers(new_digital_object_data)
        set_mint_doi(new_digital_object_data)
        set_optimistic_lock_token(new_digital_object_data)
        set_parent_uids(new_digital_object_data)
        set_preserve(new_digital_object_data)
        set_pending_publish_entries(new_digital_object_data)
        set_resources(new_digital_object_data)
        set_state(new_digital_object_data)
        set_projects(new_digital_object_data)
      end
    end
  end
end
