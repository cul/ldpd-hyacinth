class Api::V2::ImportJobsController < Api::V2::BaseController
  before_action :set_import_job, only: [:show, :download_original_csv, :destroy]

  # GET /import_jobs
  def index
    scope = current_user.admin? ? ImportJob.all : ImportJob.where(user: current_user)
    per_page = 5 # temp

    @import_jobs = scope
      .includes(:user)
      .order(id: :desc)
      .page(params[:page])
      .per(per_page)

    render_camelized_json({
      import_jobs: @import_jobs.map { |import_job| import_job_list_json(import_job) },
      pagination: pagination_data(@import_jobs)
    })
  end

  # POST /api/v2/import_jobs
  def create
    return render_missing_file_error if uploaded_csv_file.blank?
    return render_invalid_priority_error unless valid_priority?

    @import_job = Hyacinth::Utils::CsvImportExportUtils.create_import_job_from_csv_data(
      uploaded_csv_file.read,
      uploaded_csv_file.original_filename,
      current_user,
      requested_priority.to_sym
    )

    if @import_job.errors.any?
      render_camelized_json({ errors: format_errors(@import_job.errors) }, status: :unprocessable_entity)
    else
      render_camelized_json({ import_job: import_job_json(@import_job) }, status: :created)
    end
  end

  # POST /api/v2/import_jobs/validate
  def validate
    return render_missing_file_error if uploaded_csv_file.blank?
    return render_invalid_priority_error unless valid_priority?

    import_job = ImportJob.new
    Hyacinth::Utils::CsvImportExportUtils.validate_import_job_csv_data(
      uploaded_csv_file.read, current_user, import_job
    )

    if import_job.errors.any?
      render_camelized_json({ valid: false, errors: format_errors(import_job.errors) }, status: :unprocessable_entity)
    else
      render_camelized_json({ valid: true, message: 'The submitted CSV file appears to be valid.' })
    end
  end

  # GET /api/v2/import_jobs/:id
  def show
    # authorize! :show, @import_job
    render_camelized_json({ import_job: import_job_detail_json(@import_job) })
  end

  # GET /api/v2/import_jobs/queue_activity
  def queue_activity
    counts = [:low, :medium, :high].map do |priority|
      [
        priority,
        DigitalObjectImport
          .joins(:import_job)
          .where(status: :pending, import_jobs: { priority: priority })
          .count
      ]
    end.to_h

    render_camelized_json({ queue_activity: counts })
  end

  def download_original_csv
    if @import_job.path_to_csv_file.present?
      # TODO
    end
  end

  # DELETE /api/v2/import_jobs/:id
  def destroy
    @import_job.destroy
  end

  private

    def uploaded_csv_file
      file = params[:import_file]
      file.is_a?(ActionDispatch::Http::UploadedFile) ? file : nil
    end

    def requested_priority
      params.fetch(:priority, 'low')
    end

    def valid_priority?
      requested_priority.present? &&
        Hyacinth::Queue.const_defined?("DIGITAL_OBJECT_IMPORT_#{requested_priority.upcase}")
    end

    def render_missing_file_error
      render_camelized_json({ errors: { file: ['is required.'] } }, status: :unprocessable_entity)
    end

    def render_invalid_priority_error
      render_camelized_json(
        { errors: { priority: ["#{requested_priority} is not a valid priority."] } },
        status: :unprocessable_entity
      )
    end

    def set_import_job
      @import_job = ImportJob.find(params[:id])
    end

    def pagination_data(scope)
      {
        current_page: scope.current_page,
        per_page: scope.limit_value,
        total_pages: scope.total_pages,
        total_count: scope.total_count
      }
    end

    def import_job_list_json(import_job)
      {
        id: import_job.id,
        name: import_job.name,
        priority: import_job.priority,
        status: import_job.status_string,
        created_at: import_job.created_at,
        user: {
          email: import_job.user.email,
          full_name: "#{import_job.user.first_name} #{import_job.user.last_name}".strip
        }
      }
    end

    def import_job_detail_json(import_job)
      {
        id: import_job.id,
        name: import_job.name,
        priority: import_job.priority,
        status: import_job.status_string,
        pending_count: import_job.count_pending_digital_object_imports,
        success_count: import_job.count_successful_digital_object_imports,
        failure_count: import_job.count_failed_digital_object_imports,
        path_to_csv_file: import_job.path_to_csv_file,
        created_at: import_job.created_at,
        updated_at: import_job.updated_at,
        user: {
          email: import_job.user.email,
          full_name: "#{import_job.user.first_name} #{import_job.user.last_name}".strip
        }
      }
    end
end
