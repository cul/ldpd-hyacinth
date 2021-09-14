# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_asset, mutation: Mutations::CreateAsset
    field :create_digital_object, mutation: Mutations::DigitalObject::CreateDigitalObject
    field :delete_digital_object, mutation: Mutations::DigitalObject::DeleteDigitalObject
    field :purge_digital_object, mutation: Mutations::DigitalObject::PurgeDigitalObject

    field :add_parent, mutation: Mutations::DigitalObject::AddParent
    field :remove_parent, mutation: Mutations::DigitalObject::RemoveParent

    field :create_resource, mutation: Mutations::DigitalObject::Resource::CreateResource
    field :delete_resource, mutation: Mutations::DigitalObject::Resource::DeleteResource

    field :update_resource_request, mutation: Mutations::ResourceRequest::UpdateResourceRequest
    field :delete_resource_request, mutation: Mutations::ResourceRequest::DeleteResourceRequest

    field :update_descriptive_metadata, mutation: Mutations::DigitalObject::UpdateDescriptiveMetadata
    field :update_rights, mutation: Mutations::DigitalObject::UpdateRights
    field :update_featured_thumbnail_region, mutation: Mutations::DigitalObject::UpdateFeaturedThumbnailRegion
    field :update_child_structure, mutation: Mutations::DigitalObject::UpdateChildStructure

    field :create_user, mutation: Mutations::CreateUser
    field :update_user, mutation: Mutations::UpdateUser

    field :create_project, mutation: Mutations::CreateProject
    field :update_project, mutation: Mutations::UpdateProject
    field :delete_project, mutation: Mutations::DeleteProject

    field :update_project_permissions, mutation: Mutations::UpdateProjectPermissions
    field :update_project_enabled_fields, mutation: Mutations::UpdateProjectEnabledFields

    field :create_publish_target, mutation: Mutations::CreatePublishTarget
    field :update_publish_target, mutation: Mutations::UpdatePublishTarget
    field :delete_publish_target, mutation: Mutations::DeletePublishTarget

    field :create_dynamic_field_category, mutation: Mutations::CreateDynamicFieldCategory
    field :update_dynamic_field_category, mutation: Mutations::UpdateDynamicFieldCategory
    field :delete_dynamic_field_category, mutation: Mutations::DeleteDynamicFieldCategory

    field :create_dynamic_field_group, mutation: Mutations::CreateDynamicFieldGroup
    field :update_dynamic_field_group, mutation: Mutations::UpdateDynamicFieldGroup
    field :delete_dynamic_field_group, mutation: Mutations::DeleteDynamicFieldGroup

    field :create_dynamic_field, mutation: Mutations::CreateDynamicField
    field :update_dynamic_field, mutation: Mutations::UpdateDynamicField
    field :delete_dynamic_field, mutation: Mutations::DeleteDynamicField

    field :create_batch_export, mutation: Mutations::BatchExport::CreateBatchExport
    field :delete_batch_export, mutation: Mutations::BatchExport::DeleteBatchExport

    field :create_batch_import, mutation: Mutations::BatchImport::CreateBatchImport
    field :validate_batch_import, mutation: Mutations::BatchImport::ValidateBatchImport
    field :update_batch_import, mutation: Mutations::BatchImport::UpdateBatchImport
    field :delete_batch_import, mutation: Mutations::BatchImport::DeleteBatchImport
    field :start_batch_import, mutation: Mutations::BatchImport::StartBatchImport

    field :create_field_export_profile, mutation: Mutations::FieldExportProfile::CreateFieldExportProfile
    field :update_field_export_profile, mutation: Mutations::FieldExportProfile::UpdateFieldExportProfile
    field :delete_field_export_profile, mutation: Mutations::FieldExportProfile::DeleteFieldExportProfile

    field :create_field_set, mutation: Mutations::FieldSet::CreateFieldSet
    field :update_field_set, mutation: Mutations::FieldSet::UpdateFieldSet
    field :delete_field_set, mutation: Mutations::FieldSet::DeleteFieldSet

    field :create_term, mutation: Mutations::Term::CreateTerm
    field :update_term, mutation: Mutations::Term::UpdateTerm
    field :delete_term, mutation: Mutations::Term::DeleteTerm

    field :create_vocabulary, mutation: Mutations::Vocabulary::CreateVocabulary
    field :update_vocabulary, mutation: Mutations::Vocabulary::UpdateVocabulary
    field :delete_vocabulary, mutation: Mutations::Vocabulary::DeleteVocabulary
  end
end
