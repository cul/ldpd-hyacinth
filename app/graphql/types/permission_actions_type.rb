# frozen_string_literal: true

module Types
  class PermissionActionsType < Types::BaseObject
    description 'Information about available permission actions.'

    field :project_actions, [String], null: false
  end
end
