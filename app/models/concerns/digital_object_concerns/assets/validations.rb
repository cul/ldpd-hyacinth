# frozen_string_literal: true

module DigitalObjectConcerns::Assets::Validations
  extend ActiveSupport::Concern

  included do
    validate :validate_master_resource
    validate :validate_type
    validate :validate_rights_updates
  end

  def validate_master_resource
    return if resources[self.primary_resource_name].present? || resource_imports[self.primary_resource_name].present?
    errors.add("resources[#{primary_resource_name}]", "Missing primary resource: #{primary_resource_name}")
  end

  def validate_type
    if asset_type.blank?
      errors.add(:asset_type, "Missing asset type (probably because of missing master resource)")
      return
    end

    errors.add(:asset_type, "Invalid asset type: #{asset_type}") unless BestType.pcdm_type.valid_type?(asset_type)
  end

  def validate_rights_updates
    return unless rights.keys.detect { |key| rights[key].present? && !'restriction_on_access'.eql?(key.to_s) }
    errors.add(:rights, "Asset-level rights assessment not enabled in #{primary_project.display_label}") unless primary_project.has_asset_rights
  end
end
