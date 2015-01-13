module Hyacinth::DigitalObjectsController::FileServeBehavior
  extend ActiveSupport::Concern

  VALID_IMAGE_DERIVATIVE_SIZES = {'thumb'=>200, 'medium'=>850,'large'=>1500, 'original' => ''}
  DERIVATIVE_TYPE = 'PNG'
  IMAGE_DERIVATIVE_CONTENT_TYPE = 'image/png'
  DERIVATIVE_TYPE_EXTENSION = 'png'
  PATH_TO_GENERIC_FILE_THUMBNAIL_IMAGE = File.join(Rails.root, 'app/assets/images/generic-file-thumb.jpg')

  def get

    # Handle params
    size = params[:size]
    download = params[:download] == 'true' || false
    if size.blank?
      raise 'Size must be specified.  One of: ' + VALID_IMAGE_DERIVATIVE_SIZES.keys.join(', ')
    end
    unless VALID_IMAGE_DERIVATIVE_SIZES.include?(size)
      raise 'Invalid size specified: ' + size + '.  Must be one of: ' + VALID_IMAGE_DERIVATIVE_SIZES.keys.join(', ')
    end

    if size == 'original' && ! download
      raise 'The original file cannot be served as a derivative -- only as a download.'
    end

    # Get relevant object
    digital_object = DigitalObject.where(:pid => params[:pid]).first
    if digital_object.digital_object_type != DigitalObjectType.get_type_asset
      raise 'Only DigitalObjects of type Asset have associated files.  This object is of type: ' + digital_object.digital_object_type.display_label
    end

    # Check permissions
    unless current_user.has_project_permission?(digital_object.project, :read)
      raise 'Read access denied for Digital Object: ' + digital_object.pid
    end

    # Get the full path to the file that we want to serve up
    full_path_to_file = nil

    # Return derivative
    result = digital_object.get_dynamic_attribute_property_values('content_type', 'content_type')
    if result.length > 0
      content_type = result[0]
    else
      raise 'Error: Could not get content_type for Digital Object of type Asset with PID: ' + digital_object.pid
    end

    if content_type.start_with?('image')
      if size == 'original'
        full_path_to_file = digital_object.get_full_path_to_file
      else
        namespace = PidGenerator.get_namespace_from_pid(digital_object.pid)
        pid_without_namespace = PidGenerator.get_pid_without_namespace(digital_object.pid)

        path_to_derivative_file = File.join(HYACINTH_CONFIG['full_path_to_asset_derivative_home'], size, digital_object.project.string_key, namespace, pid_without_namespace[0], pid_without_namespace[1], pid_without_namespace[2], pid_without_namespace + '.' + DERIVATIVE_TYPE_EXTENSION)

        unless File.exists?(path_to_derivative_file)
          # We need to create the derivative file at path_to_derivative_file
          original_file_path = digital_object.get_full_path_to_file
          selected_pixel_size = VALID_IMAGE_DERIVATIVE_SIZES[size]

          # Create digital asset derivative home if it doesn't exist
          derivative_file_basedir = File.dirname(path_to_derivative_file)
          unless File.exists?(derivative_file_basedir)
            FileUtils.mkdir_p(derivative_file_basedir)
          end

          derivative_start_time = Time.now

          ImageScience.with_image(original_file_path) do |img|
            img.thumbnail(selected_pixel_size) do |derivative|
              derivative.save(path_to_derivative_file)
            end
          end

          ## If latest_derivative_cache_directory_path is not found,
          ## delete all old cache directories within the derivative home directory and then create the new cache directory
          #unless File.exists?(latest_derivative_cache_directory_path)
          #
          #  # To be safe, since we're doing an `rm -rf` equivalent, we're only recursively deleting directories that start with 'derivatives_'
          #  Dir.entries(HYACINTH_CONFIG['full_path_to_asset_derivative_home']).each {|entry|
          #    if entry.start_with?('derivatives_')
          #      FileUtils.rm_rf File.join(HYACINTH_CONFIG['full_path_to_asset_derivative_home'], entry)
          #    end
          #  }
          #
          #  # And then create the latest derivative directory
          #  FileUtils.mkdir_p(latest_derivative_cache_directory_path)
          #end

          puts "Created [#{size}] derivative for [#{digital_object.pid}] in #{(Time.now-derivative_start_time).to_s} seconds."
        end

        full_path_to_file = path_to_derivative_file
      end

    else
      full_path_to_file = PATH_TO_GENERIC_FILE_THUMBNAIL_IMAGE
    end

    # Serve the file inline, or as a download
    if full_path_to_file.present?
      if download
        send_file full_path_to_file
      else
        render :text => open(full_path_to_file, "rb").read, :content_type => IMAGE_DERIVATIVE_CONTENT_TYPE # For now, all derivatives are PNGs so that we can support transparency
      end
    end

  end

end
