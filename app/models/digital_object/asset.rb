require 'addressable/uri'

class DigitalObject::Asset < DigitalObject::Base
  include DigitalObject::Assets::Validations
  include DigitalObject::Assets::FileImport
  include DigitalObject::Assets::Transcript
  include DigitalObject::Assets::IndexDocument
  include DigitalObject::Assets::Captions

  UNKNOWN_DC_TYPE = 'Unknown'
  VALID_DC_TYPES = [UNKNOWN_DC_TYPE, 'Dataset', 'MovingImage', 'Software', 'Sound', 'StillImage', 'Text']
  DIGITAL_OBJECT_TYPE_STRING_KEY = 'asset'

  DEFAULT_ASSET_NAME = 'Asset' # For when a title is not supplied and we're not doing with a filesystem upload

  IMPORT_TYPE_INTERNAL = 'internal'
  IMPORT_TYPE_EXTERNAL = 'external'
  IMPORT_TYPE_POST_DATA = 'post_data'
  IMPORT_TYPE_UPLOAD_DIRECTORY = 'upload_directory'
  VALID_FILE_IMPORT_TYPES = [IMPORT_TYPE_INTERNAL, IMPORT_TYPE_EXTERNAL, IMPORT_TYPE_POST_DATA, IMPORT_TYPE_UPLOAD_DIRECTORY]

  SIZE_RESTRICTION_LITERAL_VALUE = 'size restriction'
  ONSITE_RESTRICTION_LITERAL_VALUE = 'onsite restriction'

  attr_accessor :restricted_size_image, :restricted_onsite

  def initialize
    super

    @import_file_import_type = nil
    @import_file_import_path = nil
    @import_file_original_file_path = nil
    @access_copy_import_path = nil
    @service_copy_import_type = nil
    @service_copy_import_path = nil

    @restricted_size_image = false
    @restricted_onsite = false

    # Default to 'Unknown' dc_type.  We expect other code to properly set this
    # once the asset file type is known, but this avoid a blank value for dc_type
    # and helps to identify errors when a dc_type has been improperly set.
    self.dc_type ||= UNKNOWN_DC_TYPE
  end

  # Called during save, after all validations have passed
  def create_fedora_object
    GenericResource.new(pid: next_pid)
  end

  def run_post_validation_pre_save_logic
    super
    # For new DigitalObjects, we want to import a file as part of our save operation (assuming that this new object doesn't already have an associated Fedora object with a 'content' datastream)
    do_file_import if self.new_record? && @fedora_object.present? && @fedora_object.datastreams['content'].blank?
    do_access_copy_import if @access_copy_import_path.present? && self.access_copy_location.blank?
    do_service_copy_import if @service_copy_import_path.present? && self.service_copy_location.blank?

    self.dc_type = BestType.dc_type.for_file_name(original_filename) if self.dc_type == 'Unknown' # Attempt to correct dc_type for 'Unknown' dc_type DigitalObjects
  end

  def run_after_create_logic
    # For new Hyacinth assets, queue derivative generation (image derivatives, audio derivatives, video derivatives, fulltext extraction, etc.)
    generate_derivatives
  end

  def run_after_save_logic
    regenerate_image_server_cached_properties!
  end

  def convert_upload_import_to_internal!
    return unless @import_file_import_type == IMPORT_TYPE_UPLOAD_DIRECTORY
    # If this is an upload directory import, we'll adjust the import file path
    # and pretend that it's actually an internal file import
    @import_file_import_path = File.join(HYACINTH['upload_directory'], @import_file_import_path)
    @import_file_import_type = IMPORT_TYPE_INTERNAL
  end

  def filesystem_location
    content_ds = @fedora_object.datastreams['content']
    return nil unless content_ds.present?
    Addressable::URI.unencode(content_ds.dsLocation).gsub(/^file:/, '')
  end

  def access_copy_location
    access_ds = @fedora_object.datastreams['access']
    return nil unless access_ds.present?
    Addressable::URI.unencode(access_ds.dsLocation).gsub(/^file:/, '')
  end

  def service_copy_location
    service_ds = @fedora_object.datastreams['service']
    return nil unless service_ds.present?
    Addressable::URI.unencode(service_ds.dsLocation).gsub(/^file:/, '')
  end

  def checksum
    return nil unless @fedora_object.present? && @fedora_object.datastreams['content'].present?
    content_ds = @fedora_object.datastreams['content']
    return nil unless @fedora_object.rels_int.relationships(content_ds, :has_message_digest).length > 0
    @fedora_object.rels_int.relationships(content_ds, :has_message_digest).first.object.value[4..-1] # chop off leading 'urn:' string
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

  def access_copy_file_size_in_bytes
    access_ds = @fedora_object.datastreams['access']
    first_relationship_object_for_datastream(access_ds, :extent)
  end

  def service_copy_file_size_in_bytes
    service_ds = @fedora_object.datastreams['service']
    first_relationship_object_for_datastream(service_ds, :extent)
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
    @fedora_object.datastreams['content'].mimeType = BestType.mime_type.for_file_name(original_filename)
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

    handle_restriction_properties(digital_object_data)

    # File upload (for NEW assets only, and only if this object's current data validates successfully)
    handle_new_file_upload(digital_object_data['import_file']) if self.new_record? && digital_object_data['import_file'].present?

    # Access copy upload (only if an object doesn't already have an access copy)
    handle_access_copy_upload(digital_object_data['import_file']) if digital_object_data.fetch('import_file', {})['access_copy_import_path'].present?

    # Service copy upload (only if an object doesn't already have an service copy)
    handle_service_copy_upload(digital_object_data['import_file']) if digital_object_data.fetch('import_file', {})['service_copy_import_path'].present?
  end

  def onsite_restriction_value_changed?(digital_object_data)
    # Return true if the existing restriction value doesn't match the new onsite restriction value
    new_value = onsite_restriction_value_from_digital_object_data(digital_object_data)
    return false if new_value.nil? # Value wasn't set, so report no change
    restricted_onsite != new_value
  end

  def onsite_restriction_value_from_digital_object_data(digital_object_data)
    return nil unless digital_object_data.key?('restrictions') && digital_object_data['restrictions'].key?('restricted_onsite')
    # We currently default to not having an onsite restriction, so only apply an onsite restriction when given explicit value of true
    digital_object_data['restrictions']['restricted_onsite'].to_s.downcase == 'true'
  end

  def handle_restriction_properties(digital_object_data)
    return unless digital_object_data.key?('restrictions')
    if digital_object_data['restrictions'].key?('restricted_size_image')
      # To be extra careful about accidentally making restricted size content public, only unrestrict when given explicit value of false
      self.restricted_size_image = (digital_object_data['restrictions']['restricted_size_image'].to_s.downcase == 'false') ? false : true
    end

    self.restricted_onsite = onsite_restriction_value_from_digital_object_data(digital_object_data)
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

  def handle_access_copy_upload(import_file_data)
    if import_file_data['access_copy_import_path'].present?
      # Get access copy import path
      @access_copy_import_path = import_file_data['access_copy_import_path']
      raise 'File paths cannot contain: "..". Please specify a full path.' if @access_copy_import_path.index('/..') || @access_copy_import_path.index('../')
    end
  end

  def handle_service_copy_upload(import_file_data)
    if import_file_data['service_copy_import_path'].present?
      # Get service copy import path
      @service_copy_import_path = import_file_data['service_copy_import_path']
      @service_copy_import_type = import_file_data['service_copy_import_type']
      raise 'File paths cannot contain: "..". Please specify a full path.' if @service_copy_import_path.index('/..') || @service_copy_import_path.index('../')
      raise "Must specify import type (#{VALID_FILE_IMPORT_TYPES.join(', ')}) for service copy." unless VALID_FILE_IMPORT_TYPES.include?(@service_copy_import_type)
    end
  end

  def destroy_and_regenerate_derivatives!
    generate_derivatives(true)
  end

  def generate_derivatives(delete_existing_derivatives = false)
    credentials = ActionController::HttpAuthentication::Token.encode_credentials(IMAGE_SERVER_CONFIG['remote_request_api_key'])
    resource_url = IMAGE_SERVER_CONFIG['url'] + "/resources/#{pid}"
    # Destroy old derivatives if requested
    destroy_response = JSON(RestClient.delete(resource_url, Authorization: credentials)) if delete_existing_derivatives
    # Queue creation of new derivatives
    queue_response = JSON(RestClient.put(resource_url, {}, { Authorization: credentials }))
    queue_response['success'].to_s == 'true' && (!delete_existing_derivatives || destroy_response['success'].to_s == 'true')
  rescue Errno::ECONNREFUSED, RestClient::InternalServerError, SocketError, RestClient::NotFound
    Hyacinth::Utils::Logger.logger.error("Tried to regenerate derivatives for #{pid}, but could not connect to image server at: #{IMAGE_SERVER_CONFIG['url']}")
    false
  end

  def regenerate_image_server_cached_properties!
    credentials = ActionController::HttpAuthentication::Token.encode_credentials(IMAGE_SERVER_CONFIG['remote_request_api_key'])
    response = JSON(RestClient.delete(IMAGE_SERVER_CONFIG['url'] + "/resources/#{pid}/destroy_cachable_properties", Authorization: credentials))
    response['success'].to_s == 'true'
  rescue Errno::ECONNREFUSED, RestClient::InternalServerError, SocketError, RestClient::NotFound
    Hyacinth::Utils::Logger.logger.error("Tried to regenerate cached image properties for #{pid}, but could not connect to image server at: #{IMAGE_SERVER_CONFIG['url']}")
    false
  end

  def save_datastreams
    super
    save_captions_datastream
    save_chapters_datastream
    true
  end

  def load_data_from_sources
    super

    # Get restriction status
    self.restricted_size_image = fedora_object.relationships(:restriction).include?(SIZE_RESTRICTION_LITERAL_VALUE)
    self.restricted_onsite = fedora_object.relationships(:restriction).include?(ONSITE_RESTRICTION_LITERAL_VALUE)
  end

  def set_data_to_sources
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

    if restricted_onsite
      fedora_object.add_relationship(:restriction, ONSITE_RESTRICTION_LITERAL_VALUE, true)
    else
      # Remove SIZE_RESTRICTION_LITERAL_VALUE, but preserve any other restrictions
      current_restrictions = fedora_object.relationships(:restriction).to_a
      fedora_object.clear_relationship(:restriction)
      current_restrictions.delete(ONSITE_RESTRICTION_LITERAL_VALUE)
      current_restrictions.each do |restriction_liternal|
        fedora_object.add_relationship(:restriction, restriction_liternal, true)
      end
    end

    # ensure that uuid directory exists
    FileUtils.mkdir_p(Hyacinth::Utils::PathUtils.data_directory_path_for_uuid(self.uuid))
    write_update_transcript_file_if_changed!
    write_update_index_document_file_if_changed!
    write_update_captions_file_if_changed!
  end

  def write_update_transcript_file_if_changed!
    if transcript_changed?
      IO.write(self.transcript_location, self.transcript)
    end
  end

  def write_update_index_document_file_if_changed!
    if index_document_changed?
      IO.write(self.index_document_location, self.index_document)
    end
  end

  def write_update_captions_file_if_changed!
    if captions_changed?
      IO.write(self.captions_location, self.captions)
    end
  end

  def player_url(client_ip = nil)
    return nil if access_copy_location.blank?

    # if no media_streaming config is present for wowza, always default to progressive download for the player URL
    return '/digital_objects/' + self.pid + '/download_access_copy' unless HYACINTH.fetch('media_streaming', {})['wowza'].present?

    # use the media streaming config. only wowza is currently supported as a streaming source.
    raise 'Unsupported media_streaming config: ' + HYACINTH['media_streaming'].inspect unless HYACINTH['media_streaming']['wowza'].present?

    wowza_config = HYACINTH['media_streaming']['wowza']
    Wowza::SecureToken::Params.new({
      stream: wowza_config['application'] + '/_definst_/' + (access_copy_location.downcase.index('.mp3') ? 'mp3:' : 'mp4:') + access_copy_location.gsub(/^\//, ''),
      secret: wowza_config['shared_secret'],
      client_ip: client_ip,
      starttime: Time.now.to_i,
      endtime: Time.now.to_i + wowza_config['token_lifetime'].to_i,
      prefix: wowza_config['token_prefix']
    }).to_url_with_token_hash(wowza_config['host'], wowza_config['ssl_port'], 'hls-ssl')

  end

  def to_solr
    doc = super
    doc['original_filename_sim'] = original_filename
    doc['original_file_path_sim'] = original_file_path
    doc['access_copy_location_sim'] = access_copy_location
    doc['service_copy_location_sim'] = service_copy_location
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
      original_file_path: original_file_path,
      access_copy_location: access_copy_location,
      access_copy_file_size_in_bytes: access_copy_file_size_in_bytes,
      service_copy_location: service_copy_location,
      service_copy_file_size_in_bytes: service_copy_file_size_in_bytes
    }

    json['restrictions'] ||= {}
    json['restrictions']['restricted_size_image'] = restricted_size_image
    json['restrictions']['restricted_onsite'] = restricted_onsite
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

  def self.ints_as_binstring(ints = [])
    stub = "".force_encoding(Encoding::ASCII_8BIT)
    ints.inject(stub) { |m,c| m << c }
  end

  BOM_UTF_8 = ints_as_binstring([239,187,191])
  BOM_UTF_16BE = ints_as_binstring([254,255])
  BOM_UTF_16LE = ints_as_binstring([255,254])
  BOM_UTF_32BE = ints_as_binstring([0,0,254,255])
  BOM_UTF_32LE = ints_as_binstring([255,254,0,0])


  def encoded_string(source, target_encoding = Encoding::UTF_8)
    magic_bytes = source.each_byte.lazy.first(4)
    magic_bytes = DigitalObject::Asset.ints_as_binstring(magic_bytes)
    return source if source.encoding == target_encoding
    # these codepoint patterns indicate unicode data in an ASCII_8 string
    case
    when magic_bytes.start_with?(BOM_UTF_16BE)
      source_encoding = Encoding::UTF_16BE
      source = source.byteslice(BOM_UTF_16BE.length..-1)
    when magic_bytes.start_with?(BOM_UTF_16LE)
      source_encoding = Encoding::UTF_16LE
      source = source.byteslice(BOM_UTF_16LE.length..-1)
    when magic_bytes.start_with?(BOM_UTF_8)
      source_encoding = Encoding::UTF_8
      source = source.byteslice(BOM_UTF_8.length..-1)
    when magic_bytes.start_with?(BOM_UTF_32BE)
      source_encoding = Encoding::UTF_32BE
      source = source.byteslice(BOM_UTF_32BE.length..-1)
    when magic_bytes.start_with?(BOM_UTF_32LE)
      source_encoding = Encoding::UTF_32LE
      source = source.byteslice(BOM_UTF_32LE.length..-1)
    else
      detection = CharlockHolmes::EncodingDetector.detect(source)
      source_encoding = detection[:encoding] ?
        Encoding.find(detection[:encoding]) : Encoding::ASCII_8BIT
    end
    if source.encoding == target_encoding
      # just the trim, thanks
      source
    else
      source.force_encoding(source_encoding).encode(target_encoding)
    end
  end
end
