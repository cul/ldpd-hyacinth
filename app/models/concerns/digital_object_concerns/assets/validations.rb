# frozen_string_literal: true

module DigitalObjectConcerns::Assets::Validations
  extend ActiveSupport::Concern

  included do
    validate :validate_type
    validate :validate_rights_updates
  end

  def validate_type
    errors.add(:asset_type, "Invalid asset type: #{asset_type}") unless BestType.pcdm_type.valid_type?(asset_type)
  end

  def validate_rights_updates
    return unless rights.keys.detect { |key| rights[key].present? && !'restriction_on_access'.eql?(key.to_s) }
    errors.add(:rights, "Asset-level rights assessment not enabled in #{primary_project.display_label}") unless primary_project.has_asset_rights
  end
end
