# frozen_string_literal: true

class Mutations::BatchImport::UpdateBatchImport < Mutations::BaseMutation
  argument :id, ID, required: true
  argument :cancelled, Boolean, required: false

  field :batch_import, Types::BatchImportType, null: false

  def resolve(id:, **attributes)
    batch_import = BatchImport.find(id)
    ability.authorize! :update, batch_import
    batch_import.update!(**attributes)

    { batch_import: batch_import }
  end
end
