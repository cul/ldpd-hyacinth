# frozen_string_literal: true

module DigitalObjectConcerns::Validations
  extend ActiveSupport::Concern

  included do
    validates :uid, presence: true, if: :persisted?
    validates :state, inclusion: { in: Hyacinth::DigitalObject::State::VALID_STATES, message: "Invalid state: %{value}" }
    validates :primary_project, presence: true

    validates :descriptive_metadata, 'digital_object/descriptive_fields': true
    validates :rights, 'digital_object/rights_fields': true

    validates_with DigitalObject::TypeValidator
    validates_with DigitalObject::RestrictionsValidator

    # Validate that import files are readable before we import them

    # Validate that none of this object's possible publish targets have the same doi_priority (regardless of which targets it's actually published to)
    # Validate that all current publish_entries are real PublishTargets
    # Validate that no publish targets appears in both @pending_publish_to and @pending_unpublish_from
    # Validate that all @pending_publish_to and @pending_unpublish_from destinations are real PublishTargets

    # Validate that all @parent_uids_to_add and @parent_uids_to_remove are existing objects

    # Validate that all preservation_target_uris have unique protocols
  end
end
