# frozen_string_literal: true

module DigitalObjectConcerns::Validations
  extend ActiveSupport::Concern

  included do
    validates :uid, :metadata_location_uri, :optimistic_lock_token, :type, presence: true, if: :persisted?

    validates :uid, presence: true, if: :persisted?
    validates :primary_project, presence: true
    validates :state, presence: true

    validates :descriptive_metadata, 'digital_object/descriptive_fields': true
    validates :rights, 'digital_object/rights_fields': true
    validate :indexing_test_succeeds

    validates_with DigitalObject::TypeValidator
    validates_with DigitalObject::ResourceImportValidator
    validates_with DigitalObject::MetadataAttributesValidator

    # Validate that import files are readable before we import them

    # Validate that none of this object's possible publish targets have the same doi_priority (regardless of which targets it's actually published to)
    # Validate that all current publish_entries are real PublishTargets
    # Validate that no publish targets appears in both @pending_publish_to and @pending_unpublish_from
    # Validate that all @pending_publish_to and @pending_unpublish_from destinations are real PublishTargets

    # Validate that all parents_to_add, parent_to_remove, children_to_add, and children_to_remove are allowed types (e.g. only items can be parents of assets)

    # Validate that all preservation_target_uris have unique protocols

    private

      def indexing_test_succeeds
        errors.add(:indexing_test, "Indexing test failed.") unless self.index_test
      end
  end
end
