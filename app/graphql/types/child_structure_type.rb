# frozen_string_literal: true

module Types
  class ChildStructureType < Types::BaseObject
    description 'A resolved description of how child objects should be organized'
    field :parent, DigitalObjectInterface, null: false
    field :type, String, null: false
    field :structure, [DigitalObjectInterface], null: false
  end
end
