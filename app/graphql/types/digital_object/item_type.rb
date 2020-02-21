# frozen_string_literal: true

module Types
  module DigitalObject
    class ItemType < Types::BaseObject
      implements Types::DigitalObjectInterface

      field :rights, Types::DigitalObject::ItemRightsType, null: true
    end
  end
end
