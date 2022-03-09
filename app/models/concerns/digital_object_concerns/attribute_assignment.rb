# frozen_string_literal: true

module DigitalObjectConcerns
  module AttributeAssignment
    include DigitalObjectConcerns::AttributeAssignment::DescriptiveMetadata
    include DigitalObjectConcerns::AttributeAssignment::Doi
    include DigitalObjectConcerns::AttributeAssignment::Identifiers
    include DigitalObjectConcerns::AttributeAssignment::OptimisticLockToken
    include DigitalObjectConcerns::AttributeAssignment::Parents
    include DigitalObjectConcerns::AttributeAssignment::PendingPublishEntries
    include DigitalObjectConcerns::AttributeAssignment::Preserve
    include DigitalObjectConcerns::AttributeAssignment::Projects
    include DigitalObjectConcerns::AttributeAssignment::ResourceImports
    include DigitalObjectConcerns::AttributeAssignment::Rights
    include DigitalObjectConcerns::AttributeAssignment::State
    include DigitalObjectConcerns::AttributeAssignment::Title
    include DigitalObjectConcerns::AttributeAssignment::Uid

    # A batch setter method that assigns many of this object's properties in one go, based on the
    # given digital_object_data hash. This method is particularly useful in cases like batch import,
    # where a JSON document should be applied as an update to a digital object.
    # This method and the child methods it calls will raise errors if it is given invalid data
    # (e.g. references to projects or publish targets that don't exist), so be ready to handle those
    # exceptions. All of the deliberately-thrown exceptions will extend Hyacinth::Exceptions::HyacinthError.
    # @param digital_object_data [Hash] A hash of digital object data used to update many of this
    # digital object's attributes.
    # @param merge_descriptive_metadata [boolean] If true, merges given descriptive_metadata Hash into into existing descriptive_metadata.
    #        If false, replaces existing descriptive_metadata with new descriptive_metadata Hash.
    # @param opts [Hash] A hash of options. Options include:
    #             :merge_descriptive_metadata [boolean] If true, merges given descriptive_metadata Hash into
    #                                             into existing descriptive_metadata.
    #             :merge_rights [boolean] If true, merges given rights_data Hash into
    #                                     into existing rights_data.
    def assign_attributes(new_digital_object_data, merge_descriptive_metadata = true, merge_rights = true)
      # NOTE: You can optionally include an optimistic_lock_token in the digital_object_data
      # if you want the save operation to fail if the object has been modified by another process.
      # TODO: Make sure to include an optimistic_lock_token in the Hyacinth UI editor save submissions
      # so that users will know to refresh the page and redo changes if another user or process made changes
      # while they had the editing screen open.

      assign_descriptive_metadata(new_digital_object_data, merge_descriptive_metadata)
      assign_doi(new_digital_object_data)
      assign_identifiers(new_digital_object_data)
      assign_mint_doi(new_digital_object_data)
      assign_optimistic_lock_token(new_digital_object_data)
      assign_parents(new_digital_object_data)
      assign_preserve(new_digital_object_data)
      assign_preservation_target_uris(new_digital_object_data)
      assign_pending_publish_entries(new_digital_object_data)
      assign_resource_imports(new_digital_object_data)
      assign_state(new_digital_object_data)
      assign_projects(new_digital_object_data)
      assign_rights(new_digital_object_data, merge_rights)
      assign_title(new_digital_object_data)
    end
  end
end
