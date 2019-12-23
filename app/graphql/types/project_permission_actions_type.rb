# frozen_string_literal: true

module Types
  class ProjectPermissionActionsType < Types::BaseObject
    description 'Information about available project permission actions.'

    field :actions, [String], null: false
    field :actions_disallowed_for_aggregator_projects, [String], null: false
    field :read_objects_action, String, null: false
    field :manage_action, String, null: false
  end
end
