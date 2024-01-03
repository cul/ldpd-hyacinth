module Hyacinth::DigitalObjects::UploadsEditorBehavior
  def upload_directory_listing
    directory_path = params[:directory_path] || ''
    errors = []

    # Return a directory listing for the specified directory within mod/assets

    # For safety, don't allow file paths with ".." in them.
    # If we encounter this, change the entire directoryPath to an empty string.
    if directory_path.index("..") =~ /\.\./
      directory_path = ""
      errors << "Paths are not allowed to contain \"..\""
    end

    # Get list of files contained within directory_path
    full_path_to_directory = File.join(HYACINTH[:upload_directory], directory_path)
    entries = Dir.entries(full_path_to_directory)

    directory_data = []
    entries.each do |entry|
      next if entry == '.' || entry == '..'
      entry_to_add = {}
      entry_to_add['name'] = entry
      entry_to_add['isDirectory'] = File.directory?(File.join(full_path_to_directory, entry))
      entry_to_add['path'] = directory_path + '/' + entry
      directory_data << entry_to_add
    end

    response = {}
    response["errors"] = errors if errors.present?
    response["directoryData"] = directory_data

    render json: response
  end
end
