module DigitalObject::Assets::FileImport
  extend ActiveSupport::Concern

  VALID_FILE_URI_REGEX = /^file:(\/{2})*\/{1}[^\/].+$/

  def process_import_file_data_if_present
    import_data_for_main_resource = @import_file_data[DigitalObject::Asset::MAIN_RESOURCE_NAME]
    import_data_for_service_resource = @import_file_data[DigitalObject::Asset::SERVICE_RESOURCE_NAME]
    # If import data is present for an access resource, set import_type to internal
    import_data_for_access_resource = @import_file_data[DigitalObject::Asset::ACCESS_RESOURCE_NAME]&.merge({ 'import_type' => DigitalObject::Asset::IMPORT_TYPE_INTERNAL })
    # If import data is present for a poster resource, set import_type to internal
    import_data_for_poster_resource = @import_file_data[DigitalObject::Asset::POSTER_RESOURCE_NAME]&.merge({ 'import_type' => DigitalObject::Asset::IMPORT_TYPE_INTERNAL })

    [
      import_data_for_main_resource,
      import_data_for_service_resource,
      import_data_for_access_resource,
      import_data_for_poster_resource
    ].each do |import_data_for_resource|
      normalize_import_type_and_import_location!(import_data_for_resource) if import_data_for_resource.present?
    end

    # TODO: Later on, see if we can make the four methods below more similar in implementation.  Maybe similar enough to be one shared method?
    # This is probably something that we'll need to do after decoupling Hyacinth from Fedora more, since right now
    # we set different properties on different Fedora datastreams based on the resource type.
    handle_main_file_import(import_data_for_main_resource) if import_data_for_main_resource.present?
    handle_service_copy_import(import_data_for_service_resource) if import_data_for_service_resource.present?
    handle_access_copy_import(import_data_for_access_resource) if import_data_for_access_resource.present?
    handle_poster_import(import_data_for_poster_resource) if import_data_for_poster_resource.present?
  end

  def normalize_import_type_and_import_location!(import_data_for_resource)
    # We only need to make a change if this is an upload directory import type
    return unless import_data_for_resource['import_type'] == DigitalObject::Asset::IMPORT_TYPE_UPLOAD_DIRECTORY

    # If this is an upload directory import, we'll adjust the import file path by prepending the full path
    # to the upload directory and then it can be treated as the same as an internal file import.
    import_data_for_resource['import_location'] = File.join(HYACINTH[:upload_directory], import_data_for_resource['import_location'])
    import_data_for_resource['import_type'] = DigitalObject::Asset::IMPORT_TYPE_INTERNAL
  end

  def perform_import(import_type, import_location, resource_type, allow_overwrite:)
    case import_type
    when DigitalObject::Asset::IMPORT_TYPE_INTERNAL, DigitalObject::Asset::IMPORT_TYPE_POST_DATA
      final_save_location_uri, checksum_hexdigest_uri, import_file_size = handle_internal_import(import_location, resource_type, allow_overwrite: allow_overwrite)
    when DigitalObject::Asset::IMPORT_TYPE_EXTERNAL
      final_save_location_uri, checksum_hexdigest_uri, import_file_size = handle_external_import(import_location)
    else
      raise "Unexpected import_type: #{import_type.inspect}"
    end

    [final_save_location_uri, checksum_hexdigest_uri, import_file_size]
  end

  # Copies the source file to its internal Hyacinth storage destination
  def handle_internal_import(import_location, resource_type, allow_overwrite: false) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    # If import_location is a file URI, then we'll convert it to a regular file path.  This allows us to support
    # either a file URI or an absolute file paths during imports.  Note that we do not support internal imports
    # from other sources like 's3://' at this time.
    import_location = Hyacinth::Utils::UriUtils.location_uri_to_file_path(import_location) if import_location =~ VALID_FILE_URI_REGEX

    unless import_location.start_with?('/') && File.exist?(import_location)
      raise ArgumentError, "Internal imports must refer to a locally-resolvable file.  Cannot find local file: #{import_location}"
    end

    import_file_size = File.size(import_location)
    if import_file_size == 0
      raise Hyacinth::Exceptions::ZeroByteFileError,
            "Cannot import a 0-byte file.  File must contain data.  (#{import_location})"
    end

    final_save_location_uri = Hyacinth::Storage.generate_location_uri_for(
      self.uuid, project, File.extname(import_location), resource_type
    )

    storage_object = Hyacinth::Storage.storage_object_for(final_save_location_uri)

    if !allow_overwrite && storage_object.exist?
      raise 'Could not process new internally-stored file because an existing file was already found at the target '\
            "location and overwriting files is not allowed for the #{resource_type} resource type (#{final_save_location_uri})."
    end

    # If this is a file-based upload, make sure that any recursively generated new directories have group permissions set to 0755.
    FileUtils.mkdir_p(File.dirname(storage_object.path), mode: 0755) if final_save_location_uri.start_with?('file:')

    sha256_hexdigest = storage_object.write(import_location)

    # After writing to an internal location, set appropriate permissions on the
    # file if our HYACINTH configuration specifies that we should do so.
    if final_save_location_uri.start_with?('file:')
      file_config = HYACINTH[:default_resource_storage_locations][resource_type.to_sym][:file]
      apply_permissions_to_local_file(storage_object.path, file_config['group'], file_config['permissions'])
    end

    [storage_object.location_uri, "sha256:#{sha256_hexdigest}", import_file_size]
  end

  def apply_permissions_to_local_file(file_path, group, permissions)
    # Optionally set file's group
    FileUtils.chown(nil, group, file_path) if group.present?
    # Optionally set file's permissions
    FileUtils.chmod(permissions.to_i(8), file_path) if permissions.present?
  end

  # Verifies the existence of the file at the given import_location and retrieves or generates its whole file checksum.
  # For local files, the checksum will be generated.  For S3 files, this method will retrieve the value from S3 object metadata.
  def handle_external_import(import_location)
    # If import_location is a file path, then we'll convert it to a file URI.  This allows us to support
    # either an absolute file file path or a file URI during imports.  We also support S3 URIs.
    import_location_uri = import_location.start_with?('/') ? Hyacinth::Utils::UriUtils.file_path_to_location_uri(import_location) : import_location
    storage_object = Hyacinth::Storage.storage_object_for(import_location_uri)
    raise "External file not found at: #{storage_object.path}" unless storage_object.exist?
    raise Hyacinth::Exceptions::ZeroByteFileError, 'Original file file size is 0 bytes. File must contain data.' if storage_object.size == 0

    case storage_object
    when Hyacinth::Storage::FileObject
      # This is a file on the local filesystem.  We will need to calculate its checksum.
      checksum_hexdigest_uri = "sha256:#{Digest::SHA256.file(storage_object.path).hexdigest}"
    when Hyacinth::Storage::S3Object
      # This is a file in S3.  We will retrieve its checksum from metadata.
      checksum_hexdigest_uri = storage_object.checksum_uri_from_metadata
    else
      raise ArgumentError, "Unsupported URI scheme: #{location_uri}"
    end
    [storage_object.location_uri, checksum_hexdigest_uri, storage_object.size]
  end

  def copy_file_and_apply_access_copy_permissions(source_path, dest_path)
    FileUtils.cp(source_path, dest_path)
    # Optionally set file's group
    FileUtils.chown(nil, HYACINTH[:access_copy_file_group], dest_path) if HYACINTH[:access_copy_file_group].present?
    # Optionally set file's permissions
    FileUtils.chmod(HYACINTH[:access_copy_file_permissions].to_i(8), dest_path) if HYACINTH[:access_copy_file_permissions].present?
  end

  def assign_properties_after_main_file_import(
    import_location, original_file_path, final_save_location_uri, checksum_hexdigest_uri, import_file_size
  )
    original_filename = File.basename(original_file_path || import_location)

    # If the title of this Asset is the DEFAULT_ASSET_NAME, use the original filename as the title.
    # If the title of this Asset is NOT equal to DEFAULT_ASSET_NAME, that means that a title was
    # manually set by the user in this Asset's digital_object_data.
    set_title('', original_filename) if get_title == DigitalObject::Asset::DEFAULT_ASSET_NAME

    # Create 'content' datastream for file, using `controlGroup: 'E'` to indicate "External Referenced Content".
    # That means this file is referenced by Fedora but not stored in Fedora's internal data store.
    content_ds = @fedora_object.create_datastream(
      ActiveFedora::Datastream, 'content', controlGroup: 'E',
      mimeType: BestType.mime_type.for_file_name(original_filename),
      dsLabel: original_filename, versionable: true
    )
    content_ds.dsLocation = final_save_location_uri
    @fedora_object.add_datastream(content_ds)

    @fedora_object.datastreams["DC"].dc_source = final_save_location_uri

    # Add checksum property to content datastream using :has_message_digest predicate
    @fedora_object.rels_int.add_relationship(content_ds, :has_message_digest, "urn:#{checksum_hexdigest_uri}") unless checksum_hexdigest_uri.nil?

    # Add size property to content datastream using :extent predicate
    @fedora_object.rels_int.add_relationship(content_ds, :extent, import_file_size.to_s, true)

    # Add original filename property to content datastream using <info:fedora/fedora-system:def/model#downloadFilename> relationship.
    @fedora_object.rels_int.add_relationship(content_ds, 'info:fedora/fedora-system:def/model#downloadFilename', original_filename, true)

    # Assume 0-degree orientation at upload time. A Hyacinth user can update this later.
    @fedora_object.orientation = 0

    # This also updates the 'content' datastream label
    self.original_file_path = original_file_path || import_location
  end

  def handle_main_file_import(import_data_for_main_resource)
    import_type = import_data_for_main_resource['import_type']
    import_location = import_data_for_main_resource['import_location']
    original_file_path = import_data_for_main_resource['original_file_path']

    # We don't allow users to set a new main file for an Asset.  An Asset is linked to a specific main file.
    # If a user wants an Asset that references a different location, they need to create a new Asset.
    # Raise an exception if this method is ever run for an object that already has a main resource.
    raise 'Cannot import a new main file that replaces an existing main file.' if self.location_uri_for_resource(DigitalObject::Asset::MAIN_RESOURCE_NAME).present?

    final_save_location_uri, checksum_hexdigest_uri, import_file_size = perform_import(import_type, import_location, DigitalObject::Asset::MAIN_RESOURCE_NAME, allow_overwrite: false)

    assign_properties_after_main_file_import(import_location, original_file_path, final_save_location_uri, checksum_hexdigest_uri, import_file_size)
  end

  def handle_service_copy_import(import_data_for_service_resource)
    import_type = import_data_for_service_resource['import_type']
    import_location = import_data_for_service_resource['import_location']

    return if import_location.blank?
    final_save_location_uri, _checksum_hexdigest_uri, import_file_size = perform_import(import_type, import_location, DigitalObject::Asset::SERVICE_RESOURCE_NAME, allow_overwrite: true)

    service_ds = @fedora_object.create_datastream(
      ActiveFedora::Datastream, 'service', controlGroup: 'E',
      mimeType: BestType.mime_type.for_file_name(final_save_location_uri),
      dsLabel: File.basename(final_save_location_uri), versionable: true
    )
    service_ds.dsLocation = final_save_location_uri
    @fedora_object.add_datastream(service_ds)

    # Store service copy file size on datastream
    @fedora_object.rels_int.add_relationship(service_ds, :extent, import_file_size.to_s, true)
  end

  def handle_access_copy_import(import_data_for_access_resource)
    import_type = import_data_for_access_resource['import_type']
    import_location = import_data_for_access_resource['import_location']

    return if import_location.blank?
    final_save_location_uri, _checksum_hexdigest_uri, import_file_size = perform_import(import_type, import_location, DigitalObject::Asset::ACCESS_RESOURCE_NAME, allow_overwrite: true)

    access_ds = @fedora_object.datastreams['access']
    if access_ds.blank?
      access_ds = @fedora_object.create_datastream(
        ActiveFedora::Datastream, 'access',
        controlGroup: 'E', mimeType: BestType.mime_type.for_file_name(final_save_location_uri),
        dsLabel: File.basename(final_save_location_uri), versionable: true
      )
      access_ds.dsLocation = final_save_location_uri
      @fedora_object.add_datastream(access_ds)
    else
      access_ds.dsLocation = final_save_location_uri
      access_ds.mimeType = BestType.mime_type.for_file_name(final_save_location_uri)
      access_ds.dsLabel = File.basename(final_save_location_uri)
    end

    # Clear old rels_int values if present
    @fedora_object.rels_int.clear_relationship(access_ds, :extent)
    @fedora_object.rels_int.clear_relationship(access_ds, :rdf_type)

    # Set new rels_int values
    @fedora_object.rels_int.add_relationship(access_ds, :extent, import_file_size.to_s, true)

    # TODO: It seems a little strange to describe the access copy as a 'service file', but we've been doing this for
    # a while in Derivativo.  Might as well be consistent until we change this practice everywhere (and confirm that
    # nothing relies on it).
    @fedora_object.rels_int.add_relationship(access_ds, :rdf_type, "http://pcdm.org/use#ServiceFile")
  end

  def handle_poster_import(import_data_for_poster_resource)
    import_type = import_data_for_poster_resource['import_type']
    import_location = import_data_for_poster_resource['import_location']

    return if import_location.blank?
    final_save_location_uri, _checksum_hexdigest_uri, import_file_size = perform_import(import_type, import_location, DigitalObject::Asset::POSTER_RESOURCE_NAME, allow_overwrite: true)

    # Create poster datastream if it doesn't already exist
    poster_ds = @fedora_object.datastreams['poster']
    if poster_ds.blank?
      poster_ds = @fedora_object.create_datastream(
        ActiveFedora::Datastream, 'poster',
        controlGroup: 'E', mimeType: BestType.mime_type.for_file_name(final_save_location_uri),
        dsLabel: File.basename(final_save_location_uri), versionable: true
      )
      poster_ds.dsLocation = final_save_location_uri
      @fedora_object.add_datastream(poster_ds)
    else
      poster_ds.dsLocation = final_save_location_uri
      poster_ds.mimeType = BestType.mime_type.for_file_name(final_save_location_uri)
      poster_ds.dsLabel = File.basename(final_save_location_uri)
    end

    # Clear old rels_int values if present
    @fedora_object.rels_int.clear_relationship(poster_ds, :extent)
    @fedora_object.rels_int.clear_relationship(poster_ds, :rdf_type)

    # Set rels_int values
    @fedora_object.rels_int.add_relationship(poster_ds, :extent, import_file_size.to_s, true)
  end
end
