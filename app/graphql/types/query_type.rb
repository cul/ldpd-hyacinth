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

    def project(string_key:)
      project = Project.find_by!(string_key: string_key)
      context[:ability].authorize!(:show, project)
      project
    end

    def projects
      context[:ability].authorize!(:index, Project)
      Project.accessible_by(context[:ability])
    end

    def user(id:)
      user = User.find_by!(uid: id)
      context[:ability].authorize!(:show, user)
      user
    end

    def users
      context[:ability].authorize!(:index, User)
      User.all.order(:last_name)
    end

    def authenticated_user
      context[:current_user]
    end
  end
end
