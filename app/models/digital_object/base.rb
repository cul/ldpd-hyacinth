module DigitalObject
  # DigitalObject::Base class is an abstract class that should not
  # be instantiated. Instead, it should be subclassed (Item, Asset, etc).
  class Base
    extend ActiveModel::Callbacks

    include ActiveModel::Validations
    include Hyacinth::DigitalObject::MetadataAttributes
    include Hyacinth::DigitalObject::ResourceAttributes
    include DigitalObjectConcerns::DigitalObjectData::Setters
    include DigitalObjectConcerns::Validations
    include DigitalObjectConcerns::SaveBehavior
    include DigitalObjectConcerns::PreservationBehavior
    include DigitalObjectConcerns::PublishBehavior
    include DigitalObjectConcerns::Serializer
    include DigitalObjectConcerns::FindBehavior

    # Set up callbacks
    define_model_callbacks :validation, :save
    before_validation :trim_whitespace_for_dynamic_field_data!, :remove_blank_fields_from_dynamic_field_data!
    # TODO: Add these before_validations ---> :register_new_uris_and_values_for_dynamic_field_data!, normalize_controlled_term_fields!

    # Simple attributes
    metadata_attribute :uid, Hyacinth::DigitalObject::TypeDef::String.new
    metadata_attribute :doi, Hyacinth::DigitalObject::TypeDef::String.new
    metadata_attribute :digital_object_type, Hyacinth::DigitalObject::TypeDef::String.new
    metadata_attribute :state, Hyacinth::DigitalObject::TypeDef::String.new.default(-> { 'active' }).public_writer
    # Modification Info
    metadata_attribute :created_by, Hyacinth::DigitalObject::TypeDef::User.new.public_writer
    metadata_attribute :updated_by, Hyacinth::DigitalObject::TypeDef::User.new.public_writer
    metadata_attribute :created_at, Hyacinth::DigitalObject::TypeDef::DateTime.new.default(-> { DateTime.now })
    metadata_attribute :updated_at, Hyacinth::DigitalObject::TypeDef::DateTime.new.default(-> { DateTime.now })
    metadata_attribute :first_published_at, Hyacinth::DigitalObject::TypeDef::DateTime.new
    metadata_attribute :persisted_to_preservation_at, Hyacinth::DigitalObject::TypeDef::DateTime.new
    metadata_attribute :first_persisted_to_preservation_at, Hyacinth::DigitalObject::TypeDef::DateTime.new
    # Identifiers
    metadata_attribute :identifiers, Hyacinth::DigitalObject::TypeDef::JsonSerializableSet.new.default(-> { Set.new })
    # Dynamic Fields
    metadata_attribute :dynamic_field_data, Hyacinth::DigitalObject::TypeDef::JsonSerializableHash.new.default(-> { Hash.new })
    # Administrative Relationsip Objects
    metadata_attribute :group, Hyacinth::DigitalObject::TypeDef::Group.new
    metadata_attribute :projects, Hyacinth::DigitalObject::TypeDef::Projects.new.default(-> { Set.new })
    # Preservation System Linkage
    metadata_attribute :preservation_target_uris, Hyacinth::DigitalObject::TypeDef::JsonSerializableSet.new.default(-> { Set.new })
    # Parent-Child Structural Data
    metadata_attribute :parent_uids, Hyacinth::DigitalObject::TypeDef::JsonSerializableSet.new.default(-> { Set.new.freeze }).freeze_on_deserialize # Frozen Set so this can only be modified by modification methods.
    metadata_attribute :structured_children, Hyacinth::DigitalObject::TypeDef::JsonSerializableHash.new.default(-> { { 'type' => 'sequence', 'structure' => [] } })
    # Publish Data
    metadata_attribute :publish_entries, Hyacinth::DigitalObject::TypeDef::JsonSerializableHash.new.default(-> { Hash.new.freeze }).freeze_on_deserialize # Frozen Set so this can only be modified by modification methods.

    attr_reader :digital_object_record, :publish_to, :unpublish_from
    # attr_accessor :parent_uids_to_add, :parent_uids_to_remove
    # private :parent_uids_to_add, :parent_uids_to_add=, :parent_uids_to_remove, :parent_uids_to_remove=

    delegate :new_record?, :persisted?, :optimistic_lock_token, :optimistic_lock_token=, to: :digital_object_record

    # Creates a new DigitalObject with default values for all fields
    def initialize
      raise NotImplementedError, 'Cannot instantiate DigitalObject::Base. Instantiate a subclass instead.' if self.class == DigitalObject::Base
      self.digital_object_type = Hyacinth.config.digital_object_types.class_to_key(self.class)
      @digital_object_record = DigitalObjectRecord.new
      @parent_uids_to_add = Set.new
      @parent_uids_to_remove = Set.new
      @publish_to = []
      @unpublish_from = []
    end
  end
end
