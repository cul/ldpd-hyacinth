class ImportJobsController < ApplicationController
  before_action :set_import_job, only: [:show, :download_original_csv, :download_csv_without_successful_rows, :destroy]
  before_action :set_contextual_nav_options

  # GET /import_jobs
  def index
    page = params[:page]
    per_page = 20

    if current_user.admin?
      @import_jobs = ImportJob.all.order(id: :desc).page(page).per(per_page)
    else
      @import_jobs = ImportJob.where(user: current_user).order(id: :desc).page(page).per(per_page)
    end
  end

  # GET /import_jobs/1
  def show
    @count_pending = @import_job.count_pending_digital_object_imports
    @count_success = @import_job.count_successful_digital_object_imports
    @count_failure = @import_job.count_failed_digital_object_imports
    @count_total = @count_pending + @count_success + @count_failure
  end

  def new
  end

  def import_job_for_params(params)
    if params[:import_file]
      import_file = params[:import_file]
      priority = params.fetch(:priority, 'low')
      priority_as_queue_name = 'DIGITAL_OBJECT_IMPORT_' + priority.upcase
      if priority.blank? || ! Hyacinth::Queue.const_defined?(priority_as_queue_name)
        import_job = ImportJob.new
        import_job.errors.add(:priority, "#{priority} is not a valid priority.")
      elsif params[:submit] == 'validate'
        import_job = ImportJob.new
        Hyacinth::Utils::CsvImportExportUtils.validate_import_job_csv_data(import_file.read, current_user, import_job)
      else
        import_job = Hyacinth::Utils::CsvImportExportUtils.create_import_job_from_csv_data(import_file.read, import_file.original_filename, current_user, priority.to_sym)
      end
    else
      import_job = ImportJob.new
      import_job.errors.add(:file, 'is required.')
    end
    import_job
  end

  # POST /import_jobs
  def create
    @import_job = import_job_for_params(params)
    if @import_job.errors.any?
      render action: 'new'
    else
      if params[:submit] == 'validate'
        flash[:notice] = 'The submitted CSV file appears to be valid.' if @import_job.errors.blank?
        render action: 'new'
      else
        redirect_to import_job_path(@import_job)
      end
    end
  end

  def destroy
    @import_job.destroy
    redirect_to import_jobs_path
  end

  def download_original_csv
    if @import_job.path_to_csv_file.present?
      send_file @import_job.path_to_csv_file, filename: File.basename(@import_job.name)
    else
      render plain: 'No CSV file available for this import job.'
    end
  end

  def download_csv_without_successful_rows
    if @import_job.path_to_csv_file.present?
      # Get list of successfully imported rows for this import job
      # We're using a Set rather than an array for fast lookup time
      csv_rows_to_collect = @import_job.csv_row_numbers_for_all_non_successful_digital_object_imports.to_set

      csv_data_string = ''
      csv_row_counter = 1

      found_header_row = false
      CSV.foreach(@import_job.path_to_csv_file) do |row|
        if !found_header_row
          csv_data_string += CSV.generate_line row
          found_header_row = true if row[0].start_with?('_')
        elsif csv_rows_to_collect.include?(csv_row_counter)
          csv_data_string += CSV.generate_line row
        end

        csv_row_counter += 1
      end

      send_data(csv_data_string, type: 'text/csv', filename: 'without-successful-rows-' + File.basename(@import_job.name))
    else
      render plain: 'No CSV file available for this import job.'
    end
  end

  private

    def set_import_job
      @import_job = ImportJob.find(params[:id])
    end

    def set_contextual_nav_options
      if params[:action] == 'index'
        @contextual_nav_options['nav_title']['label'] = 'Import Jobs'.html_safe
        @contextual_nav_options['nav_items'].push(label: 'New Import Job', url: new_import_job_path)
      else
        @contextual_nav_options['nav_title']['label'] =  '&laquo; Back to Import Jobs'.html_safe
        @contextual_nav_options['nav_title']['url'] = import_jobs_path
      end
    end
end
