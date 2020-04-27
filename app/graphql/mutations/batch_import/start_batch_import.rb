# frozen_string_literal: true

class Mutations::BatchImport::StartBatchImport < Mutations::BaseMutation
  argument :id, ID, required: true

  field :batch_import, Types::BatchImportType, null: false

  def resolve(id:)
    batch_import = BatchImport.find(id)
    ability.authorize! :update, batch_import

    Resque.enqueue(BatchImportSetupJob, batch_import.id)
    { batch_import: batch_import }
  end
end
