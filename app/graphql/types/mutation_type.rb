module Types
  class MutationType < Types::BaseObject
    field :create_user, mutation: Mutations::CreateUser
    field :update_user, mutation: Mutations::UpdateUser

    field :create_project, mutation: Mutations::CreateProject
    field :update_project, mutation: Mutations::UpdateProject
    field :delete_project, mutation: Mutations::DeleteProject

    field :create_publish_target, mutation: Mutations::CreatePublishTarget
    field :update_publish_target, mutation: Mutations::UpdatePublishTarget
    field :delete_publish_target, mutation: Mutations::DeletePublishTarget

    field :create_field_set, mutation: Mutations::CreateFieldSet
    field :update_field_set, mutation: Mutations::UpdateFieldSet
  end
end
