module DigitalObject
  # DigitalObject::Base class is an abstract class that should not
  # be instantiated. Instead, it should be subclassed (Item, Asset, etc).
  class Base
    include Hyacinth::DigitalObject::MetadataAttributes
    include Hyacinth::DigitalObject::ResourceAttributes
    include DigitalObjectConcerns::DigitalObjectData::Setters
    include DigitalObjectConcerns::DigitalObjectData::Serializer
    include DigitalObjectConcerns::FindBehavior
    include DigitalObjectConcerns::SaveBehavior

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
  end
end
