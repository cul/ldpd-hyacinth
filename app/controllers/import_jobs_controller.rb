class ImportJobsController < ApplicationController
  
  before_action :set_import_job, only: [:show, :download_original_csv, :download_csv_without_successful_rows, :destroy]
  before_action :set_contextual_nav_options

  # GET /import_jobs
  def index    
    if current_user.is_admin?
      @import_jobs = ImportJob.all # TODO: Add pagination feature using: .page(page).per(per_page)
    else
      @import_jobs = ImportJob.where(user: current_user) # TODO: Add pagination feature using: .page(page).per(per_page)
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

  # POST /import_jobs
  def create
    
    if params[:import_file]
      import_file = params[:import_file]
      if params[:submit] == 'validate'
        @import_job = ImportJob.new
        Hyacinth::Utils::CsvImportExportUtils.validate_import_job_csv_data(import_file.read, current_user, @import_job)
      else
        @import_job = Hyacinth::Utils::CsvImportExportUtils.create_import_job_from_csv_data(import_file.read, import_file.original_filename, current_user)
      end
    else
      @import_job = ImportJob.new
      @import_job.errors.add(:file, 'is required.')
    end
    
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
      render text: 'No CSV file available for this import job.'
    end
  end
  
  def download_csv_without_successful_rows
    if @import_job.path_to_csv_file.present?
      
      # Get list of successfully imported rows for this import job
      # We're using a Set rather than an array for fast lookup time
      csv_rows_to_collect = @import_job.get_csv_row_numbers_for_all_non_successful_digital_object_imports.to_set
      
      csv_data_string = ''
      csv_row_counter = 1
      CSV.foreach(@import_job.path_to_csv_file) do |row|
        if csv_row_counter == 1 || csv_row_counter == 2 || csv_rows_to_collect.include?(csv_row_counter)
          csv_data_string += CSV::generate_line row
        end
        csv_row_counter += 1
      end
      
      send_data(csv_data_string, type: 'text/csv', filename: 'without-successful-rows-' + File.basename(@import_job.name))
    else
      render text: 'No CSV file available for this import job.'
    end
  end

  private
  
  def set_import_job
    @import_job = ImportJob.find(params[:id])
  end

  def set_contextual_nav_options

    if params[:action] == 'index'
      @contextual_nav_options['nav_title']['label'] =  'Import Jobs'.html_safe
      @contextual_nav_options['nav_items'].push(label: 'New Import Job', url: new_import_job_path)
    else
      @contextual_nav_options['nav_title']['label'] =  '&laquo; Back to Import Jobs'.html_safe
      @contextual_nav_options['nav_title']['url'] = import_jobs_path
    end

  end

end
