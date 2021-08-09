# frozen_string_literal: true

class Mutations::CreateAsset < Mutations::BaseMutation
  argument :parent_id, ID, required: true
  argument  :file_location, String,
            "ActiveStorage signed blob id URI (e.g. blob://abcdefg), file URI (file:///path/to/file), or other type of supported import location.",
            required: true

  field :asset, Types::DigitalObject::AssetType, null: true

  def resolve(file_location:, parent_id:)
    parent = DigitalObject.find_by_uid(parent_id)
    ability.authorize! :create_objects, parent.primary_project

    # At this time, non-admins can only perform blob-based asset creation
    raise GraphQL::ExecutionError, 'You are only authorized to create assets from ActiveStorage blob uploads.' unless file_location.start_with?('blob://') || ability.can?(:manage, :all)

    asset = initialize_child_asset(parent)
    asset.resource_imports[asset.main_resource_name] = Hyacinth::DigitalObject::ResourceImport.new(
      method: Hyacinth::DigitalObject::ResourceImport::COPY,
      location: file_location
    )
    asset.save!
    { asset: asset }
  ensure
    # If the file location was an ActiveStorage blob, make sure to delete it now that we're done with it.
    ActiveStorage::Blob.find_signed(file_location.sub('blob://', ''))&.purge if file_location.start_with?('blob://')
  end

  def initialize_child_asset(parent)
    asset = DigitalObject::Asset.new
    asset.primary_project = parent.primary_project
    asset.parents_to_add << parent
    asset
  end
end
