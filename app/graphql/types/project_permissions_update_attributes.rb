# frozen_string_literal: true

module Types
  class ProjectPermissionsUpdateAttributes < Types::BaseInputObject
    description 'A project string key / user id combination, plus the new set of '\
      'permission actions for that combination. Sending an empty actions array '\
      'clears all existing project actions for the given project / user combo.'

    argument :project_string_key, String, "String key for project", required: true
    argument :user_id, ID, "ID for user", required: true
    argument(
      :actions,
      [String],
      "An array representing the new set of actions the given user should have in the given project, "\
      "or an empty array to remove all project actions for the given user.",
      required: true
    )
  end
end
