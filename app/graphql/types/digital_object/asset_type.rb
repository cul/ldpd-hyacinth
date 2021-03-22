# frozen_string_literal: true

module Types
  module DigitalObject
    class AssetType < Types::BaseObject
      implements Types::DigitalObjectInterface

      field :asset_type, Enums::AssetTypeEnum, null: false # enum delegating to BestType library
      field :featured_thumbnail_region, String, null: true
    end
  end
end
