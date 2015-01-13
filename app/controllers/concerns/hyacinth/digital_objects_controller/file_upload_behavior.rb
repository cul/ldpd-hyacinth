module Hyacinth::DigitalObjectsController::FileUploadBehavior
  extend ActiveSupport::Concern

  # GET /digital_objects/1/upload_assets
  # POST /digital_objects/1/upload_assets
  def upload_assets

    if params[:commit]
      success, error_message = @digital_object.create_child_assets_from_file_upload_data(params[:asset_upload])
      if success
        flash[:notice] = 'File upload was successful.'
      else
        flash[:alert] = ('<strong>Upload Error:</strong> ' + error_message).html_safe
      end
    end

  end

end
