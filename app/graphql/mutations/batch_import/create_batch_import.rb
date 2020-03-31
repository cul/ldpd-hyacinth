# frozen_string_literal: true

class Mutations::BatchImport::CreateBatchImport < Mutations::BaseMutation
  argument :priority, Enums::BatchImportPriorityEnum, required: false
  argument :signed_blob_id, String, "Signed blob ID generated via `/api/v1/uploads`", required: true

  field :batch_import, Types::BatchImportType, null: false

  def resolve(signed_blob_id:, **attributes)
    ability.authorize! :create, BatchImport
    attributes[:user] = context[:current_user]

    blob = ActiveStorage::Blob.find_signed(signed_blob_id)
    batch_import = BatchImport.new(**attributes)

    begin
      batch_import.add_blob(blob)
      batch_import.save!
      { batch_import: batch_import }
    rescue StandardError => e
      Hyacinth::Config.batch_import_storage.delete(batch_import.location) if batch_import&.location
      raise e
    ensure
      blob&.destroy
    end
  end
end
