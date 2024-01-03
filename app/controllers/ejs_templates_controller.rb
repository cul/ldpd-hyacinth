class EjsTemplatesController < ApplicationController
  def get
    path_to_template_file = params[:path_to_template_file]
    full_path_to_file = File.join(Rails.root, 'app/assets/templates', path_to_template_file)
    if full_path_to_file.end_with?('.ejs') && File.exist?(full_path_to_file)
      send_file full_path_to_file, type: 'text/plain', disposition: 'inline'
    else
      render plain: 'EJS template not found: ' + path_to_template_file, status: :not_found
    end
  end
end
