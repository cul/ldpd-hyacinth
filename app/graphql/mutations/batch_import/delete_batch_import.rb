# frozen_string_literal: true

class Mutations::BatchImport::DeleteBatchImport < Mutations::BaseMutation
  argument :id, ID, required: true

  field :batch_import, Types::BatchImportType, null: false

  def resolve(id:)
    batch_import = BatchImport.find(id)
    ability.authorize! :destroy, batch_import
    batch_import.destroy!

    { batch_import: batch_import }
  end
end
