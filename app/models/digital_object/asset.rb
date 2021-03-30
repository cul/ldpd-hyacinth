# frozen_string_literal: true

class DigitalObject::Asset < DigitalObject
  include DigitalObjectConcerns::Assets::Validations
  include DigitalObjectConcerns::Assets::ResourceRequests

  MASTER_RESOURCE_NAME = 'master'
  SERVICE_RESOURCE_NAME = 'service'
  ACCESS_RESOURCE_NAME = 'access'
  POSTER_RESOURCE_NAME = 'poster'
  FULLTEXT_RESOURCE_NAME = 'fulltext'

  resource_attribute MASTER_RESOURCE_NAME.to_sym
  resource_attribute SERVICE_RESOURCE_NAME.to_sym
  resource_attribute ACCESS_RESOURCE_NAME.to_sym
  resource_attribute POSTER_RESOURCE_NAME.to_sym
  resource_attribute FULLTEXT_RESOURCE_NAME.to_sym

  before_validation :assign_asset_type_from_master_resource_import_if_blank
  before_validation :assign_title_from_master_resource_import_if_blank
  after_save :run_resource_requests, unless: :skip_resource_request_callbacks # sometimes it's useful to skip resource request callbacks when testing

  metadata_attribute :asset_type, Hyacinth::DigitalObject::TypeDef::String.new
  metadata_attribute :exif_orientation, Hyacinth::DigitalObject::TypeDef::Integer.new.default(-> { 1 }) # Value of 1-8, describing orientation, based on EXIF standard
  metadata_attribute :featured_thumbnail_region, Hyacinth::DigitalObject::TypeDef::String.new

  metadata_attribute :image_size_restriction, Hyacinth::DigitalObject::TypeDef::String.new.default(-> { Hyacinth::DigitalObject::Asset::ImageSizeRestriction::NONE })

  attr_accessor :skip_resource_request_callbacks

  def can_have_rights?
    true
  end

  def assign_asset_type_from_master_resource_import_if_blank
    return if self.asset_type.present?

    resource_import = resource_imports[master_resource_name]
    return if resource_import.blank?

    self.asset_type = BestType.pcdm_type.for_file_name(resource_import.preferred_filename)
  end

  def assign_title_from_master_resource_import_if_blank
    return if self.descriptive_metadata['title'].present?

    resource_import = resource_imports[master_resource_name]
    return if resource_import.blank?

    self.descriptive_metadata['title'] = [{ 'sort_portion' => resource_import.preferred_filename }]
  end
end
