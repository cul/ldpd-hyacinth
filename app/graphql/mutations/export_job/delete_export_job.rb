# frozen_string_literal: true

class Mutations::ExportJob::DeleteExportJob < Mutations::BaseMutation
  argument :id, ID, required: true

  field :export_job, Types::ExportJobType, null: false

  def resolve(id:)
    export_job = ExportJob.find(id)
    ability.authorize! :destroy, export_job
    export_job.destroy!

    { export_job: export_job }
  end
end
