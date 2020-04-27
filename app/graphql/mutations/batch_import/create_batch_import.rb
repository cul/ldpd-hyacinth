# frozen_string_literal: true

class Mutations::BatchImport::CreateBatchImport < Mutations::BaseMutation
  argument :priority, Enums::BatchImportPriorityEnum, required: false
  argument :signed_blob_id, String, "Signed blob ID generated via `/api/v1/uploads`", required: true

  field :batch_import, Types::BatchImportType, null: true
  field :is_valid, Boolean, null: false
  field :errors, [String], null: true

  def resolve(signed_blob_id:, **attributes)
    ability.authorize! :create, BatchImport
    attributes[:user] = context[:current_user]

    blob = ActiveStorage::Blob.find_signed(signed_blob_id)
    is_valid, errors = BatchImport.pre_validate_blob(blob)

    begin
      batch_import = is_valid ? create_batch_export_and_enqueue_setup_job(attributes, blob) : nil
      { batch_import: batch_import, is_valid: is_valid, errors: errors }
    rescue StandardError => e
      Hyacinth::Config.batch_import_storage.delete(batch_import.file_location) if batch_import&.file_location
      raise e
    ensure
      blob&.destroy
    end
  end

  def create_batch_export_and_enqueue_setup_job(attributes, blob)
    batch_import = BatchImport.new(**attributes)
    batch_import.add_blob(blob)
    batch_import.save!
    batch_import
  end
end
