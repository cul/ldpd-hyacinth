# frozen_string_literal: true

module DigitalObjectConcerns::Assets::Validations
  extend ActiveSupport::Concern

  included do
    validate :validate_type
  end

  def validate_type
    errors.add(:asset_type, "Invalid asset type: #{asset_type}") unless BestType.pcdm_type.valid_type?(asset_type)
  end
end
