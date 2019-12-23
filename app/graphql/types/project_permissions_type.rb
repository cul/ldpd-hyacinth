# frozen_string_literal: true

module Types
  class ProjectPermissionsType < Types::BaseObject
    description 'An array of allowed actions for a user + project combination.'

    field :user, UserType, null: false
    field :project, ProjectType, null: false
    field :actions, [String], null: false
  end
end
