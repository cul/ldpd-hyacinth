class ImportJobsController < ApplicationController
  
  before_action :set_contextual_nav_options

  # fcd1, 10/19/15: TODO: implement access control:
  # admin type user can see all ImportJobs
  # for non-admin type user, only show ImportJobs belonging to user
  def index

    @import_jobs = ImportJob.all

  end

  def show

    @import_job = ImportJob.find(params[:id])
    @count_pending = @import_job.count_pending_digital_object_imports
    @count_success = @import_job.count_successful_digital_object_imports
    @count_failure = @import_job.count_failed_digital_object_imports
    @count_total = @count_pending + @count_success + @count_failure

  end
  
  private
  
  def set_contextual_nav_options

    if params[:action] == 'index'
      @contextual_nav_options['nav_title']['label'] =  'Import Jobs'.html_safe
    else
      @contextual_nav_options['nav_title']['label'] =  '&laquo; Back to Import Jobs'.html_safe
      @contextual_nav_options['nav_title']['url'] = import_jobs_path
    end

  end

end
