# frozen_string_literal: true

class Mutations::UpdateProjectPermissions < Mutations::BaseMutation
  argument :project_permissions_update, [Types::ProjectPermissionsUpdateAttributes], required: true

  field :project_permissions, [Types::ProjectPermissionsType], null: false

  def resolve(project_permissions_update:)
    projects = {}
    users = {}

    # This should be an all or nothing update
    ActiveRecord::Base.transaction do
      project_permissions_update.each do |project_permission|
        project_string_key = project_permission.project_string_key
        user_id = project_permission.user_id
        permission_actions = project_permission.actions

        # Cache projects and users for future lookups
        project = projects[project_string_key] ||= Project.find_by!(string_key: project_string_key)
        user = users[user_id] ||= User.find_by!(uid: user_id)

        # Ensure that the user initiating this update is allowed to do so for the given project
        ability.authorize! :update, project

        apply_new_permission_actions(project, user, permission_actions)
      end
    end

    # If we got here, there weren't any errors and we can return all of the
    # successfully updated project permissions data.
    project_permissions_response(project_permissions_update, users, projects)
  end

  def project_permissions_response(project_permissions_update, users, projects)
    {
      project_permissions: project_permissions_update.map do |data|
        {
          user: users[data.user_id],
          project: projects[data.project_string_key],
          actions: data['actions']
        }
      end
    }
  end

  def apply_new_permission_actions(project, user, permission_actions)
    # Perform update by clearing out all old permissions for this user+project combo
    # TODO: In Rails 6, change operation below Permission.delete_by(...)
    Permission.where(user: user, subject: 'Project', subject_id: project.id).delete_all

    # And then create all of the appropriate new permissions:

    # If the manage permission has been provided, enable all applicable project actions.
    permission_actions = Permission::PROJECT_ACTIONS if permission_actions.include?(Permission::PROJECT_ACTION_MANAGE)

    permission_actions.each do |permission_action|
      Permission.create!(user: user, subject: 'Project', subject_id: project.id, action: permission_action)
    end
  end
end
