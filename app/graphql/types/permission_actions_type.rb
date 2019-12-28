# frozen_string_literal: true

module Types
  class PermissionActionsType < Types::BaseObject
    description 'Information about available permission actions.'

    field :project_actions, [String], null: false
    field :primary_project_actions, [String], null: false
    field :aggregator_project_actions, [String], null: false
  end
end
