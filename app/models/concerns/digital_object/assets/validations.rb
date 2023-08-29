module DigitalObject::Assets::Validations
  extend ActiveSupport::Concern

  def validate
    super # Always run shared parent class validation

    # New Assets must have certain import variables set
    return @errors.blank? unless self.new_record? && pid.nil?

    validate_new_import_file_path

    validate_new_import_file_type
    # Update: Assets can be parts of filesystem objects too. Disabling this
    # check for now, but we'll get back to this later.
    ## Assets can only be children of DigitalObject::Item objects
    # parent_digital_object_pids.each {|parent_digital_object_pid|
    #  parent_digital_object = DigitalObject::Base.find(parent_digital_object_pid)
    #  unless parent_digital_object.is_a?(DigitalObject::Item)
    #    @errors.add(:parent_digital_object_pids, 'Assets are only allowed to be children of Items.  Found parent of type: ' + parent_digital_object.digital_object_type.display_label)
    #  end
    # }
    validate_featured_region
    @errors.blank?
  end

  def validate_new_import_file_path
    if @import_file_import_path.blank?
      @errors.add(:import_file_import_path, 'New Assets must have @import_file_import_path set.')
    else
      # If file import path is present for this new Asset, make sure that there isn't already another Asset that is also pointing to the same file
      pid = Hyacinth::Utils::FedoraUtils.find_object_pid_by_filesystem_path(@import_file_import_path)
      @errors.add(:import_file_import_path, "Found existing Asset (#{pid}) with file path: #{@import_file_import_path}") if pid.present?
    end
  end

  def validate_new_import_file_type
    @errors.add(:import_file_import_type, 'New Assets must have @import_file_import_type set.') if @import_file_import_type.blank?

    raise "Invalid @import_file_import_type: #{@import_file_import_type.inspect}" unless DigitalObject::Asset::VALID_FILE_IMPORT_TYPES.include?(@import_file_import_type)
  end

  def validate_full_file_path(actual_path_to_validate)
    raise "No file found at path: #{actual_path_to_validate}" unless File.exist?(actual_path_to_validate)

    raise "File exists, but is not readable due to a permissions issue: #{actual_path_to_validate}" unless File.readable?(actual_path_to_validate)
  end

  def admin_required_for_type?(import_file_import_type)
    return false if DigitalObject::Asset::IMPORT_TYPE_UPLOAD_DIRECTORY == import_file_import_type
    return false if DigitalObject::Asset::IMPORT_TYPE_POST_DATA == import_file_import_type
    true
  end

  def validate_import_file_type(import_file_import_type)
    raise "Missing type for import_file: digital_object_data['import_file']['import_type']" if import_file_import_type.blank?

    raise "Invalid type for import_file: digital_object_data['import_file']['import_type']: #{import_file_import_type.inspect}" unless DigitalObject::Asset::VALID_FILE_IMPORT_TYPES.include?(import_file_import_type)

    return if import_file_import_type == DigitalObject::Asset::IMPORT_TYPE_UPLOAD_DIRECTORY
  end

  def validate_import_file_data(import_file_data)
    return unless import_file_data.present?

    import_file_import_type = import_file_data['import_type']
    validate_import_file_type(import_file_import_type)

    import_file_import_path = import_file_data['import_path']
    raise "Missing path for import_file: digital_object_data['import_file']['import_path']" if import_file_import_path.blank?

    # Make sure that the file exists and is readable
    if import_file_import_type == DigitalObject::Asset::IMPORT_TYPE_UPLOAD_DIRECTORY
      actual_path_to_validate = File.join(HYACINTH['upload_directory'], import_file_import_path)
    else
      actual_path_to_validate = import_file_import_path
    end

    validate_full_file_path(actual_path_to_validate)

    # Also validate presence of access file, if given
    if import_file_data['access_copy_import_path'].present?
      access_copy_import_path = import_file_data['access_copy_import_path']
      validate_full_file_path(access_copy_import_path)
      raise "Invalid UTF-8 characters found in access copy file path.  Unable to upload." if access_copy_import_path != Hyacinth::Utils::StringUtils.clean_utf8_string(access_copy_import_path)
    end

    # Also validate presence of service file, if given
    if import_file_data['service_copy_import_path'].present?
      service_copy_import_path = import_file_data['service_copy_import_path']
      validate_full_file_path(service_copy_import_path)
      raise "Invalid UTF-8 characters found in service copy file path.  Unable to upload." if service_copy_import_path != Hyacinth::Utils::StringUtils.clean_utf8_string(service_copy_import_path)
    end

    # Check for invalid characters in import path.  Reject if non-utf8.
    # If we get weird characters (like "\xC2"), Ruby will die a horrible death.  Let's keep Ruby alive.
    raise "Invalid UTF-8 characters found in file path.  Unable to upload." if import_file_import_path != Hyacinth::Utils::StringUtils.clean_utf8_string(import_file_import_path)
  end

  def validate_featured_region
    value_to_validate = featured_region
    return if value_to_validate.blank?

    unless pid.blank?
      dims_oriented = (fedora_object.orientation / 10).even?
      original_image_width = dims_oriented ? asset_image_width : asset_image_height
      original_image_height = dims_oriented ? asset_image_height : asset_image_width
    end
    unless original_image_width && original_image_height
      @errors.add(:featured_region, "Original asset has not yet been analyzed; cannot reassign featured region")
      return
    end

    left, top, width, height = value_to_validate.to_s.split(',').map(&:to_i)
    unless (top >= 0) &&(left >= 0) && (width >= 768) && (width == height)
      @errors.add(:featured_region, "region must describe a square within image of at least 768px side (given region '#{value_to_validate}')")
    end

    unless (original_image_width >= left + width) && (original_image_height >= top + height)
      @errors.add(:featured_region, "region #{value_to_validate} is not within original image dimensions #{original_image_width}x#{original_image_height}")
    end
  end
end
