# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :authenticated_user, AuthenticatedUserType, null: true do
      description 'Logged-in user'
    end

    field :users, [UserType], null: true do
      description 'List of all users'
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

    field :permission_actions, PermissionActionsType, null: true do
      description 'Information about available project permission actions.'
    end

    field :vocabulary, VocabularyType, null: true do
      argument :string_key, ID, required: true
    end

    field :vocabularies, [VocabularyType], null: true do
      description "List of all vocabularies"
      argument :limit, Integer, required: true
      argument :offset, Integer, required: false
    end

    def digital_objects
      # This is a temporary implementation, this should actually querying solr
      # and considering object read permissions.
      DigitalObjectRecord.all
    end

    def digital_object(id:)
      digital_object = ::DigitalObject::Base.find(id)
      ability.authorize!(:read, digital_object)
      digital_object

    def vocabulary(string_key:)
      ability.authorize!(:read, :vocabulary)
      response = URIService.connection.vocabulary(string_key)
      raise(GraphQL::ExecutionError, response.data['errors'].map { |e| e['title'] }.join('; ')) if response.errors?
      response.data['vocabulary']
    end

    def vocabularies(limit:, offset: 0)
      ability.authorize!(:read, :vocabulary)
      response = URIService.connection.vocabularies(limit: limit, offset: offset)
      raise(GraphQL::ExecutionError, response.data['errors'].map { |e| e['title'] }.join('; ')) if response.errors?
      response.data['vocabularies']
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
      User.accessible_by(ability).order(:sort_name)
    end

    def permission_actions
      {
        project_actions: Permission::PROJECT_ACTIONS,
        primary_project_actions: Permission::PRIMARY_PROJECT_ACTIONS,
        aggregator_project_actions: Permission::AGGREGATOR_PROJECT_ACTIONS
      }
    end

    def authenticated_user
      context[:current_user]
    end
  end
end
