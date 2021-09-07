# frozen_string_literal: true

module Types
  class ChildStructureType < Types::BaseObject
    description 'A representation of how child objects are organized'
    field :type, String, null: false
    field :structure, [DigitalObjectInterface], null: false
  end
end
