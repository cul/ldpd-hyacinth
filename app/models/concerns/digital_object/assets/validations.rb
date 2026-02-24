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

        # Make sure that there isn't already another active Asset in Hyacinth with a main file that points to this same file
        import_location_as_uri = import_location.start_with?('/') ? Hyacinth::Utils::UriUtils.file_path_to_location_uri(import_location) : import_location
        possible_asset = DigitalObject::Asset.find_by_resource_location_uri(::DigitalObject::Asset::MAIN_RESOURCE_NAME, import_location_as_uri)
        if possible_asset.present? && possible_asset.state == ::DigitalObject::Base::STATE_ACTIVE
          @errors.add(:import_file, "Found existing active Hyacinth Asset (#{possible_asset.pid}) with main file path: #{possible_asset.location_uri_for_resource(::DigitalObject::Asset::MAIN_RESOURCE_NAME)}")
        end
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
  end
end
