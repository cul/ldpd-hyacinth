# frozen_string_literal: true

class Mutations::UpdateProjectPermissions < Mutations::BaseMutation
  argument :project_permissions, [Types::ProjectPermissionsAttributes], required: true

  field :errors, [String], null: false

  def resolve(project_permissions:)
    projects = {}
    users = {}

    # This should be an all or nothing update
    ActiveRecord::Base.transaction do
      project_permissions.each do |project_permission|
        project_string_key = project_permission.project_string_key
        user_id = project_permission.user_id
        permission_actions = project_permission.permissions

        # Cache projects and users for future lookups
        project = projects[project_string_key] ||= Project.find_by!(string_key: project_string_key)
        user = users[user_id] ||= User.find_by!(uid: user_id)

        # Ensure that the user initiating this update is allowed to do so for the given project
        ability.authorize! :update, project

        apply_new_permission_actions(project, user, permission_actions)
      end
    end

    { errors: [] }
  end

  def apply_new_permission_actions(project, user, permission_actions)
    # Perform update by clearing out all old permissions for this user+project combo
    # TODO: In Rails 6, change operation below Permission.delete_by(...)
    Permission.where(user: user, subject: 'Project', subject_id: project.id).delete_all

    # And then create all of the appropriate new permissions:

    # If the manage permission has been provided, enable all possible project actions.
    permission_actions = Permission::PROJECT_ACTIONS if permission_actions.include?(Permission::PROJECT_ACTION_MANAGE)
    permission_actions.each do |permission_action|
      Permission.create!(user: user, subject: 'Project', subject_id: project.id, action: permission_action)
    end
  end
end
