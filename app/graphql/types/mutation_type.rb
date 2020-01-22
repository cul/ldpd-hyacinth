# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_asset, mutation: Mutations::CreateAsset

    field :create_user, mutation: Mutations::CreateUser
    field :update_user, mutation: Mutations::UpdateUser

    field :create_project, mutation: Mutations::CreateProject
    field :update_project, mutation: Mutations::UpdateProject
    field :delete_project, mutation: Mutations::DeleteProject

    field :update_project_permissions, mutation: Mutations::UpdateProjectPermissions

    field :create_publish_target, mutation: Mutations::CreatePublishTarget
    field :update_publish_target, mutation: Mutations::UpdatePublishTarget
    field :delete_publish_target, mutation: Mutations::DeletePublishTarget

    field :create_dynamic_field_category, mutation: Mutations::CreateDynamicFieldCategory
    field :update_dynamic_field_category, mutation: Mutations::UpdateDynamicFieldCategory
    field :delete_dynamic_field_category, mutation: Mutations::DeleteDynamicFieldCategory

    field :create_dynamic_field_group, mutation: Mutations::CreateDynamicFieldGroup
    field :update_dynamic_field_group, mutation: Mutations::UpdateDynamicFieldGroup
    field :delete_dynamic_field_group, mutation: Mutations::DeleteDynamicFieldGroup

    field :create_field_set, mutation: Mutations::FieldSet::CreateFieldSet
    field :update_field_set, mutation: Mutations::FieldSet::UpdateFieldSet
    field :delete_field_set, mutation: Mutations::FieldSet::DeleteFieldSet

    field :create_vocabulary, mutation: Mutations::Vocabulary::CreateVocabulary
    field :update_vocabulary, mutation: Mutations::Vocabulary::UpdateVocabulary
    field :delete_vocabulary, mutation: Mutations::Vocabulary::DeleteVocabulary

    field :create_term, mutation: Mutations::Term::CreateTerm
    field :update_term, mutation: Mutations::Term::UpdateTerm
    field :delete_term, mutation: Mutations::Term::DeleteTerm
  end
end
