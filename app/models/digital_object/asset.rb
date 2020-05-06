# frozen_string_literal: true

module DigitalObject
  class Asset < DigitalObject::Base
    include DigitalObjectConcerns::Assets::Validations

    PRIMARY_RESOURCE_NAME = 'master'

    resource_attribute PRIMARY_RESOURCE_NAME.to_sym
    resource_attribute :service
    resource_attribute :access

    before_validation :assign_asset_type_from_primary_resource_import_if_blank
    before_validation :assign_title_from_primary_resource_import_if_blank

    metadata_attribute :asset_type, Hyacinth::DigitalObject::TypeDef::String.new

    restriction_attribute :restricted_onsite, Hyacinth::DigitalObject::TypeDef::Boolean.new
    restriction_attribute :restricted_size_image, Hyacinth::DigitalObject::TypeDef::Boolean.new

    def initialize
      super
    end

    def primary_resource_name
      PRIMARY_RESOURCE_NAME
    end

    def resource_import_for_primary_resource
      resource_imports[primary_resource_name]
    end

    def assign_asset_type_from_primary_resource_import_if_blank
      return if self.asset_type.present?

      resource_import = resource_import_for_primary_resource
      return if resource_import.blank?

      self.asset_type = BestType.pcdm_type.for_file_name(resource_import.preferred_filename)
    end

    def assign_title_from_primary_resource_import_if_blank
      return if self.descriptive_metadata['title'].present?

      resource_import = resource_import_for_primary_resource
      return if resource_import.blank?

      self.descriptive_metadata['title'] = [{ 'sort_portion' => resource_import.preferred_filename }]
    end
  end
end
