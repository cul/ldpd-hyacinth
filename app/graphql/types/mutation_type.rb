# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_user, mutation: Mutations::CreateUser
    field :update_user, mutation: Mutations::UpdateUser
    field :impersonate_user, mutation: Mutations::ImpersonateUser

    field :create_project, mutation: Mutations::CreateProject
    field :update_project, mutation: Mutations::UpdateProject
    field :delete_project, mutation: Mutations::DeleteProject

    field :update_project_permissions, mutation: Mutations::UpdateProjectPermissions

    field :create_publish_target, mutation: Mutations::CreatePublishTarget
    field :update_publish_target, mutation: Mutations::UpdatePublishTarget
    field :delete_publish_target, mutation: Mutations::DeletePublishTarget

    field :create_field_set, mutation: Mutations::FieldSet::CreateFieldSet
    field :update_field_set, mutation: Mutations::FieldSet::UpdateFieldSet
    field :delete_field_set, mutation: Mutations::FieldSet::DeleteFieldSet
  end
end
