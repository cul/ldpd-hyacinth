# frozen_string_literal: true

class Mutations::ExportJob::CreateExportJob < Mutations::BaseMutation
  argument :user_id, Integer, required: true
  argument :search_params, String, required: true

  field :export_job, Types::ExportJobType, null: true

  def resolve(**attributes)
    # Note: No ability-based authorization for creating a CSV export.
    # Just need to be a logged in user. The Hyacinth search function won't
    # return results if you don't have permission to view those results.
    export_job = ExportJob.new(**attributes)
    export_job.save!

    { export_job: export_job }
  end
end
