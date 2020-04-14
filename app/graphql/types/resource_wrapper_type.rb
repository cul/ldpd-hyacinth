# frozen_string_literal: true

module Types
  class ResourceWrapperType < Types::BaseObject
    description 'A resource wrapper object that includes id and display_label'

    field :id, ID, null: false
    field :display_label, String, null: false
    field :resource, ResourceType, null: true
  end
end
