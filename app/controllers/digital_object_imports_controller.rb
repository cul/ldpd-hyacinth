class DigitalObjectImportsController < ApplicationController

  def index
    @import_job = ImportJob.find params[:import_job_id] if params.has_key? :import_job_id

    @status_filter = params[:status].present? && DigitalObjectImport.statuses.include?(params[:status].to_sym) ? params[:status].to_sym : nil
    page = params[:page]
    per_page = 50

    if current_user.is_admin?
      @digital_object_imports = @status_filter.present? ? DigitalObjectImport.where(status: DigitalObjectImport.statuses[@status_filter]).page(page).per(per_page) : DigitalObjectImport.all.page(page).per(per_page)
    else
      @digital_object_imports = @status_filter.present? ? DigitalObjectImport.where(user: current_user, status: DigitalObjectImport.statuses[@status_filter]).page(page).per(per_page) : DigitalObjectImport.where(user: current_user).page(page).per(per_page)
    end
  end

  def show
    @import_job = ImportJob.find params[:import_job_id] if params.has_key? :import_job_id
    @digital_object_import = DigitalObjectImport.find(params[:id])
  end

end
