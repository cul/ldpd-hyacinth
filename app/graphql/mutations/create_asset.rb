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
    begin
      resource = initialize_asset_resource_for_blob(asset, blob, Hyacinth::Config.resource_storage)
      asset.dynamic_field_data['title'] = [{
        'sort_portion' => blob.filename.to_s
      }]
      asset.save!
      { asset: asset }
    rescue StandardError => e
      cleanup_on_failure(asset, resource)
      raise e
    ensure
      blob&.destroy
    end
  end

  def initialize_child_asset(parent, file_name)
    asset = DigitalObject::Asset.new
    asset.primary_project = parent.primary_project
    asset.add_parent_uid(parent.uid)
    asset.asset_type = BestType.pcdm_type.for_file_name(file_name)
    asset
  end

  def initialize_asset_resource_for_blob(asset, blob, storage)
    asset.with_primary_resource do |_resource_name, resource|
      resource.original_filename = blob.filename.to_s
      resource.media_type = BestType.mime_type.for_file_name(blob.filename.to_s)
      resource.location = storage.generate_new_managed_location_uri(SecureRandom.uuid, 'upload')
      storage.with_writable(resource.location) do |output_file|
        blob.download { |chunk| output_file << chunk }
      end
    end
  end

  def cleanup_on_failure(asset, resource)
    Hyacinth::Config.resource_storage.delete(resource.location) if resource&.location
    asset.destroy unless asset.new_record?
  end
end
