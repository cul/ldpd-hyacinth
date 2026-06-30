class Api::V2::DigitalObjectImportsController < Api::V2::BaseController
  before_action :set_import_job
  before_action :set_digital_object_import, only: [:show]

  # GET /api/v2/import_jobs/:import_job_id/digital_object_imports
  # Optional query params:
  # - ?status=pending|success|failure
  # - ?page=N
  def index
    scope = @import_job.digital_object_imports
    scope = scope.where(status: DigitalObjectImport.statuses[status_filter]) if status_filter

    @digital_object_imports = scope
      .order(csv_row_number: :asc)
      .page(params[:page])
      .per(2) # temp

    render_camelized_json({
      digital_object_imports: @digital_object_imports.map { |doi| digital_object_import_list_json(doi) },
      pagination: pagination_data(@digital_object_imports),
      status_filter: status_filter,
      import_job_name: @import_job.name,
    })
  end

  # GET /api/v2/import_jobs/:import_job_id/digital_object_imports/:id
  def show
    render_camelized_json({
      digital_object_import: digital_object_import_detail_json(@digital_object_import, @import_job)
    })
  end

  private

    def set_import_job
      @import_job = ImportJob.find(params[:import_job_id])

      # If the user is not authorized to view this import job, we also want to prevent them
      # from viewing the digital object imports that belong to this import job.
      authorize! :show, @import_job
    end

    def set_digital_object_import
      @digital_object_import = @import_job.digital_object_imports.find(params[:id])
    end

    def status_filter
      key = params[:status]
      key.present? && DigitalObjectImport.statuses.key?(key) ? key : nil
    end

    def pagination_data(scope)
      {
        current_page: scope.current_page,
        per_page: scope.limit_value,
        total_pages: scope.total_pages,
        total_count: scope.total_count
      }
    end

    def digital_object_import_list_json(doi)
      {
        id: doi.id,
        csv_row_number: doi.csv_row_number,
        status: doi.status,
        created_at: doi.created_at,
        updated_at: doi.updated_at
      }
    end

    def digital_object_import_detail_json(doi, import_job)
      {
        id: doi.id,
        import_job_id: doi.import_job_id,
        import_job_name: import_job.name,
        csv_row_number: doi.csv_row_number,
        status: doi.status,
        digital_object_data: doi.digital_object_data,
        digital_object_errors: doi.digital_object_errors,
        prerequisite_csv_row_numbers: doi.prerequisite_csv_row_numbers,
        created_at: doi.created_at,
        updated_at: doi.updated_at,
      }
    end
end
