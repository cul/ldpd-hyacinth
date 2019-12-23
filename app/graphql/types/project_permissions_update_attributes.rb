# frozen_string_literal: true

module Types
  class ProjectPermissionsUpdateAttributes < Types::BaseInputObject
    description 'An array of permission String values for a project + user combination.'

    argument :project_string_key, String, "String key for project", required: true
    argument :user_id, ID, "ID for user", required: true
    argument(
      :permissions,
      [String],
      "An array representing the new set of permissions the given user should have in the given project, "\
      "or an empty array to remove all project permissions for the given user.",
      required: true
    )
  end
end
