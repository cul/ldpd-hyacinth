class DigitalObjectImportsController < ApplicationController

  # fcd1, 10/19/15: TODO: implement access control:
  # only admin type user can see all DigitalObjectImports
  def index
    
    # params[:import_job_id] will be set if coming in via an import_job, i.e.
    # path helper: import_job_digital_object_imports_path
    if params.has_key? :import_job_id

      # only want to show associated DigitalObjectImports
      @import_job = ImportJob.find params[:import_job_id]
      @digital_object_imports = @import_job.digital_object_imports.all
      @sub_header = 'for ' + @import_job.name

    else

      # coming in directly, i.e.
      # path helper: digital_object_imports_path
      # show all DigitalObjectImports

      # TODO: access control, only admins should see 
      # all DigitalObjectImports
      @digital_object_imports = DigitalObjectImport.all
      @sub_header = 'for all import jobs'

    end

  end

  def show

    # two possible helper paths to get here:
    # first path:
    # import_job_digital_object_import_path
    # which means we came from a listing of DigitalObjectImports for a particular ImportJob
    # In this case, params[:import_job_id] is set
    # second path:
    # digital_object_import
    # which means we came from the listing of all DigitalObjectImports
    # 
    # Associated view will be slightly different depending on which path was used
    
    @import_job = ImportJob.find params[:import_job_id] if params.has_key? :import_job_id
    @digital_object_import = DigitalObjectImport.find(params[:id])

  end

end
