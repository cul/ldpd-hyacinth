# frozen_string_literal: true

module DigitalObjectConcerns::Assets::Validations
  extend ActiveSupport::Concern

  FEATURED_THUMBNAIL_REGION_PATTERN = /^\d+,\d+,(\d+),(\d+)$/.freeze

  included do
    validate :validate_main_resource
    validate :validate_asset_type
    validate :validate_rights_updates
    validate :validate_image_size_restriction
    validate :validate_featured_thumbnail_region
  end

  def validate_main_resource
    return if has_main_resource? || resource_imports[main_resource_name].present?
    errors.add("resources[#{main_resource_name}]", "Missing main resource: #{main_resource_name}")
  end

  def validate_asset_type
    if asset_type.blank?
      errors.add(:asset_type, "Missing asset type (probably because of missing main resource)")
      return
    end

    errors.add(:asset_type, "Invalid asset type: #{asset_type}") unless BestType.pcdm_type.valid_type?(asset_type)
  end

  def validate_rights_updates
    return if primary_project.has_asset_rights # nothing to validate if assets rights are enabled for this project
    return if rights.reject { |k, _v| k.to_s == 'asset_access_restriction' }.blank? # asset_access_restriction updates are always allowed even if other asset rights updates aren't
    errors.add(:rights, "Asset-level rights assessment not enabled in #{primary_project.display_label}")
  end

  def validate_image_size_restriction
    allowed_restriction_values = Hyacinth::DigitalObject::Asset::ImageSizeRestriction::VALID_IMAGE_SIZE_RESTRICTIONS
    return if allowed_restriction_values.include?(self.image_size_restriction)
    errors.add(:asset_type, "Invalid image_size_restriction value: #{self.image_size_restriction}.  Must be one of: #{allowed_restriction_values.join(', ')}")
  end

  def validate_featured_thumbnail_region
    return if featured_thumbnail_region.blank?
    # ensure that region conforms to expected regex
    match_data = featured_thumbnail_region.match(FEATURED_THUMBNAIL_REGION_PATTERN)
    if match_data.nil?
      errors.add(:featured_thumbnail_region, "Invalid featured thumbnail region format. Must be for comma-delimited numbers (e.g. '5,10,100,100').")
      return
    end
    # ensure that region is a square
    errors.add(:featured_thumbnail_region, "Invalid featured thumbnail region. Must be a square region.") unless match_data[1] == match_data[2]
  end
end
