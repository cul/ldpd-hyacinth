require 'addressable/uri'

class DigitalObject::Asset < DigitalObject::Base
  include DigitalObject::Assets::Validations
  include DigitalObject::Assets::FeaturedRegion
  include DigitalObject::Assets::FileImport
  include DigitalObject::Assets::Transcript
  include DigitalObject::Assets::IndexDocument
  include DigitalObject::Assets::Captions

  UNKNOWN_DC_TYPE = BestType::PcdmTypeLookup::UNKNOWN
  ASSET_DC_TYPES = ['Dataset', 'MovingImage', 'Software', 'Sound', 'StillImage', 'Text']
  VALID_DC_TYPES = (BestType::PcdmTypeLookup::VALID_TYPES + ASSET_DC_TYPES).uniq
  AMI_DC_TYPES = ['Audio', 'MovingImage', 'Sound', 'Video']
  IMAGE_DC_TYPES = ['Image', 'StillImage']

  DIGITAL_OBJECT_TYPE_STRING_KEY = 'asset'

  DEFAULT_ASSET_NAME = 'Asset' # For when a title is not supplied and we're not doing with a filesystem upload

  IMPORT_TYPE_INTERNAL = 'internal'
  IMPORT_TYPE_EXTERNAL = 'external'
  IMPORT_TYPE_POST_DATA = 'post_data'
  IMPORT_TYPE_UPLOAD_DIRECTORY = 'upload_directory'
  VALID_FILE_IMPORT_TYPES = [IMPORT_TYPE_INTERNAL, IMPORT_TYPE_EXTERNAL, IMPORT_TYPE_POST_DATA, IMPORT_TYPE_UPLOAD_DIRECTORY]

  SIZE_RESTRICTION_LITERAL_VALUE = 'size restriction'
  ONSITE_RESTRICTION_LITERAL_VALUE = 'onsite restriction'

  MAIN_RESOURCE_NAME = 'main'
  SERVICE_RESOURCE_NAME = 'service'
  ACCESS_RESOURCE_NAME = 'access'
  POSTER_RESOURCE_NAME = 'poster'
  VALID_RESOURCE_TYPES = [MAIN_RESOURCE_NAME, SERVICE_RESOURCE_NAME, ACCESS_RESOURCE_NAME, POSTER_RESOURCE_NAME]
  VALID_FILE_IMPORT_RESOURCE_TYPES = VALID_RESOURCE_TYPES # At this time, all resource types can be imported by users

  attr_accessor :restricted_size_image, :restricted_onsite

  def initialize
    super

    # TODO: Make sure none of these variables are used anymore
    # @import_file_import_type = nil
    # @import_file_import_path = nil
    # @import_file_original_file_path = nil
    # @access_copy_import_path = nil
    # @poster_import_path = nil
    # @service_copy_import_type = nil
    # @service_copy_import_path = nil

    @import_file_data = {}

    @restricted_size_image = false
    @restricted_onsite = false

    # We default to `true` for Asset derivative processing,
    # assuming that all new Assets will require some type of processing.
    @perform_derivative_processing = true

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
    process_import_file_data_if_present

    # Attempt to correct dc_type for 'Unknown' dc_type DigitalObjects, based on original filename
    self.dc_type = BestType.dc_type.for_file_name(original_filename) if self.dc_type == 'Unknown'

    # For ISO files, even the original filename can't tell us if they're possibly audio or video content,
    # so if a service copy has been uploaded with the video then we'll determine dc type based on
    # the extension of the service copy.
    if self.dc_type == 'Unknown' && self.location_uri_for_resource('service').present?
      self.dc_type = BestType.dc_type.for_file_name(self.location_uri_for_resource('service'))
    end

    # If we still haven't been able to determine a dc type, see if we can get the
    # information from an access copy file extension (if present)
    if self.dc_type == 'Unknown' && self.location_uri_for_resource('access').present?
      self.dc_type = BestType.dc_type.for_file_name(self.location_uri_for_resource('access'))
    end
  end

  def run_after_create_logic
    # Nothing right now!
  end

  def run_after_save_logic
    run_derivative_updates_if_necessary
  end

  def run_derivative_updates_if_necessary
    # Conditionally run derivative processing on save
    RequestDerivativesJob.perform_later(self.pid) if self.perform_derivative_processing
    # Always update the image service on save, regardless of whether derivatives are ready
    UpdateImageServiceJob.perform_later(self.pid)
  end

  # If the given uri is a file URI, returns an unescaped path string.  Otherwise returns the provided uri value, unchanged.
  def convert_location_uri_to_path_if_file_uri(uri)
    return nil if uri.nil?
    uri.start_with?('file:/') ? Hyacinth::Utils::UriUtils.location_uri_to_file_path(uri) : uri
  end

  # TODO: Use this location in other places rather than directly calling the other
  # underlying methods (filesystem_location_uri, service_copy_location_uri, etc.)
  def location_uri_for_resource(resource_name)
    case resource_name
    when 'access'
      @fedora_object&.datastreams&.[]('access')&.dsLocation
    when 'poster'
      @fedora_object&.datastreams&.[]('poster')&.dsLocation
    when 'main'
      @fedora_object&.datastreams&.[]('content')&.dsLocation
    when 'service'
      @fedora_object&.datastreams&.[]('service')&.dsLocation
    else
      raise ArgumentError, "Unsupported resource: #{resource_name}"
    end
  end

  def file_size_for_resource(resource_name)
    case resource_name
    when 'access'
      first_relationship_object_for_datastream(@fedora_object&.datastreams&.[]('access'), :extent)
    when 'poster'
      first_relationship_object_for_datastream(@fedora_object&.datastreams&.[]('poster'), :extent)
    when 'main'
      first_relationship_object_for_datastream(@fedora_object&.datastreams&.[]('content'), :extent)
    when 'service'
      first_relationship_object_for_datastream(@fedora_object&.datastreams&.[]('service'), :extent)
    else
      raise ArgumentError, "Unsupported resource: #{resource_name}"
    end
  end

  # TODO: Use this method in other places rather than directly calling the other
  # underlying methods (filesystem_location_uri, service_copy_location_uri, etc.)
  def location_for_resource(resource_name)
    convert_location_uri_to_path_if_file_uri(location_uri_for_resource(resource_name))
  end

  # TODO: Replace calls to this method with: location_uri_for_resource('main'),
  # and then delete this method.
  def filesystem_location_uri
    location_uri_for_resource('main')
  end

  # TODO: Look into removing this method if possible, and only using filesystem_location_uri.
  # This method only works for file:// URIs.
  def filesystem_location
    convert_location_uri_to_path_if_file_uri(filesystem_location_uri)
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

  # TODO: Replace occurrences of this method with `file_size_for_resource('main')`
  def file_size_in_bytes
    file_size_for_resource('main')
  end

  # TODO: Replace occurrences of this method with `file_size_for_resource('main')`
  def main_resource_file_size_in_bytes
    file_size_for_resource('main')
  end

  # TODO: Replace occurrences of this method with `file_size_for_resource('access')`
  def access_copy_file_size_in_bytes
    file_size_for_resource('access')
  end

  # TODO: Replace occurrences of this method with `file_size_for_resource('poster')`
  def poster_file_size_in_bytes
    file_size_for_resource('poster')
  end

  # TODO: Replace occurrences of this method with `file_size_for_resource('service')`
  def service_copy_file_size_in_bytes
    file_size_for_resource('service')
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

    handle_import_file_data(digital_object_data['import_file']) if digital_object_data['import_file'].present?

    # Featured region
    handle_featured_region(digital_object_data['featured_region']) if digital_object_data['featured_region'].present?
  end

  def handle_import_file_data(import_file_data)
    # Remove all blank values before assigning data to import_file_data variable (so that subsequent operations
    # only act on values that are actually present).
    @import_file_data = Hyacinth::Utils::HashUtils.recursively_remove_blank_fields_from_hash(import_file_data)
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

  def handle_featured_region(region)
    self.featured_region = region
  end

  def handle_blank_asset_title
    set_title('', DigitalObject::Asset::DEFAULT_ASSET_NAME) if get_title.blank?
  end

  def regenerate_derivatives!(access_copy:, image_server_cache:)
    destroy_access_copy! if access_copy
    destroy_image_server_cache! if image_server_cache
    self.perform_derivative_processing = true
    self.save
  end

  def destroy_access_copy!
    access_copy_location_uri = location_uri_for_resource('access')
    if access_copy_location_uri.present?
      access_copy_storage_object = Hyacinth::Storage.storage_object_for(access_copy_location_uri)
      access_copy_storage_object.delete!
    end
    if @fedora_object.datastreams['access']
      @fedora_object.datastreams['access'].delete
    end
  end

  def destroy_image_server_cache!
    RestClient.delete(
      "#{IMAGE_SERVER_CONFIG[:url]}/api/v1/resources/#{self.pid}",
      Authorization: "Bearer #{IMAGE_SERVER_CONFIG[:token]}"
    )
  end

  # def generate_derivatives(delete_existing_derivatives = false)
  #   credentials = ActionController::HttpAuthentication::Token.encode_credentials(IMAGE_SERVER_CONFIG[:remote_request_api_key])
  #   resource_url = IMAGE_SERVER_CONFIG[:url] + "/resources/#{pid}"
  #   # Destroy old derivatives if requested
  #   destroy_response = JSON(RestClient.delete(resource_url, Authorization: credentials)) if delete_existing_derivatives
  #   # Queue creation of new derivatives
  #   queue_response = JSON(RestClient.put(resource_url, {}, { Authorization: credentials }))
  #   queue_response['success'].to_s == 'true' && (!delete_existing_derivatives || destroy_response['success'].to_s == 'true')
  # rescue Errno::ECONNREFUSED, RestClient::InternalServerError, SocketError, RestClient::NotFound, RestClient::Unauthorized
  #   Hyacinth::Utils::Logger.logger.error("Tried to regenerate derivatives for #{pid}, but could not connect to image server at: #{IMAGE_SERVER_CONFIG[:url]}")
  #   false
  # end

  # def regenerate_image_server_cached_properties!
  #   credentials = ActionController::HttpAuthentication::Token.encode_credentials(IMAGE_SERVER_CONFIG[:remote_request_api_key])
  #   response = JSON(RestClient.delete(IMAGE_SERVER_CONFIG[:url] + "/resources/#{pid}/destroy_cachable_properties", Authorization: credentials))
  #   response['success'].to_s == 'true'
  # rescue Errno::ECONNREFUSED, RestClient::InternalServerError, SocketError, RestClient::NotFound, RestClient::Unauthorized
  #   Hyacinth::Utils::Logger.logger.error("Tried to regenerate cached image properties for #{pid}, but could not connect to image server at: #{IMAGE_SERVER_CONFIG[:url]}")
  #   false
  # end

  def save_datastreams
    super
    save_synchronized_transcript_datastream
    save_chapters_datastream
    save_transcript_datastream
    save_captions_datastream do |new_content, content_changed|
      # companion_file_path is derived from access copy path since these files need to be next to each other.
      # companion_file_path is the access copy path with the original extension replaced with "vtt".

      access_copy_storage_object = Hyacinth::Storage.storage_object_for(location_uri_for_resource('access'))

      if access_copy_storage_object.is_a?(Hyacinth::Storage::FileObject)
        local_access_path = access_copy_storage_object.path
        next if local_access_path.nil? # skip writing out vtt file if there is no access file to place it next to
        companion_file_path = local_access_path[0..local_access_path.rindex('.')] + 'vtt'
        if content_changed || !File.exist?(companion_file_path)
          open(companion_file_path, 'wb') { |io| io.write(new_content) }
        end
      else
        Rails.logger.error(
          "Skipping save of local storage caption companion file for Asset with UUID #{self.uuid} because "\
          " the access copy is not a local file.  This companion file feature is not implemented for non-local files.")
      end
    end
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
    write_update_captions_file_if_changed!
    write_update_index_document_file_if_changed!
    write_update_synchronized_transcript_file_if_changed!
  end

  def write_update_captions_file_if_changed!
    if captions_changed?
      IO.write(self.captions_location, self.captions)
    end
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

  def write_update_synchronized_transcript_file_if_changed!
    if synchronized_transcript_changed?
      IO.write(self.synchronized_transcript_location, self.synchronized_transcript)
    end
  end

  def audio_moving_image?
    AMI_DC_TYPES.include?(self.dc_type || BestType.dc_type.for_file_name(self.original_filename))
  end

  def still_image?
    IMAGE_DC_TYPES.include?(self.dc_type || BestType.dc_type.for_file_name(self.original_filename))
  end

  def player_mime_type
    if HYACINTH.fetch(:media_streaming, {})['wowza'].present?
      'application/x-mpegURL'
    else
      'video/mp4'
    end
  end

  def player_url(client_ip = nil)
    return nil if location_uri_for_resource('access').blank?

    # if no media_streaming config is present for wowza, always default to progressive download for the player URL
    return '/digital_objects/' + self.pid + '/download?resource_name=access' unless HYACINTH.fetch(:media_streaming, {})['wowza'].present?

    # use the media streaming config. only wowza is currently supported as a streaming source.
    # TODO: This is unreachable code
    raise 'Unsupported media_streaming config: ' + HYACINTH[:media_streaming].inspect unless HYACINTH[:media_streaming]['wowza'].present?

    access_copy_storage_object = Hyacinth::Storage.storage_object_for(location_uri_for_resource('access'))
    unless access_copy_storage_object.is_a?(Hyacinth::Storage::FileObject)
      Rails.logger.error("Cannot generate a Wowza player url for a non-local file. Asset UUID: #{self.uuid}")
      return nil
    end

    local_access_path = access_copy_storage_object.path

    wowza_config = HYACINTH[:media_streaming]['wowza']
    Wowza::SecureToken::Params.new({
      stream: wowza_config['application'] + '/_definst_/' + (local_access_path.downcase.index('.mp3') ? 'mp3:' : 'mp4:') + local_access_path.gsub(/^\//, ''),
      secret: wowza_config['shared_secret'],
      client_ip: client_ip,
      starttime: Time.now.to_i,
      endtime: Time.now.to_i + wowza_config['token_lifetime'].to_i,
      prefix: wowza_config['token_prefix']
    }).to_url_with_token_hash(wowza_config['host'], wowza_config['ssl_port'], 'hls-ssl')
  end

  def pcdm_type
    BestType.pcdm_type.for_file_name(location_for_resource('main'))
  end

  def to_solr
    doc = super
    doc['original_filename_si'] = original_filename
    doc['original_file_path_si'] = original_file_path

    doc['resource_main_location_si'] = location_for_resource('main')
    doc['resource_service_location_si'] = location_for_resource('service')
    doc['resource_access_location_si'] = location_for_resource('access')
    doc['resource_poster_location_si'] = location_for_resource('poster')

    doc['resource_main_size_in_bytes_lsi'] = file_size_for_resource('main')
    doc['resource_service_size_in_bytes_lsi'] = file_size_for_resource('service')
    doc['resource_access_size_in_bytes_lsi'] = file_size_for_resource('access')
    doc['resource_poster_size_in_bytes_lsi'] = file_size_for_resource('poster')

    # doc['file_size_in_bytes_ltsi'] = file_size_in_bytes&.to_i
    # doc['service_copy_file_size_in_bytes_ltsi'] = service_copy_file_size_in_bytes&.to_i
    # doc['access_copy_file_size_in_bytes_ltsi'] = access_copy_file_size_in_bytes&.to_i
    # doc['poster_file_size_in_bytes_ltsi'] = poster_file_size_in_bytes&.to_i

    doc
  end

  # JSON representation
  def as_json(options = {})
    json = super(options)

    json['asset_data'] = {
      # filesystem_location: location_for_resource('main'), # TODO: remove in favor of newly added fields
      checksum: checksum, # TODO: nest this under 'main' resource and remove in favor of newly added fields
      # file_size_in_bytes: file_size_in_bytes, # TODO: remove in favor of newly added fields
      original_filename: original_filename,
      original_file_path: original_file_path,
      # access_copy_location: location_for_resource('access'), # TODO: remove in favor of newly added fields
      # access_copy_file_size_in_bytes: access_copy_file_size_in_bytes, # TODO: remove in favor of newly added fields
      # poster_location: location_for_resource('poster'), # TODO: remove in favor of newly added fields
      # poster_file_size_in_bytes: poster_file_size_in_bytes, # TODO: remove in favor of newly added fields
      # service_copy_location: location_for_resource('service'), # TODO: remove in favor of newly added fields
      # service_copy_file_size_in_bytes: service_copy_file_size_in_bytes, # TODO: remove in favor of newly added fields

      # TODO: After updating above fields, might need to update to_solr logic to extract resource locations and size info

      # New fields (which will eventually replace some of the above ones)
      # TODO: Maybe nest these under a 'resources' key, and then have keys for each resource name under that?
      #       That might be the preferred future structure.
      resource_main_location: location_for_resource('main'),
      resource_main_file_size_in_bytes: file_size_for_resource('main'),
      resource_service_location: location_for_resource('service'),
      resource_service_file_size_in_bytes: file_size_for_resource('service'),
      resource_access_location: location_for_resource('access'),
      resource_access_file_size_in_bytes: file_size_for_resource('access'),
      resource_poster_location: location_for_resource('poster'),
      resource_poster_file_size_in_bytes: file_size_for_resource('poster'),
    }

    json['restrictions'] ||= {}
    json['restrictions']['restricted_size_image'] = restricted_size_image
    json['restrictions']['restricted_onsite'] = restricted_onsite
    json['featured_region'] = self.featured_region

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
