class Api::V2::ImportJobsController < Api::V2::BaseController
  before_action :set_import_job, only: [:show, :download_original_csv, :download_csv_without_successful_rows, :destroy]

  # GET /import_jobs
  def index
    authorize! :index, ImportJob
    per_page = 20

    # CanCanCan already filters the import jobs based on the current user's permissions
    @import_jobs = ImportJob.accessible_by(current_ability)
      .includes(:user)
      .order(id: :desc)
      .page(params[:page])
      .per(per_page)

    render_camelized_json({
      import_jobs: @import_jobs.map { |import_job| import_job_summary_json(import_job) },
      pagination: pagination_data(@import_jobs)
    })
  end

  # POST /api/v2/import_jobs
  def create
    return render_missing_file_error if uploaded_csv_file.blank?
    return render_invalid_priority_error unless valid_priority?

    args = [
      uploaded_csv_file.read,
      uploaded_csv_file.original_filename,
      current_user,
      requested_priority.to_sym
    ]
    args << true if params[:restore_archived_s3_objects_for_new_assets] == 'true'

    @import_job = Hyacinth::Utils::CsvImportExportUtils.create_import_job_from_csv_data(*args)

    if @import_job.errors.any?
      render_camelized_json({ errors: format_errors(@import_job.errors) }, status: :unprocessable_entity)
    else
      render_camelized_json({ import_job: import_job_summary_json(@import_job) }, status: :created)
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
    authorize! :show, @import_job
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

  # GET /api/v2/import_jobs/:id/download_original_csv
  def download_original_csv
    authorize! :show, @import_job

    if @import_job.path_to_csv_file.present?
      send_file @import_job.path_to_csv_file, filename: File.basename(@import_job.name)
    else
      render_camelized_json({ errors: { file: ['No CSV file available for this import job.'] } }, status: :not_found)
    end
  end

  # GET /api/v2/import_jobs/:id/download_csv_without_successful_rows
  def download_csv_without_successful_rows
    authorize! :show, @import_job

    return render_camelized_json(
      { errors: { file: ['No CSV file available for this import job.'] } },
      status: :not_found
    ) if @import_job.path_to_csv_file.blank?

    csv_rows_to_collect = @import_job.csv_row_numbers_for_all_non_successful_digital_object_imports.to_set
    csv_data_string = ''
    csv_row_counter = 1
    found_header_row = false

    CSV.foreach(@import_job.path_to_csv_file) do |row|
      if !found_header_row
        csv_data_string << CSV.generate_line(row)
        found_header_row = true if row[0].start_with?('_')
      elsif csv_rows_to_collect.include?(csv_row_counter)
        csv_data_string << CSV.generate_line(row)
      end

      csv_row_counter += 1
    end

    send_data(csv_data_string, type: 'text/csv', filename: "without-successful-rows-#{File.basename(@import_job.name)}")
  end

  # DELETE /api/v2/import_jobs/:id
  def destroy
    authorize! :destroy, @import_job
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

    def import_job_summary_json(import_job)
      {
        id: import_job.id,
        name: import_job.name,
        priority: import_job.priority,
        status: import_job.status_string,
        complete: import_job.complete?,
        created_at: import_job.created_at,
        user: {
          uid: import_job.user.uid,
          email: import_job.user.email,
          full_name: import_job.user.full_name
        }
      }
    end

    def import_job_detail_json(import_job)
      {
        id: import_job.id,
        name: import_job.name,
        priority: import_job.priority,
        restore_archived_s3_objects_for_new_assets: import_job.restore_archived_s3_objects_for_new_assets,
        status: import_job.status_string,
        pending_count: import_job.count_pending_digital_object_imports,
        success_count: import_job.count_successful_digital_object_imports,
        failure_count: import_job.count_failed_digital_object_imports,
        path_to_csv_file: import_job.path_to_csv_file,
        created_at: import_job.created_at,
        updated_at: import_job.updated_at,
        user: {
          uid: import_job.user.uid,
          email: import_job.user.email,
          full_name: import_job.user.full_name
        }
      }
    end
end
