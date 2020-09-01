# frozen_string_literal: true

module Types
  module DigitalObject
    class SearchRecord < Types::BaseObject
      description 'A limited-field variation of a Digital Object used for search results'

      field :id, ID, null: false
      field :title, String, null: false
      field :digital_object_type, Enums::DigitalObjectTypeEnum, null: false
      field :projects, [ProjectType], null: false
      field :number_of_children, Integer, null: false
      field :parent_ids, [ID], null: false
    end
  end
end
