module DigitalObject::Assets::Validations
  extend ActiveSupport::Concern

  def validate
    super # Always run shared parent class validation

    validate_import_file_data_if_present
    validate_featured_region_if_present

    @errors.blank?
  end

  def validate_import_file_data_if_present
    unexpected_import_file_data_keys = @import_file_data.keys - ::DigitalObject::Asset::VALID_FILE_IMPORT_RESOURCE_TYPES
    if unexpected_import_file_data_keys.present?
      @errors.add(:import_file, "Unexpected import_file keys found: #{unexpected_import_file_data_keys.map {|key| "import_file.#{key}"}}")
    end

    # If this is a new record and a pid was not supplied, ensure that a main import file is present
    if self.new_record? && pid.nil? && @import_file_data[::DigitalObject::Asset::MAIN_RESOURCE_NAME].blank?
      @errors.add(:import_file, "A #{::DigitalObject::Asset::MAIN_RESOURCE_NAME} resource is required for new assets.")
    end

    ::DigitalObject::Asset::VALID_FILE_IMPORT_RESOURCE_TYPES.each do |resource_name|
      import_data = @import_file_data[resource_name]
      next if import_data.blank?

      import_location = import_data['import_location']

      if import_location.blank?
        @errors.add(:import_file, "Missing import_file.#{resource_name}.import_location")
      end

      if import_location.index('/..') || import_location.index('../')
        @errors.add(:import_file, "#{resource_name} import path contains relative directory traversal characters: "..".  Please specify an absolute path.")
      end

      if import_location != Hyacinth::Utils::StringUtils.clean_utf8_string(import_location)
        @errors.add(:import_file, "import_file.#{resource_name}.import_location contains invalid UTF-8 characters.")
      end

      if resource_name == ::DigitalObject::Asset::MAIN_RESOURCE_NAME
        # Main file can optionally have an original_file_path
        original_file_path = import_data['import_type']
        if original_file_path.present? && original_file_path != Hyacinth::Utils::StringUtils.clean_utf8_string(original_file_path)
          @errors.add(:import_file, "import_file.#{resource_name}.original_file_path contains invalid UTF-8 characters.")
        end

        # Make sure that there isn't already another Asset with a main file that points to this same file
        pid = Hyacinth::Utils::FedoraUtils.find_object_pid_by_filesystem_path(import_location)
        @errors.add(:import_file, "Found existing Asset (#{pid}) with main file path: #{import_location}") if pid.present?
      end

      if [::DigitalObject::Asset::MAIN_RESOURCE_NAME, ::DigitalObject::Asset::SERVICE_RESOURCE_NAME].include?(resource_name)
        # Main and service copies need to specify an import_type
        import_type = import_data['import_type']
        if import_type.blank?
          @errors.add(:import_file, "Missing import_file.#{resource_name}.import_type")
        elsif !(::DigitalObject::Asset::VALID_FILE_IMPORT_TYPES.include?(import_type))
          @errors.add(:import_file, "Invalid import_file.#{resource_name}.import_type: #{import_type}")
        end
      end
    end
  end

  def validate_featured_region_if_present
    value_to_validate = featured_region
    return if value_to_validate.blank?
    unless value_to_validate =~ /\d+,\d+,\d+,\d+/
      @errors.add(:featured_region, "Invalid featured region format: '#{value_to_validate}')")
    end

    ### Commenting out the validation below because this is no longer a limitation we need to worry about.  The image server handles smaller images properly.

    # left, top, width, height = value_to_validate.to_s.split(',').map(&:to_i)

    # unless (top >= 0) &&(left >= 0) && (width >= 768) && (width == height)
    #   @errors.add(:featured_region, "region must describe a square within image of at least 768px side (given region '#{value_to_validate}')")
    # end

    ### Commenting out the validation below because the featured region isn't always based on the original image dimensions.

    # unless pid.blank?
    #   dims_oriented = (fedora_object.orientation / 10).even?
    #   original_image_width = dims_oriented ? asset_image_width : asset_image_height
    #   original_image_height = dims_oriented ? asset_image_height : asset_image_width
    # end
    # unless original_image_width&.positive? && original_image_height&.positive?
    #   @errors.add(:featured_region, "Original asset has not yet been analyzed; cannot reassign featured region")
    #   return
    # end
    #
    # It can be based on a service copy or poster.
    # unless (original_image_width >= left + width) && (original_image_height >= top + height)
    #   @errors.add(:featured_region, "region #{value_to_validate} is not within original image dimensions #{original_image_width}x#{original_image_height}")
    # end
  end
end
