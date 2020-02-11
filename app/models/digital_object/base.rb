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
    include DigitalObjectConcerns::DigitalObjectData::Setters
    include DigitalObjectConcerns::Validations
    include DigitalObjectConcerns::SaveBehavior
    include DigitalObjectConcerns::Serialization
    include DigitalObjectConcerns::FindBehavior
    include DigitalObjectConcerns::CopyBehavior
    include DigitalObjectConcerns::PublishBehavior
    include DigitalObjectConcerns::DestroyBehavior
    include DigitalObjectConcerns::ExportFieldsBehavior
    include DigitalObjectConcerns::PreserveBehavior

    SERIALIZATION_VERSION = '1' # Increment this if the serialized data format changes so that we can upgrade to the new format.

    # Set up callbacks
    define_model_callbacks :validation, :save, :destroy
    before_validation :clean_dynamic_field_data!, :clean_rights!
    # TODO: Add these before_validations ---> :register_new_uris_and_values_for_dynamic_field_data!, normalize_controlled_term_fields!

    # Simple attributes
    metadata_attribute :serialization_version, Hyacinth::DigitalObject::TypeDef::String.new.default(-> { SERIALIZATION_VERSION }).private_writer
    metadata_attribute :uid, Hyacinth::DigitalObject::TypeDef::String.new.private_writer
    metadata_attribute :doi, Hyacinth::DigitalObject::TypeDef::String.new.private_writer
    # constrain type to the keys for registered type classes
    metadata_attribute :digital_object_type, Hyacinth::DigitalObject::TypeDef::String.new.private_writer
    metadata_attribute :state, Hyacinth::DigitalObject::TypeDef::String.new.default(-> { 'active' })
    # Modification Info
    metadata_attribute :created_by, Hyacinth::DigitalObject::TypeDef::User.new.private_writer
    metadata_attribute :updated_by, Hyacinth::DigitalObject::TypeDef::User.new.private_writer
    metadata_attribute :created_at, Hyacinth::DigitalObject::TypeDef::DateTime.new.default(-> { DateTime.current }).private_writer
    metadata_attribute :updated_at, Hyacinth::DigitalObject::TypeDef::DateTime.new.default(-> { DateTime.current }).private_writer
    metadata_attribute :first_published_at, Hyacinth::DigitalObject::TypeDef::DateTime.new.private_writer
    metadata_attribute :preserved_at, Hyacinth::DigitalObject::TypeDef::DateTime.new.private_writer
    metadata_attribute :first_preserved_at, Hyacinth::DigitalObject::TypeDef::DateTime.new.private_writer
    # Identifiers
    metadata_attribute :identifiers, Hyacinth::DigitalObject::TypeDef::JsonSerializableSet.new.default(-> { Set.new }).private_writer
    # Dynamic Fields
    metadata_attribute :dynamic_field_data, Hyacinth::DigitalObject::TypeDef::JsonSerializableHash.new.default(-> { Hash.new }).private_writer
    # Rights Information
    metadata_attribute :rights, Hyacinth::DigitalObject::TypeDef::JsonSerializableHash.new.default(-> { Hash.new })
    # Administrative Relationsip Objects
    metadata_attribute :primary_project, Hyacinth::DigitalObject::TypeDef::Project.new
    metadata_attribute :other_projects, Hyacinth::DigitalObject::TypeDef::Projects.new.default(-> { Set.new }).private_writer
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
      @publish_to = []
      @unpublish_from = []
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
  end
end
