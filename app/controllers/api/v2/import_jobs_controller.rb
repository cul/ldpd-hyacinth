class Api::V2::ImportJobsController < Api::V2::BaseController
  before_action :set_import_job, only: [:show]

  # GET /import_jobs
  def index
    page = params[:page]
    per_page = 20

    # @import_job_queue_counts = [:low, :medium, :high].map do |priority|
    #   [
    #     priority,
    #     DigitalObjectImport.joins(:import_job).where(status: :pending, import_jobs: { priority: priority }).count
    #   ]
    # end.to_h

    if current_user.admin?
      puts "Admin user"
      res = ImportJob.all.order(id: :desc).page(page).per(per_page)
      puts res.inspect
      @import_jobs = ImportJob.all.order(id: :desc).page(page).per(per_page)
      render_camelized_json({ import_jobs: @import_jobs.map do |import_job|
        import_job.user = User.find(import_job.user_id)
        puts "Import job user: #{import_job.user.inspect}"
        import_job_json(import_job)
      end })
    else
      @import_jobs = ImportJob.where(user: current_user).order(id: :desc).page(page).per(per_page)
      render_camelized_json({ import_jobs: @import_jobs.map { |import_job| import_job_json(import_job) } })
    end
  end

  # POST /api/v2/import_jobs
  def create 
    # TODO: Validate params
    puts "In import jobs controller"
    @import_job = build_import_job_from_upload
 
    if @import_job.errors.any?
      render_camelized_json({ errors: format_errors(@import_job.errors) }, status: :unprocessable_entity)
    elsif validate_only?
      render_camelized_json({ valid: true, message: 'The submitted CSV file appears to be valid.' })
    else
      render_camelized_json({ import_job: import_job_json(@import_job) }, status: :created)
    end
  end

  def show
    # authorize! :show, @import_job
    render_camelized_json({ import_job: import_job_json(@import_job) })
  end

  private
 
    def build_import_job_from_upload
      puts "Params:"
      puts params
      requested_priority = params.dig(:import_job, :priority) || 'low'

      # ? This mimics the logic from the old controller but is a bit weird since we create an ImportJob
      # just to store validation errors but no job is actually created until CsvImportExportUtils.create_import_job_from_csv_data is called.
      return import_job_with_error(:file, 'is required.') if params[:import_file].blank?
      return import_job_with_error(:priority, "#{requested_priority} is not a valid priority.") unless valid_priority?(requested_priority)
 
       validate_only? ? validate_uploaded_csv : import_uploaded_csv
    end

    # Validates the uploaded CSV without queueing an import
    def validate_uploaded_csv
      import_job = ImportJob.new
      Hyacinth::Utils::CsvImportExportUtils.validate_import_job_csv_data(
        uploaded_csv_file.read, current_user, import_job
      )
      import_job
    end

    def import_uploaded_csv
      Hyacinth::Utils::CsvImportExportUtils.create_import_job_from_csv_data(
        uploaded_csv_file.read,
        uploaded_csv_file.original_filename,
        current_user,
        requested_priority.to_sym
      )
    end

    def uploaded_csv_file
      params[:import_file]
    end

    def validate_only?
      params[:submit] == 'validate'
    end

    def valid_priority?(requested_priority)
      requested_priority.present? && Hyacinth::Queue.const_defined?("DIGITAL_OBJECT_IMPORT_#{requested_priority.upcase}")
    end

    def import_job_with_error(attribute, message)
      import_job = ImportJob.new
      import_job.errors.add(attribute, message)
      import_job
    end

    def requested_priority
      params.fetch(:priority, 'low')
    end

    def set_import_job
      puts "Params:"
      puts params
      @import_job = ImportJob.find(params[:id])
    end

    def import_job_json(import_job)
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
        updated_at: import_job.updated_at
      }
    end
end
