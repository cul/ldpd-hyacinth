# frozen_string_literal: true

module Types
  module DigitalObject
    class ItemType < Types::BaseObject
      implements Types::DigitalObjectInterface

      # ... additional fields
      field :rights, Types::DigitalObject::ItemRightsType, null: true
    end
  end
end
