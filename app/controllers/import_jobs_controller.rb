class ImportJobsController < ApplicationController
  
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

    @import_job = ImportJob.find(params[:id])
    @count_pending = @import_job.count_pending_digital_object_imports
    @count_success = @import_job.count_successful_digital_object_imports
    @count_failure = @import_job.count_failed_digital_object_imports
    @count_total = @count_pending + @count_success + @count_failure

  end

  def new
  end

  # POST /import_jobs
  def create
    import_file = params[:import_file]
    @import_filename = import_file.original_filename
    
    @import_job = Hyacinth::Utils::CsvImportExportUtils.create_import_job_from_csv_data(import_file.read, @import_filename, current_user)
    
    redirect_to import_job_path(@import_job) unless @import_job.errors.any?
  end

  private

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
