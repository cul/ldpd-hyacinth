# frozen_string_literal: true

class Mutations::BatchExport::CreateBatchExport < Mutations::BaseMutation
  argument :search_params, Types::SearchAttributes, required: true

  field :batch_export, Types::BatchExportType, null: true

  def resolve(**attributes)
    ability.authorize! :create, BatchExport
    create_attributes = {}.merge(attributes)
    create_attributes[:user] = context[:current_user]
    create_attributes[:search_params] = JSON.generate(attributes[:search_params].prepare)
    batch_export = BatchExport.new(**create_attributes)
    batch_export.save!

    Resque.enqueue(BatchExportJob, batch_export.id)

    { batch_export: batch_export }
  end
end
