# frozen_string_literal: true

class Mutations::UpdateProjectPermissions < Mutations::BaseMutation
  argument :project_permissions, [Types::ProjectPermissionsAttributes], required: true

  field :errors, [String], null: false

  def resolve(project_permissions:)
    projects = {}
    users = {}
    new_permissions = []

    # This should be an all or nothing update
    ActiveRecord::Base.transaction do
      project_permissions.each do |project_permission|
        project_string_key = project_permission.project_string_key
        user_id = project_permission.user_id
        permissions = project_permission.permissions
        
        # Cache projects and users for future lookups as we iterate through project permissions
        project = projects[project_string_key] ||= Project.find_by!(string_key: project_string_key)
        user = users[user_id] ||= User.find_by!(uid: user_id)
        
        # Ensure that the user initiating this update is allowed to do so for the given project
        ability.authorize! :update, project

        # Perform update by clearing out all old permissions for this user+project combo
        # TODO: In Rails 6, change operation below Permission.delete_by(...)
        Permission.where(user: user, subject: 'Project', subject_id: project.id).delete_all
        
        # And then create all of the appropriate new permissions
        permissions.each do |permission|
          Permission.create!(user: user, subject: 'Project', subject_id: project.id, action: permission)
        end
      end
    end

    {
      errors: [],
    }
  end
end
