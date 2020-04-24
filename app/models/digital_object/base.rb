# frozen_string_literal: true

module DigitalObject
  # DigitalObject::Base class is an abstract class that should not
  # be instantiated. Instead, it should be subclassed (Item, Asset, etc).
  class Base
    extend ActiveModel::Callbacks

    include ActiveModel::Validations
    include Hyacinth::DigitalObject::MetadataAttributes
    include Hyacinth::DigitalObject::ResourceAttributes
    include Hyacinth::DigitalObject::Restrictions
    include DigitalObjectConcerns::AttributeAssignment
    include DigitalObjectConcerns::Validations
    include DigitalObjectConcerns::SaveBehavior
    include DigitalObjectConcerns::Serialization
    include DigitalObjectConcerns::FindBehavior
    include DigitalObjectConcerns::CopyBehavior
    include DigitalObjectConcerns::PublishBehavior
    include DigitalObjectConcerns::DestroyBehavior
    include DigitalObjectConcerns::PurgeBehavior
    include DigitalObjectConcerns::ExportFieldsBehavior
    include DigitalObjectConcerns::PreserveBehavior
    include DigitalObjectConcerns::IndexBehavior

    SERIALIZATION_VERSION = '1' # Increment this if the serialized data format changes so that we can upgrade to the new format.

    # Special structure for the title dynamic field
    TITLE_DYNAMIC_FIELD_GROUP_NAME = 'title'
    TITLE_SORT_PORTION_DYNAMIC_FIELD_NAME = 'sort_portion'
    TITLE_NON_SORT_PORTION_DYNAMIC_FIELD_NAME = 'non_sort_portion'

    # Set up callbacks
    define_model_callbacks :validation, :save, :destroy, :undestroy, :purge
    before_validation :clean_descriptive_metadata!, :clean_rights!
    # TODO: Add these before_save ---> :register_new_uris_and_values_for_descriptive_metadata!
    after_save :index
    before_destroy :remove_all_parents, :unpublish_from_all
    after_destroy :index
    after_undestroy :index
    after_purge :deindex

    # Simple attributes
    metadata_attribute :serialization_version, Hyacinth::DigitalObject::TypeDef::String.new.default(-> { SERIALIZATION_VERSION }).private_writer
    metadata_attribute :uid, Hyacinth::DigitalObject::TypeDef::String.new.private_writer
    metadata_attribute :doi, Hyacinth::DigitalObject::TypeDef::String.new
    # constrain type to the keys for registered type classes
    metadata_attribute :digital_object_type, Hyacinth::DigitalObject::TypeDef::String.new
    metadata_attribute :state, Hyacinth::DigitalObject::TypeDef::String.new.default(-> { Hyacinth::DigitalObject::State::ACTIVE })
    # Modification Info
    metadata_attribute :created_by, Hyacinth::DigitalObject::TypeDef::User.new
    metadata_attribute :updated_by, Hyacinth::DigitalObject::TypeDef::User.new
    metadata_attribute :created_at, Hyacinth::DigitalObject::TypeDef::DateTime.new.default(-> { DateTime.current })
    metadata_attribute :updated_at, Hyacinth::DigitalObject::TypeDef::DateTime.new.default(-> { DateTime.current })
    metadata_attribute :first_published_at, Hyacinth::DigitalObject::TypeDef::DateTime.new
    metadata_attribute :preserved_at, Hyacinth::DigitalObject::TypeDef::DateTime.new
    metadata_attribute :first_preserved_at, Hyacinth::DigitalObject::TypeDef::DateTime.new
    # Identifiers
    metadata_attribute :identifiers, Hyacinth::DigitalObject::TypeDef::JsonSerializableSet.new.default(-> { Set.new })
    # Descriptive Metadata
    metadata_attribute :descriptive_metadata, Hyacinth::DigitalObject::TypeDef::DynamicFieldData.new(:descriptive_metadata).default(-> { Hash.new })
    # Rights Information
    metadata_attribute :rights, Hyacinth::DigitalObject::TypeDef::DynamicFieldData.new(:rights_metadata).default(-> { Hash.new })
    # Administrative Relationsip Objects
    metadata_attribute :primary_project, Hyacinth::DigitalObject::TypeDef::Project.new
    metadata_attribute :other_projects, Hyacinth::DigitalObject::TypeDef::Projects.new.default(-> { Set.new })
    # Preservation System Linkage
    metadata_attribute :preservation_target_uris, Hyacinth::DigitalObject::TypeDef::JsonSerializableSet.new.default(-> { Set.new }).private_writer
    # Parent-Child Structural Data
    metadata_attribute :parent_uids, Hyacinth::DigitalObject::TypeDef::JsonSerializableSet.new.default(-> { Set.new.freeze }).private_writer.freeze_on_deserialize # Frozen Set so this can only be modified by modification methods.
    metadata_attribute :structured_children, Hyacinth::DigitalObject::TypeDef::JsonSerializableHash.new.default(-> { { 'type' => 'sequence', 'structure' => [] } }).private_writer
    # Publish Data
    metadata_attribute :pending_publish_to, Hyacinth::DigitalObject::TypeDef::JsonSerializableArray.new.default(-> { Array.new }).private_writer
    metadata_attribute :pending_unpublish_from, Hyacinth::DigitalObject::TypeDef::JsonSerializableArray.new.default(-> { Array.new }).private_writer
    metadata_attribute :publish_entries, Hyacinth::DigitalObject::TypeDef::PublishEntries.new.default(-> { Hash.new.freeze }).private_writer.freeze_on_deserialize # Frozen Set so this can only be modified by modification methods.

    attr_reader :digital_object_record

    delegate :new_record?, :persisted?, :optimistic_lock_token, :optimistic_lock_token=, to: :digital_object_record

    # Creates a new DigitalObject with default values for all fields
    def initialize
      raise NotImplementedError, 'Cannot instantiate DigitalObject::Base. Instantiate a subclass instead.' if self.class == DigitalObject::Base
      self.digital_object_type = Hyacinth::Config.digital_object_types.class_to_key(self.class)
      @digital_object_record = DigitalObjectRecord.new
      @parent_uids_to_add = Set.new
      @parent_uids_to_remove = Set.new
      @preserve = false
      @mint_doi = false
    end

    def projects
      ([primary_project] + other_projects.to_a).compact.freeze
    end

    def project_ids
      projects.each.map(&:id)
    end

    def parents
      @parents ||= parent_uids.map { |i| DigitalObject::Base.find(i) }
    end

    def generate_title(sortable = false)
      val = '[No Title]'

      title_field_group = descriptive_metadata[TITLE_DYNAMIC_FIELD_GROUP_NAME]
      if title_field_group.present? && (title_field = title_field_group[0]).present?
        val = title_field[TITLE_SORT_PORTION_DYNAMIC_FIELD_NAME]
        non_sort_portion = title_field[TITLE_NON_SORT_PORTION_DYNAMIC_FIELD_NAME]
        val = "#{non_sort_portion} #{val}" if non_sort_portion && !sortable
      end

      val
    end

    def number_of_children
      structured_children['structure'].length
    end
  end
end
