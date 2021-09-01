# frozen_string_literal: true

class DigitalObject::Asset < DigitalObject
  include DigitalObjectConcerns::Assets::Validations
  include DigitalObjectConcerns::Assets::ResourceRequests

  MAIN_RESOURCE_NAME = 'main'
  SERVICE_RESOURCE_NAME = 'service'
  ACCESS_RESOURCE_NAME = 'access'
  POSTER_RESOURCE_NAME = 'poster'
  FULLTEXT_RESOURCE_NAME = 'fulltext'
  TEXT_RESOURCE_NAMES = ['synchronized_transcript', 'chapters', 'captions', FULLTEXT_RESOURCE_NAME].freeze

  resource_attribute MAIN_RESOURCE_NAME.to_sym, preservable: { as: :reference }
  resource_attribute SERVICE_RESOURCE_NAME.to_sym
  resource_attribute ACCESS_RESOURCE_NAME.to_sym
  resource_attribute POSTER_RESOURCE_NAME.to_sym
  TEXT_RESOURCE_NAMES.each { |resource_name| resource_attribute resource_name.to_sym, preservable: { as: :copy } }

  before_validation :assign_asset_type_from_main_resource_import_if_blank
  before_validation :assign_title_from_main_resource_import_if_blank
  after_save :run_resource_requests, unless: :skip_resource_request_callbacks # sometimes it's useful to skip resource request callbacks when testing

  metadata_attribute :asset_type, Hyacinth::DigitalObject::TypeDef::String.new
  metadata_attribute :exif_orientation, Hyacinth::DigitalObject::TypeDef::Integer.new.default(-> { 1 }) # Value of 1-8, describing orientation, based on EXIF standard
  metadata_attribute :featured_thumbnail_region, Hyacinth::DigitalObject::TypeDef::String.new

  metadata_attribute :image_size_restriction, Hyacinth::DigitalObject::TypeDef::String.new.default(-> { Hyacinth::DigitalObject::Asset::ImageSizeRestriction::NONE })

  attr_accessor :skip_resource_request_callbacks

  def generate_display_label
    filename_fallback = resources[MAIN_RESOURCE_NAME]&.original_filename
    if title&.fetch('value', nil).blank? && filename_fallback
      filename_fallback
    else
      super
    end
  end

  def can_have_children?
    false
  end

  def can_have_rights?
    true
  end

  def assign_asset_type_from_main_resource_import_if_blank
    return if self.asset_type.present?

    resource_import = resource_imports[main_resource_name]
    return if resource_import.blank?

    self.asset_type = BestType.pcdm_type.for_file_name(resource_import.preferred_filename)
  end

  def assign_title_from_main_resource_import_if_blank
    return if self.title.present?

    resource_import = resource_imports[main_resource_name]
    return if resource_import.blank?

    self.title = { 'value' => { 'sort_portion' => resource_import.preferred_filename } }
  end
end
