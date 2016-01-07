require 'addressable/uri'

class DigitalObject::Asset < DigitalObject::Base

  VALID_DC_TYPES = ['Unknown', 'Dataset', 'MovingImage', 'Software', 'Sound', 'StillImage', 'Text']
  DIGITAL_OBJECT_TYPE_STRING_KEY = 'asset'
  
  DEFAULT_ASSET_NAME = 'Asset' # For when a title is not supplied and we're not doing with a filesystem upload
  
  IMPORT_TYPE_INTERNAL = 'internal'
  IMPORT_TYPE_EXTERNAL = 'external'
  IMPORT_TYPE_POST_DATA = 'post_data'
  IMPORT_TYPE_UPLOAD_DIRECTORY = 'upload_directory'
  VALID_FILE_IMPORT_TYPES = [IMPORT_TYPE_INTERNAL, IMPORT_TYPE_EXTERNAL, IMPORT_TYPE_POST_DATA, IMPORT_TYPE_UPLOAD_DIRECTORY]

  def initialize
    super
    
    @import_file_import_type = nil
    @import_file_import_path = nil
    @import_file_original_file_path = nil

    # Default to 'Unknown' dc_type.  We expect other code to properly set this
    # once the asset file type is known, but this avoid a blank value for dc_type
    # and helps to identify errors when a dc_type has been improperly set.
    self.dc_type ||= VALID_DC_TYPES.first
  end

  # Called during save, after all validations have passed
  def get_new_fedora_object

    pid = self.next_pid
    generic_resource = GenericResource.new(:pid => pid)

    return generic_resource
  end
  
  def run_post_validation_pre_save_logic
    super

    # If @import_file_data is set, then we want to import a file as part of our save operation
    self.do_file_import if self.new_record?
  end
  
  # Returns true if file import was successful, false otherwise
  def do_file_import
    
    path_to_final_save_location = nil
    import_file_sha256 = Digest::SHA256.new
    import_file_sha256_hexdigest = nil
    import_file_size = nil
    
    # If this is an upload directory import, we'll adjust the import file path
    # and pretend that it's actually an internal file import
    if @import_file_import_type == IMPORT_TYPE_UPLOAD_DIRECTORY
      @import_file_import_path = File.join(HYACINTH['upload_directory'], @import_file_import_path)
      @import_file_import_type = IMPORT_TYPE_INTERNAL
    end
    
    # Generate checksum using 4096-byte buffered approach (to keep memory usage low for large files)
    # If this is an internal file, also copy the file to its internal destination
    File.open(@import_file_import_path, 'rb') do |import_file| # 'r' == write, 'b' == binary mode
      
      import_file_size = import_file.size
      
      if @import_file_import_type == IMPORT_TYPE_INTERNAL || @import_file_import_type == IMPORT_TYPE_POST_DATA
        path_to_final_save_location = Hyacinth::Utils::PathUtils.path_to_asset_file(self.pid, self.project, File.basename(@import_file_import_path))
        
        if File.exists?(path_to_final_save_location)
          raise 'Could not upload new internally-stored file because existing file was already found at target location: ' + path_to_final_save_location
        end
        
        # Recursively make necessary directories
        FileUtils.mkdir_p(File.dirname(path_to_final_save_location))
        
        # Test write abilities by touching the target file
        FileUtils.touch(path_to_final_save_location)
        unless File.exists?(path_to_final_save_location)
          raise 'Unable to write to file path: ' + path_to_final_save_location
        end
        
        # Copy file to target path_to_final_save_location while generating checksum of original
        File.open(path_to_final_save_location, 'wb') do |new_file| # 'w' == write, 'b' == binary mode
          while buff = import_file.read(4096)
            import_file_sha256.update(buff)
            new_file.write(buff)
          end
        end
        import_file_sha256_hexdigest = import_file_sha256.hexdigest
        
        # Confirm that checksum of newly written file matches original checksum.  Delete new file and raise error if it doesn't.
        copied_file_sha256 = Digest::SHA256.new
        File.open(path_to_final_save_location, 'rb') do |copied_file| # 'r' == write, 'b' == binary mode
          while buff = copied_file.read(4096)
            copied_file_sha256.update(buff)
          end
        end
        copied_file_sha256_hexdigest = copied_file_sha256.hexdigest
        
        if copied_file_sha256_hexdigest != import_file_sha256_hexdigest
          FileUtils.rm(path_to_final_save_location) # Important to delete new file
          raise "Error during file copy.  Copied file checksum (#{copied_file_sha256_hexdigest}) didn't match import file (#{import_file_sha256_hexdigest}).  Try file import again."
        end
        
      elsif @import_file_import_type == IMPORT_TYPE_EXTERNAL
        # Generate checksum for file
        while buff = import_file.read(4096)
          import_file_sha256.update(buff)
        end
        
        # Set path_to_final_save_location as original file path
        path_to_final_save_location = @import_file_import_path
        import_file_sha256_hexdigest = import_file_sha256.hexdigest
      else
        raise 'Did not expect @import_file_import_type: ' + @import_file_import_type.inspect
      end
    end
    
    # At this point, there is a file at path_to_final_save_location and
    # import_file_sha256_hexdigest has been calculated, and
    # import_file_size has been set, regardless of import type.
    
    original_filename = File.basename(@import_file_original_file_path || @import_file_import_path)
    
    # If the title of this Asset is the DEFAULT_ASSET_NAME, use the original filename as the title.
    # If the title of this Asset is NOT equal to DEFAULT_ASSET_NAME, that means that a title was
    # manually set by the user in this Asset's digital_object_data.
    if self.get_title == DEFAULT_ASSET_NAME
      self.set_title('', original_filename)
    end
    
    # Create datastream for file
    
    # "controlGroup => 'E'" below means "External Referenced Content" -- as in, a file that's referenced by Fedora but not stored in Fedora's internal data store
    ds_location = Addressable::URI.encode('file:' + path_to_final_save_location) # Note: This will result in paths like "file:/something%20great/here.txt"  We DO NOT want a double slash at the beginnings of these paths.
    content_ds = @fedora_object.create_datastream(ActiveFedora::Datastream, 'content', :controlGroup => 'E', :mimeType => DigitalObject::Asset.filename_to_mime_type(original_filename), :dsLabel => original_filename, :versionable => true)
    content_ds.dsLocation = ds_location
    @fedora_object.datastreams["DC"].dc_source = ds_location
    content_ds.checksum = import_file_sha256_hexdigest
    content_ds.checksumType = 'SHA-256'
    @fedora_object.add_datastream(content_ds)

    # Add size property to content datastream using :extent predicate
    @fedora_object.rels_int.add_relationship(content_ds, :extent, import_file_size.to_s, true) # last param *true* means that this is a literal value rather than a relationship

    # Add original filename property to content datastream using <info:fedora/fedora-system:def/model#downloadFilename> relationship
    @fedora_object.rels_int.add_relationship(content_ds, 'info:fedora/fedora-system:def/model#downloadFilename', original_filename, true) # last param *true* means that this is a literal value rather than a relationship

    # Assume top-left orientation at upload time. This can be corrected later in the app.
    @fedora_object.rels_int.add_relationship(content_ds, :orientation, 'top-left', true) # last param *true* means that this is a literal value rather than a relationship

    set_original_file_path(@import_file_original_file_path || @import_file_import_path) # This also updates the 'content' datastream label
  end

  def validate
    super # Always run shared parent class validation
    
    # New Assets must have certain import variables set
    if self.new_record?
      if @import_file_import_path.blank?
        @errors.add(:import_file_import_path, 'New Assets must have @import_file_import_path set.')
      end
      
      if @import_file_import_type.blank?
        @errors.add(:import_file_import_type, 'New Assets must have @import_file_import_type set.')
      end
      
      unless DigitalObject::Asset::VALID_FILE_IMPORT_TYPES.include?(@import_file_import_type)
        raise "Invalid @import_file_import_type: " + @import_file_import_type.inspect
      end
    end
    
    # Update: Assets can be parts of filesystem objects too. Disabling this
    # check for now, but we'll get back to this later.
    ## Assets can only be children of DigitalObject::Item objects
    #parent_digital_object_pids.each {|parent_digital_object_pid|
    #  parent_digital_object = DigitalObject::Base.find(parent_digital_object_pid)
    #  unless parent_digital_object.is_a?(DigitalObject::Item)
    #    @errors.add(:parent_digital_object_pids, 'Assets are only allowed to be children of Items.  Found parent of type: ' + parent_digital_object.digital_object_type.display_label)
    #  end
    #}

    return @errors.blank?
  end

  #def set_file_and_file_size_and_original_file_path_and_calculate_checksum(path_to_file, original_file_path, file_size)
  #
  #  # "controlGroup => 'E'" below means "External Referenced Content" -- as in, a file that's referenced by Fedora but not stored internally
  #  ds_location = Addressable::URI.encode('file:' + path_to_file) # Note: This will result in paths like "file:/something%20great/here.txt"  We DO NOT want a double slash at the beginnings of these paths.
  #  original_filename = File.basename(path_to_file)
  #  content_ds = @fedora_object.create_datastream(ActiveFedora::Datastream, 'content', :controlGroup => 'E', :mimeType => DigitalObject::Asset.filename_to_mime_type(original_filename), :dsLabel => original_filename, :versionable => true)
  #  content_ds.dsLocation = ds_location
  #  @fedora_object.datastreams["DC"].dc_source = ds_location
  #
  #  # Calculate checksum for file, using 4096-byte buffered approach to save memory for large files
  #  sha256 = Digest::SHA256.new
  #  File.open(path_to_file, 'r') do |file|
  #    while buff = file.read(4096)
  #      sha256.update(buff)
  #    end
  #  end
  #
  #  content_ds.checksum = sha256.hexdigest
  #  content_ds.checksumType = 'SHA-256'
  #
  #  @fedora_object.add_datastream(content_ds)
  #
  #  # Add size property to content datastream using :extent predicate
  #  @fedora_object.rels_int.add_relationship(content_ds, :extent, file_size.to_s, true) # last param *true* means that this is a literal value rather than a relationship
  #
  #  # Add original_filename property to content datastream using <info:fedora/fedora-system:def/model#downloadFilename> relationship
  #  @fedora_object.rels_int.add_relationship(content_ds, 'info:fedora/fedora-system:def/model#downloadFilename', original_filename, true) # last param *true* means that this is a literal value rather than a relationship
  #
  #  # Assume top-left orientation at upload time. This can be corrected later in the app.
  #  @fedora_object.rels_int.add_relationship(content_ds, :orientation, 'top-left', true) # last param *true* means that this is a literal value rather than a relationship
  #
  #  set_original_file_path(original_file_path) # This also updates the 'content' datastream label
  #
  #end

  def get_filesystem_location
    content_ds = @fedora_object.datastreams['content']
    if content_ds.present?
      Addressable::URI.unencode(content_ds.dsLocation).gsub(/^file:/,'')
    else
      return nil
    end
  end

  def get_checksum
    content_ds = @fedora_object.datastreams['content']
    if content_ds.present?
      checksum = ''
      checksum += content_ds.checksumType + ':' if content_ds.checksumType
      checksum += content_ds.checksum if content_ds.checksum
      return checksum
    else
      return nil
    end
  end

  def get_file_size_in_bytes
    content_ds = @fedora_object.datastreams['content']
    if content_ds.present?
      relationship = @fedora_object.rels_int.relationships(content_ds, :extent)
      if relationship.present?
        return relationship.first.object.value.to_s
      end
    end

    return nil
  end

  def get_original_filename

    # TODO: Eventually, once we're sure that all records have an original_file_path set, no need to still reference the content ds rels_int relationship to downloadFilename

    original_file_path = get_original_file_path
    if original_file_path.present?
      return File.basename(original_file_path)
    end

    content_ds = @fedora_object.datastreams['content']
    if content_ds.present?
      relationship = @fedora_object.rels_int.relationships(content_ds, 'info:fedora/fedora-system:def/model#downloadFilename')
      if relationship.present?
        return relationship.first.object.value
      end
    end

    return nil
  end

  def set_original_file_path(original_file_path)
    original_file_path = original_file_path.first if original_file_path.is_a?(Array)
    @fedora_object.clear_relationship(:original_name)
    @fedora_object.add_relationship(:original_name, original_file_path, true)

    original_filename = get_original_filename()
    set_dc_type_based_on_filename(original_filename)
    @fedora_object.datastreams['content'].dsLabel = original_filename
    @fedora_object.datastreams['content'].mimeType = DigitalObject::Asset.filename_to_mime_type(original_filename)
  end

  def get_original_file_path
    # TODO: Once you're sure that all original_file_path values are stored in the original_name relationship rather than DC source, change code to only use the original_name relationship
    original_file_name = @fedora_object.relationships(:original_name).first.to_s
    if original_file_name.present?
      return original_file_name
    else
      return @fedora_object.datastreams["DC"].dc_source.present? ? @fedora_object.datastreams["DC"].dc_source.first : ''
    end
  end

  def set_digital_object_data(digital_object_data, merge_dynamic_fields)
    super(digital_object_data, merge_dynamic_fields)
    
    # File upload (for assets only, and only if this object's current data validates successfully)
    if digital_object_data['import_file'].present?
      
      # Check for presentce of import file original file path (which is optional, but may be set by the user)
      @import_file_original_file_path = digital_object_data['import_file']['original_file_path']
      
      # Determine import_file_import_type
      @import_file_import_type = digital_object_data['import_file']['import_type']
      if @import_file_import_type.blank?
        raise "Missing type for import_file: digital_object_data['import_file']['import_type']"
      end
      unless VALID_FILE_IMPORT_TYPES.include?(@import_file_import_type)
        raise "Invalid type for import_file: digital_object_data['import_file']['import_type']: " + @import_file_import_type.inspect
      end
      
      # Get import file path
      @import_file_import_path = digital_object_data['import_file']['import_path']
      if @import_file_import_path.blank?
        raise "Missing path for import_file: digital_object_data['import_file']['import_path']"
      end
      
      # Check for invalid characters in import path.  Reject if non-utf8.
      # If we get weird characters (like "\xC2"), Ruby will die a horrible death.  Let's keep Ruby alive.
      if @import_file_import_path != Hyacinth::Utils::StringUtils.clean_utf8_string(@import_file_import_path)
        raise "Invalid UTF-8 characters found in file path.  Unable to upload."
      end
      
      # Make sure that the file exists and is readable
      if @import_file_import_type == IMPORT_TYPE_UPLOAD_DIRECTORY
        actual_path_to_validate = File.join(HYACINTH['upload_directory'], @import_file_import_path)
      else
        actual_path_to_validate = @import_file_import_path
      end
      unless File.exist?(actual_path_to_validate)
        raise "No file found at path: " + actual_path_to_validate
      end
      unless File.readable?(actual_path_to_validate)
        raise "File exists, but is not readable due to a permissions issue: " + actual_path_to_validate
      end
      
      # Paths cannot contain "/.." or "../"
      if @import_file_import_path.index('/..') || @import_file_import_path.index('../')
        raise 'File paths cannot contain: "..". Please specify a full path.'
      end
      
    end
  end

  def set_dc_type_based_on_filename(filename)

    mime_type = DigitalObject::Asset.filename_to_mime_type(filename)

    possible_dc_type = 'Unknown'

    if mime_type.start_with?('image')
      possible_dc_type = 'StillImage'
    elsif mime_type.start_with?('video')
      possible_dc_type = 'MovingImage'
    elsif mime_type.start_with?('audio')
      possible_dc_type = 'Sound'
    elsif mime_type.start_with?('text')
      possible_dc_type = 'Text'
    elsif mime_type.index('excel') || mime_type.index('spreadsheet') || mime_type.index('xls') || mime_type.index('application/sql')
      possible_dc_type = 'Dataset'
    elsif mime_type.start_with?('application')
      possible_dc_type = 'Software'
    end

    self.dc_type = possible_dc_type
  end

  def self.filename_to_mime_type(filename)
    detected_mime_types = MIME::Types.of(filename)
    if detected_mime_types.present?
      mime_type = MIME::Types.of(filename).first.content_type
    else
      mime_type = 'application/octet-stream' # generic catch-all for unknown content types
    end
    return mime_type
  end

  def regenrate_image_derivatives!
    credentials = ActionController::HttpAuthentication::Basic.encode_credentials(REPOSITORY_CACHE_CONFIG['username'], REPOSITORY_CACHE_CONFIG['password'])
    response = JSON(RestClient.post(REPOSITORY_CACHE_CONFIG['url'] + "/images/#{self.pid}/regenerate", {fake: 'fake'}, {Authorization: credentials}))

    #
    #resource = RestClient::Resource.new( REPOSITORY_CACHE_CONFIG['url'] + "/images/#{self.pid}/regenerate", REPOSITORY_CACHE_CONFIG['username'], REPOSITORY_CACHE_CONFIG['password'] )
    ##resource.post( {}, :Authorization => $auth )
    #response = resource.post({})

    return response['success'].to_s == 'true'
  end

  def to_solr
    doc = super
    doc['original_filename_sim'] = self.get_original_filename
    doc['original_file_path_sim'] = self.get_original_file_path
    return doc
  end

  # JSON representation
  def as_json(options={})
    json = super(options)

    json['asset_data'] = {
      filesystem_location: self.get_filesystem_location,
      checksum: self.get_checksum,
      file_size_in_bytes: self.get_file_size_in_bytes,
      original_filename: self.get_original_filename,
      original_file_path: self.get_original_file_path,
    }

    return json

  end

end
