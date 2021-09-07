# frozen_string_literal: true

class DigitalObject < ApplicationRecord
  include DigitalObjectConcerns::ReloadBehavior
  include Hyacinth::DigitalObject::MetadataAttributes
  include Hyacinth::DigitalObject::ResourceAttributes
  include DigitalObjectConcerns::AttributeAssignment
  include DigitalObjectConcerns::AsJson
  include DigitalObjectConcerns::Validations
  include DigitalObjectConcerns::LockBehavior
  include DigitalObjectConcerns::MetadataStorageSerialization
  include DigitalObjectConcerns::ExportFieldsBehavior
  include DigitalObjectConcerns::PreserveBehavior
  include DigitalObjectConcerns::PublishBehavior
  include DigitalObjectConcerns::IndexBehavior
  include DigitalObjectConcerns::CreateAndUpdateTerms
  include DigitalObjectConcerns::ParentChildBehavior
  include DigitalObjectConcerns::ResourceImports

  after_initialize :raise_error_if_base_class!
  after_find :load_fields_from_metadata_storage
  after_reload :load_fields_from_metadata_storage

  has_many :publish_entries
  has_many :publish_targets, through: :publish_entries
  belongs_to :created_by, required: false, class_name: 'User'
  belongs_to :updated_by, required: false, class_name: 'User'

  before_validation :clean_descriptive_metadata!, :clean_rights!
  before_save :lock, :assign_uid_if_not_exist, :assign_metadata_location_uri_if_not_exist,
              :reject_optimistic_lock_token_if_stale!, :update_optimistic_lock_token,
              :write_metadata_storage_backup,
              :create_and_update_terms, :process_resource_imports
  after_save :write_fields_to_metadata_storage
  after_commit :finalize_deleted_resources, :finalize_resource_imports, :unlock
  after_save_commit :index
  after_rollback :rollback_metadata_storage, :rollback_resource_imports, :unlock
  before_destroy :unpublish_from_all, :delete_all_resources
  after_destroy :delete_from_metadata_storage, :deindex

  enum state: { active: 0, deleted: 1 }

  attr_accessor :mint_doi # TODO: Make sure this is considered during a save operation
  attr_accessor :latest_lock_object
  after_initialize do |_digital_object|
    @mint_doi = false
  end

  # Title
  metadata_attribute :title, Hyacinth::DigitalObject::TypeDef::Title.new.validation(proc { |value| value&.dig('value').blank? || value.dig('value', 'sort_portion')&.strip.present? })
  # Identifiers
  metadata_attribute :identifiers, Hyacinth::DigitalObject::TypeDef::JsonSerializableSet.new.default(-> { Set.new })
  # Descriptive Metadata
  metadata_attribute :descriptive_metadata, Hyacinth::DigitalObject::TypeDef::DynamicFieldData.new(:descriptive_metadata).default(-> { {} })
  # Rights Information
  metadata_attribute :rights, Hyacinth::DigitalObject::TypeDef::DynamicFieldData.new(:rights_metadata).default(-> { {} })
  # Administrative Relationsip Objects
  metadata_attribute :primary_project, Hyacinth::DigitalObject::TypeDef::Project.new
  metadata_attribute :other_projects, Hyacinth::DigitalObject::TypeDef::Projects.new.default(-> { Set.new })
  # Preservation System Linkage
  metadata_attribute :preservation_target_uris, Hyacinth::DigitalObject::TypeDef::JsonSerializableSet.new.default(-> { Set.new }).private_writer

  def self.find_by_uid!(uid)
    self.find_by!(uid: uid)
  end

  def digital_object_type
    Hyacinth::Config.digital_object_types.class_to_key(self.class)
  end

  def projects
    ([primary_project] + other_projects.to_a).compact.freeze
  end

  def generate_display_label
    return uid.dup unless title&.dig('value', 'sort_portion')

    val = title.dig('value', 'sort_portion').dup
    non_sort_portion = title.dig('value', 'non_sort_portion')
    val = "#{non_sort_portion} #{val}" if non_sort_portion

    val
  end

  def number_of_children
    children.length
  end

  def can_have_children?
    false
  end

  def can_have_rights?
    false
  end

  def child_structure
    {
      type: 'sequence', # we only support sequences at this time, but may support other types later
      structure: self.children
    }
  end

  private

    def raise_error_if_base_class!
      raise NotImplementedError, 'Base class DigitalObject cannot be instantiated! Instantiate a subclass instead.' if self.class == DigitalObject
    end

    def assign_uid_if_not_exist
      return if self.uid.present?
      self.uid = mint_uid
    end

    def mint_uid
      SecureRandom.uuid
    end

    def assign_metadata_location_uri_if_not_exist
      self.metadata_location_uri = Hyacinth::Config.metadata_storage.generate_new_location_uri(self.uid) unless self.metadata_location_uri.present?
      self.backup_metadata_location_uri = Hyacinth::Config.metadata_storage.generate_new_location_uri("#{self.uid}-backup") unless self.backup_metadata_location_uri.present?
    end

    def update_optimistic_lock_token
      self.optimistic_lock_token = SecureRandom.uuid
    end
end
