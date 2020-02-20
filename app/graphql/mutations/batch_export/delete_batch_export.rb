# frozen_string_literal: true

class Mutations::BatchExport::DeleteBatchExport < Mutations::BaseMutation
  argument :id, ID, required: true

  field :batch_export, Types::BatchExportType, null: false

  def resolve(id:)
    batch_export = BatchExport.find(id)
    ability.authorize! :destroy, batch_export
    batch_export.destroy!

    { batch_export: batch_export }
  end
end
