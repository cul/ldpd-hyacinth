# frozen_string_literal: true

module DigitalObjectConcerns::Assets::Validations
  extend ActiveSupport::Concern

  included do
    validates :asset_type, inclusion: { in: Hyacinth::DigitalObject::AssetType::VALID_TYPES, message: "Invalid asset type: %{value}" }
  end
end
