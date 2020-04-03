# frozen_string_literal: true

class Mutations::CreateAsset < Mutations::BaseMutation
  argument :signed_blob_id, String, "Signed blob ID generated via `/api/v1/uploads`", required: true
  argument :parent_id, ID, required: true

  field :asset, Types::DigitalObject::AssetType, null: true

  def resolve(signed_blob_id:, parent_id:)
    parent = DigitalObject::Item.find(parent_id)
    ability.authorize! :create_objects, parent.primary_project
    blob = ActiveStorage::Blob.find_signed(signed_blob_id)
    asset = initialize_child_asset(parent, blob.filename.to_s)
    asset.dynamic_field_data['title'] = [{ 'sort_portion' => blob.filename.to_s }]
    begin
      asset.resource_imports[asset.primary_resource_name] = Hyacinth::DigitalObject::ResourceImport.new(
        method: Hyacinth::DigitalObject::ResourceImport::COPY,
        location: blob
      )
      asset.save!
      { asset: asset }
    ensure
      blob&.purge
    end
  end

  def initialize_child_asset(parent, file_name)
    asset = DigitalObject::Asset.new
    asset.primary_project = parent.primary_project
    asset.add_parent_uid(parent.uid)
    asset.asset_type = BestType.pcdm_type.for_file_name(file_name)
    asset
  end
end
