# frozen_string_literal: true

module Types
  module DigitalObject
    class MinimalRecord < Types::BaseObject
      description 'A minimal representation of a digital object used for search results'

      field :id, ID, null: false
      field :title, String, null: false
      field :digital_object_type, Enums::DigitalObjectTypeEnum, null: false
      field :projects, [ProjectType], null: false
      field :number_of_children, Integer, null: false
      field :parent_ids, [ID], null: false
    end
  end
end
