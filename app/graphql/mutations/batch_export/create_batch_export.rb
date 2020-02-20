# frozen_string_literal: true

class Mutations::BatchExport::CreateBatchExport < Mutations::BaseMutation
  argument :search_params, String, required: true

  field :batch_export, Types::BatchExportType, null: true

  def resolve(**attributes)
    # Note: No ability-based authorization for creating a CSV export.
    # Just need to be a logged in user. The Hyacinth search function won't
    # return results if you don't have permission to view those results.

    attributes[:user] = context[:current_user]
    batch_export = BatchExport.new(**attributes)
    batch_export.save!

    { batch_export: batch_export }
  end
end
