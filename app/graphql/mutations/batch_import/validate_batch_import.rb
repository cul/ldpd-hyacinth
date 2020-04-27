# frozen_string_literal: true

class Mutations::BatchImport::ValidateBatchImport < Mutations::BaseMutation
  argument :signed_blob_id, String, "Signed blob ID generated via `/api/v1/uploads`", required: true

  field :is_valid, Boolean, null: false
  field :errors, [String], null: true

  def resolve(signed_blob_id:, **attributes)
    ability.authorize! :create, BatchImport
    attributes[:user] = context[:current_user]

    begin
      blob = ActiveStorage::Blob.find_signed(signed_blob_id)
      is_valid, errors = BatchImport.pre_validate_blob(blob)
      { is_valid: is_valid, errors: errors }
    ensure
      blob&.destroy
    end
  end
end
