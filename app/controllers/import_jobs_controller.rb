class ImportJobsController < ApplicationController
  
  before_action :set_contextual_nav_options

  # fcd1, 10/19/15: TODO: implement access control:
  # admin type user can see all ImportJobs
  # for non-admin type user, only show ImportJobs belonging to user
  # GET /import_jobs
  def index

    @import_jobs = ImportJob.all

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

    @project = Project.find(params[:project_id]) if params[:project_id]
    @import_job = ImportJob.new(name: @import_filename, user: current_user)
    @array_of_digital_object_data = Array.new

    begin
      Hyacinth::Utils::CsvImportExportUtils.csv_to_digital_object_data(import_file.read) do |digital_object_data|
        # Defer import_job save until a valid CSV row is detected
        @import_job.save if @import_job.new_record?

        # if neither the project pid nor project string_key are specified in the import data, insert the project pid
        if missing_project?(digital_object_data)
          digital_object_data['project']['pid'] = default_project
        end

        # encode the data as JSON string for insertion into the database
        digital_object_data_encoded_as_json = ActiveSupport::JSON.encode digital_object_data
        @array_of_digital_object_data.push(digital_object_data_encoded_as_json)
        digital_object_import = DigitalObjectImport.create!(import_job: @import_job,
                                                            digital_object_data: digital_object_data_encoded_as_json)
        #####@import_job.digital_object_imports << digital_object_import
        # queue up digital_object_import for procssing -- entails queueing up the id of the instance
        Hyacinth::Queue.process_digital_object_import(digital_object_import.id)
      end
    rescue CSV::MalformedCSVError
      # Handle invalid CSV
      @import_job.errors.add(:invalid_csv, 'Invalid CSV File')
    end

    redirect_to import_job_path(@import_job) unless @import_job.errors.any?
  end

  private

  def missing_project?(digital_object_data)
    digital_object_data['project']['pid'].blank? &&
    digital_object_data['project']['string_key'].blank?
  end

  def default_project
    @project.pid if @project
  end

  def set_contextual_nav_options

    if params[:action] == 'index'
      @contextual_nav_options['nav_title']['label'] =  'Import Jobs'.html_safe
    else
      @contextual_nav_options['nav_title']['label'] =  '&laquo; Back to Import Jobs'.html_safe
      @contextual_nav_options['nav_title']['url'] = import_jobs_path
    end

  end

end
