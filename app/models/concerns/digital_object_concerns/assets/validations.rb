# frozen_string_literal: true

module DigitalObjectConcerns::Assets::Validations
  extend ActiveSupport::Concern

  included do
    validates :asset_type, inclusion: { in: Hyacinth::DigitalObject::AssetType::VALID_TYPES, message: "Invalid asset type: %{value}" }
    validate :validate_rights_updates
  end

  def validate_rights_updates
    return unless rights.keys.detect { |key| rights[key].present? && !'access_condition'.eql?(key.to_s) }
    errors.add(:rights, "Asset-level rights assessment not enabled in #{primary_project.display_label}") unless primary_project.has_asset_rights
  end
end
