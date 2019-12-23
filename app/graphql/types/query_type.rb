# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :authenticated_user, AuthenticatedUserType, null: true do
      description 'Logged-in user'
    end

    field :users, [UserType], null: true do
      description "List of all users"
    end

    field :user, UserType, null: true do
      description "Find a user by ID"
      argument :id, ID, required: true
    end

    field :project, ProjectType, null: true do
      argument :string_key, ID, required: true
    end

    field :projects, [ProjectType], null: true do
      description "List of all projects"
    end

    field :digital_objects, [DigitalObjectInterface], null: true do
      description "List and searches all digital objects"
    end

    field :digital_object, DigitalObjectInterface, null: true do
      argument :id, ID, required: true
    end

    field :project_permissions_for_project, [ProjectPermissionsType], null: true do
      argument :string_key, String, required: true
    end

    field :project_permission_actions, ProjectPermissionActionsType, null: true do
      description 'Information about available project permission actions.'
    end

    def digital_objects
      # This is a temporary implementation, this should actually querying the solr instance.
      DigitalObjectRecord.all
    end

    def digital_object(id:)
      digital_object = ::DigitalObject::Base.find(id)
      ability.authorize!(:read, digital_object)
      digital_object
    end

    def project(string_key:)
      project = Project.find_by!(string_key: string_key)
      ability.authorize!(:read, project)
      project
    end

    def projects
      ability.authorize!(:read, Project)
      Project.accessible_by(ability)
    end

    def user(id:)
      user = User.find_by!(uid: id)
      ability.authorize!(:read, user)
      user
    end

    def users
      ability.authorize!(:index, User)
      User.accessible_by(ability).order(:last_name)
    end

    def project_permission_actions
      ability.authorize!(:read, Project)
      {
        actions: Permission::PROJECT_ACTIONS,
        read_objects_action: Permission::PROJECT_ACTION_READ_OBJECTS,
        manage_action: Permission::PROJECT_ACTION_MANAGE
      }
    end

    def project_permissions_for_project(string_key:)
      # Note: In the future, we'll likely have a project_permissions_for_user method as well.
      project = Project.find_by!(string_key: string_key)
      ability.authorize!(:update, project)
      user_permissions = {}
      permissions = Permission.where(subject: 'Project', subject_id: project.id)
      permissions.each do |permission|
        user_permissions[permission.user_id] ||= {
          user: permission.user,
          project: project
        }
        user_permissions[permission.user_id]['permissions'] ||= []
        user_permissions[permission.user_id]['permissions'] << permission.action
      end
      user_permissions.values
    end

    def authenticated_user
      context[:current_user]
    end

    def ability
      context[:ability]
    end
  end
end
