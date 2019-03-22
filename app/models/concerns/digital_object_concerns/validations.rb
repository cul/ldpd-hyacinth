module DigitalObjectConcerns::Validations
  extend ActiveSupport::Concern

  included do
    validates :uid, presence: true, if: :persisted?
    validates :state, inclusion: { in: Hyacinth::DigitalObject::State::VALID_STATES, message: "Invalid state: %{value}" }

    # Validate URI fields and raise exception if any of them are malformed
    # raise_exception_if_malformed_controlled_field_data!

    # Validate that import files are readable before we import them

    # Validate that none of this object's possible publish targets have the same doi_priority (regardless of which targets it's actually published to)
    # Validate that all current publish_entries are real PublishTargets
    # Validate that no publish targets appears in both @publish_to and @unpublish_from
    # Validate that all Wpublish_to and @unpublish_from destinations are real PublishTargets

    # Validate that all @parent_uids_to_add and @parent_uids_to_remove are existing objects
  end
end
