require 'addressable/uri'

class DigitalObject::Asset < DigitalObject::Base
  include DigitalObject::Assets::Validations

  VALID_DC_TYPES = ['Unknown', 'Dataset', 'MovingImage', 'Software', 'Sound', 'StillImage', 'Text']
  DIGITAL_OBJECT_TYPE_STRING_KEY = 'asset'

  DEFAULT_ASSET_NAME = 'Asset' # For when a title is not supplied and we're not doing with a filesystem upload

  IMPORT_TYPE_INTERNAL = 'internal'
  IMPORT_TYPE_EXTERNAL = 'external'
  IMPORT_TYPE_POST_DATA = 'post_data'
  IMPORT_TYPE_UPLOAD_DIRECTORY = 'upload_directory'
  VALID_FILE_IMPORT_TYPES = [IMPORT_TYPE_INTERNAL, IMPORT_TYPE_EXTERNAL, IMPORT_TYPE_POST_DATA, IMPORT_TYPE_UPLOAD_DIRECTORY]

  SIZE_RESTRICTION_LITERAL_VALUE = 'size restriction'

  attr_accessor :restricted_size_image

  def initialize
    super

    @import_file_import_type = nil
    @import_file_import_path = nil
    @import_file_original_file_path = nil

    @restricted_size_image = false

    # Default to 'Unknown' dc_type.  We expect other code to properly set this
    # once the asset file type is known, but this avoid a blank value for dc_type
    # and helps to identify errors when a dc_type has been improperly set.
    self.dc_type ||= VALID_DC_TYPES.first
  end

  # Called during save, after all validations have passed
  def create_fedora_object
    GenericResource.new(pid: next_pid)
  end

  def run_post_validation_pre_save_logic
    super
    # For new DigitalObjects, we want to import a file as part of our save operation (assuming that this new object doesn't already have an associated Fedora object with a 'content' datastream)
    do_file_import if self.new_record? && @fedora_object.present? && @fedora_object.datastreams['content'].blank?

    self.dc_type = dc_type_for_filename(original_filename) if self.dc_type == 'Unknown' # Attempt to correct dc_type for 'Unknown' dc_type DigitalObjects
  end

  def run_after_create_logic
    # For new Hyacinth records, perform post processing on the asset file (image derivative generation, fulltext extraction, etc.)
    regenerate_image_derivatives! if self.dc_type == 'StillImage'
  end

  def run_after_save_logic
    self.regenerate_image_server_cached_properties! if self.dc_type == 'StillImage'
  end

  def convert_upload_import_to_internal!
    return unless @import_file_import_type == IMPORT_TYPE_UPLOAD_DIRECTORY
    # If this is an upload directory import, we'll adjust the import file path
    # and pretend that it's actually an internal file import
    @import_file_import_path = File.join(HYACINTH['upload_directory'], @import_file_import_path)
    @import_file_import_type = IMPORT_TYPE_INTERNAL
  end

  # Returns true if file import was successful, false otherwise
  def do_file_import
    path_to_final_save_location = nil
    import_file_sha256_hexdigest = nil
    import_file_size = nil

    convert_upload_import_to_internal!

    # Generate checksum using 4096-byte buffered approach (to keep memory usage low for large files)
    # If this is an internal file, also copy the file to its internal destination
    File.open(@import_file_import_path, 'rb') do |import_file| # 'r' == write, 'b' == binary mode
      import_file_size = import_file.size

      copy_results = copy_and_verify_file(import_file)

      path_to_final_save_location = copy_results[0]
      import_file_sha256_hexdigest = copy_results[1]
    end
    # At this point, there is a file at path_to_final_save_location and
    # import_file_sha256_hexdigest has been calculated, and
    # import_file_size has been set, regardless of import type.

    original_filename = File.basename(@import_file_original_file_path || @import_file_import_path)

    # If the title of this Asset is the DEFAULT_ASSET_NAME, use the original filename as the title.
    # If the title of this Asset is NOT equal to DEFAULT_ASSET_NAME, that means that a title was
    # manually set by the user in this Asset's digital_object_data.
    set_title('', original_filename) if get_title == DEFAULT_ASSET_NAME

    # Create datastream for file

    # "controlGroup => 'E'" below means "External Referenced Content" -- as in, a file that's referenced by Fedora but not stored in Fedora's internal data store

    # Line below will create paths like "file:/this%23_and_%26_also_something%20great/here.txt"
    # We DO NOT want a double slash at the beginnings of these paths.
    # We need to manually escape ampersands (%26) and pound signs (%23) because these are not always handled by Addressable::URI.encode()
    ds_location = Addressable::URI.encode('file:' + path_to_final_save_location).gsub('&', '%26').gsub('#', '%23')
    content_ds = @fedora_object.create_datastream(ActiveFedora::Datastream, 'content', controlGroup: 'E', mimeType: DigitalObject::Asset.filename_to_mime_type(original_filename), dsLabel: original_filename, versionable: true)
    content_ds.dsLocation = ds_location
    @fedora_object.datastreams["DC"].dc_source = path_to_final_save_location
    content_ds.checksum = import_file_sha256_hexdigest
    content_ds.checksumType = 'SHA-256'
    @fedora_object.add_datastream(content_ds)

    # Add size property to content datastream using :extent predicate
    @fedora_object.rels_int.add_relationship(content_ds, :extent, import_file_size.to_s, true) # last param *true* means that this is a literal value rather than a relationship

    # Add original filename property to content datastream using <info:fedora/fedora-system:def/model#downloadFilename> relationship
    @fedora_object.rels_int.add_relationship(content_ds, 'info:fedora/fedora-system:def/model#downloadFilename', original_filename, true) # last param *true* means that this is a literal value rather than a relationship

    # Assume top-left orientation at upload time. This can be corrected later in the app.
    @fedora_object.rels_int.add_relationship(content_ds, :orientation, 'top-left', true) # last param *true* means that this is a literal value rather than a relationship

    self.original_file_path = (@import_file_original_file_path || @import_file_import_path) # This also updates the 'content' datastream label
  end

  def copy_and_verify_file(import_file)
    if [IMPORT_TYPE_INTERNAL, IMPORT_TYPE_POST_DATA].include? @import_file_import_type
      return copy_and_verify_internal_file(import_file)
    elsif @import_file_import_type == IMPORT_TYPE_EXTERNAL
      return copy_and_verify_external_file(import_file)
    end
    raise "Did not expect @import_file_import_type: #{@import_file_import_type.inspect}"
  end

  def copy_and_verify_internal_file(import_file)
    path_to_final_save_location = Hyacinth::Utils::PathUtils.path_to_asset_file(pid, project, File.basename(@import_file_import_path))

    if File.exist?(path_to_final_save_location)
      raise 'Could not upload new internally-stored file because existing file was already found at target location: ' + path_to_final_save_location
    end

    # Recursively make necessary directories
    FileUtils.mkdir_p(File.dirname(path_to_final_save_location))

    # Test write abilities by touching the target file
    FileUtils.touch(path_to_final_save_location)
    unless File.exist?(path_to_final_save_location)
      raise 'Unable to write to file path: ' + path_to_final_save_location
    end

    import_file_sha256 = Digest::SHA256.new
    # Copy file to target path_to_final_save_location while generating checksum of original
    File.open(path_to_final_save_location, 'wb') do |new_file| # 'w' == write, 'b' == binary mode
      buff = ''
      while import_file.read(4096, buff)
        import_file_sha256.update(buff)
        new_file.write(buff)
      end
    end
    import_file_sha256_hexdigest = import_file_sha256.hexdigest

    # Confirm that checksum of newly written file matches original checksum.  Delete new file and raise error if it doesn't.
    copied_file_sha256 = Digest::SHA256.new
    File.open(path_to_final_save_location, 'rb') do |copied_file| # 'r' == write, 'b' == binary mode
      buff = ''
      copied_file_sha256.update(buff) while copied_file.read(4096, buff)
    end
    copied_file_sha256_hexdigest = copied_file_sha256.hexdigest

    if copied_file_sha256_hexdigest != import_file_sha256_hexdigest
      FileUtils.rm(path_to_final_save_location) # Important to delete new file
      raise "Error during file copy.  Copied file checksum (#{copied_file_sha256_hexdigest}) didn't match import file (#{import_file_sha256_hexdigest}).  Try file import again."
    end

    [path_to_final_save_location, import_file_sha256_hexdigest]
  end

  def copy_and_verify_external_file(import_file)
    import_file_sha256 = Digest::SHA256.new
    # Generate checksum for file
    buff = ''
    import_file_sha256.update(buff) while import_file.read(4096, buff)

    # Set path_to_final_save_location as original file path
    path_to_final_save_location = @import_file_import_path
    import_file_sha256_hexdigest = import_file_sha256.hexdigest
    [path_to_final_save_location, import_file_sha256_hexdigest]
  end

  def filesystem_location
    content_ds = @fedora_object.datastreams['content']
    return nil unless content_ds.present?
    Addressable::URI.unencode(content_ds.dsLocation).gsub(/^file:/, '')
  end

  def checksum
    content_ds = @fedora_object.datastreams['content']
    return nil unless content_ds.present?

    value = ''
    value += content_ds.checksumType + ':' if content_ds.checksumType
    value += content_ds.checksum if content_ds.checksum
    value
  end

  def first_relationship_object_for_datastream(ds, rel)
    if ds.present?
      relationship = @fedora_object.rels_int.relationships(ds, rel)
      return relationship.first.object.value.to_s if relationship.present?
    end
    nil
  end

  def file_size_in_bytes
    content_ds = @fedora_object.datastreams['content']
    first_relationship_object_for_datastream(content_ds, :extent)
  end

  def original_filename
    # TODO: Eventually, once we're sure that all records have an original_file_path set, no need to still reference the content ds rels_int relationship to downloadFilename

    return File.basename(original_file_path) if original_file_path.present?

    content_ds = @fedora_object.datastreams['content']
    first_relationship_object_for_datastream(content_ds, 'info:fedora/fedora-system:def/model#downloadFilename')
  end

  def original_file_path=(original_file_path)
    original_file_path = original_file_path.first if original_file_path.is_a?(Array)
    @fedora_object.clear_relationship(:original_name)
    @fedora_object.add_relationship(:original_name, original_file_path, true)

    @fedora_object.datastreams['content'].dsLabel = original_filename
    @fedora_object.datastreams['content'].mimeType = DigitalObject::Asset.filename_to_mime_type(original_filename)
  end

  def original_file_path
    # TODO: Once you're sure that all original_file_path values are stored in the original_name relationship rather than DC source, change code to only use the original_name relationship
    original_file_name = @fedora_object.relationships(:original_name).first.to_s

    return original_file_name if original_file_name.present?

    @fedora_object.datastreams["DC"].dc_source.present? ? @fedora_object.datastreams["DC"].dc_source.first : ''
  end

  def set_digital_object_data(digital_object_data, merge_dynamic_fields)
    super(digital_object_data, merge_dynamic_fields)

    # If this Asset's title is blank after dynamic field data is applied,
    # use the DEFAULT_ASSET_NAME. This allows validation to complete,
    # and the title will be later inferred from the filename during the upload step.
    handle_blank_asset_title

    if digital_object_data.key?('restrictions') && digital_object_data['restrictions'].key?('restricted_size_image')
      self.restricted_size_image = digital_object_data['restrictions']['restricted_size_image']
    end

    # File upload (for NEW assets only, and only if this object's current data validates successfully)
    handle_new_file_upload(digital_object_data['import_file']) if self.new_record? && digital_object_data['import_file'].present?
  end

  def handle_blank_asset_title
    set_title('', DigitalObject::Asset::DEFAULT_ASSET_NAME) if get_title.blank?
  end

  def handle_new_file_upload(import_file_data)
    validate_import_file_data(import_file_data)
    # Check for presentce of import file original file path (which is optional, but may be set by the user)
    @import_file_original_file_path = import_file_data['original_file_path']

    # Determine import_file_import_type
    @import_file_import_type = import_file_data['import_type']

    # Get import file path
    @import_file_import_path = import_file_data['import_path']

    # Paths cannot contain "/.." or "../"
    raise 'File paths cannot contain: "..". Please specify a full path.' if @import_file_import_path.index('/..') || @import_file_import_path.index('../')
  end

  def dc_type_for_filename(filename)
    mime_type = DigitalObject::Asset.filename_to_mime_type(filename)

    mimes_to_dc = {
      /^image/ => 'StillImage',
      /^video/ => 'MovingImage',
      /^audio/ => 'Sound',
      /^text/ => 'Text',
      /excel|spreadsheet|xls|application\/sql/ => 'Dataset',
      /^application/ => 'Software'
    }

    possible_dc_type = mimes_to_dc.detect { |pattern, _type_val| mime_type =~ pattern }

    possible_dc_type ? possible_dc_type.last : 'Unknown'
  end

  def self.filename_to_mime_type(filename)
    detected_mime_types = MIME::Types.of(filename)
    detected_mime_types.present? ? MIME::Types.of(filename).first.content_type : 'application/octet-stream' # generic catch-all for unknown content types
  end

  def regenerate_image_derivatives!
    credentials = ActionController::HttpAuthentication::Token.encode_credentials(IMAGE_SERVER_CONFIG['remote_request_api_key'])
    resource_url = IMAGE_SERVER_CONFIG['url'] + "/resources/#{pid}"
    # Destroy old derivatives
    destroy_response = JSON(RestClient.delete(resource_url, Authorization: credentials))
    # Queue creation of new derivatives
    queue_response = JSON(RestClient.put(resource_url, {}, Authorization: credentials))
    destroy_response['success'].to_s == 'true' && queue_response['success'].to_s == 'true'
  rescue Errno::ECONNREFUSED, RestClient::InternalServerError, SocketError, RestClient::NotFound
    Hyacinth::Utils::Logger.logger.error("Tried to regenerate image derivatives for #{pid}, but could not connect to image server at: #{IMAGE_SERVER_CONFIG['url']}")
    false
  end

  def regenerate_image_server_cached_properties!
    credentials = ActionController::HttpAuthentication::Token.encode_credentials(IMAGE_SERVER_CONFIG['remote_request_api_key'])
    response = JSON(RestClient.delete(IMAGE_SERVER_CONFIG['url'] + "/resources/#{pid}/destroy_cachable_properties", Authorization: credentials))
    response['success'].to_s == 'true'
  rescue Errno::ECONNREFUSED, RestClient::InternalServerError, SocketError, RestClient::NotFound
    Hyacinth::Utils::Logger.logger.error("Tried to regenerate image derivatives for #{pid}, but could not connect to image server at: #{IMAGE_SERVER_CONFIG['url']}")
    return false
  end

  def load_data_from_sources
    super

    # Get restriction status
    self.restricted_size_image = fedora_object.relationships(:restriction).include?(SIZE_RESTRICTION_LITERAL_VALUE)
  end

  def set_fedora_object_properties
    super

    if restricted_size_image
      fedora_object.add_relationship(:restriction, SIZE_RESTRICTION_LITERAL_VALUE, true)
    else
      # Remove SIZE_RESTRICTION_LITERAL_VALUE, but preserve any other restrictions
      current_restrictions = fedora_object.relationships(:restriction).to_a
      fedora_object.clear_relationship(:restriction)
      current_restrictions.delete(SIZE_RESTRICTION_LITERAL_VALUE)
      current_restrictions.each do |restriction_liternal|
        fedora_object.add_relationship(:restriction, restriction_liternal, true)
      end
    end
  end

  def to_solr
    doc = super
    doc['original_filename_sim'] = original_filename
    doc['original_file_path_sim'] = original_file_path
    doc
  end

  # JSON representation
  def as_json(options = {})
    json = super(options)

    json['asset_data'] = {
      filesystem_location: filesystem_location,
      checksum: checksum,
      file_size_in_bytes: file_size_in_bytes,
      original_filename: original_filename,
      original_file_path: original_file_path
    }

    json['restrictions'] ||= {}
    json['restrictions']['restricted_size_image'] = restricted_size_image

    json
  end

  # Returns: Hash of data confirming creation
  def as_confirmation_json
    json = super
    json ['uploaded_file_confirmation'] =
      {
        'name' => original_filename,
        'size' => file_size_in_bytes,
        'errors' => errors.full_messages
      }
    json
  end
end
