# frozen_string_literal: true

class Mutations::BatchExport::CreateBatchExport < Mutations::BaseMutation
  argument :search_params, String, required: true

  field :batch_export, Types::BatchExportType, null: true

  def resolve(**attributes)
    ability.authorize! :create, BatchExport

    attributes[:user] = context[:current_user]
    batch_export = BatchExport.new(**attributes)
    batch_export.save!

    { batch_export: batch_export }
  end
end
