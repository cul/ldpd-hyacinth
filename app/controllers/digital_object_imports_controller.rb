class DigitalObjectImportsController < ApplicationController

  def index
    @import_job = ImportJob.find params[:import_job_id]

    @status_filter = params[:status].present? && DigitalObjectImport.statuses.include?(params[:status].to_sym) ? params[:status].to_sym : nil
    page = params[:page]
    per_page = 50

    if @status_filter.present?
      @digital_object_imports = @import_job.digital_object_imports.where(status: DigitalObjectImport.statuses[@status_filter]).page(page).per(per_page)
    else
      @digital_object_imports = @import_job.digital_object_imports.page(page).per(per_page)
    end
  end

  def show
    @import_job = ImportJob.find params[:import_job_id] if params.has_key? :import_job_id
    @digital_object_import = DigitalObjectImport.find(params[:id])
  end

end
