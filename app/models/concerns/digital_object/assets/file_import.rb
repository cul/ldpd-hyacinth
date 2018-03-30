module DigitalObject::Assets::FileImport
  extend ActiveSupport::Concern

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
    set_title('', original_filename) if get_title == DigitalObject::Asset::DEFAULT_ASSET_NAME

    # Create datastream for file

    # "controlGroup => 'E'" below means "External Referenced Content" -- as in, a file that's referenced by Fedora but not stored in Fedora's internal data store

    # Line below will create paths like "file:/this%23_and_%26_also_something%20great/here.txt"
    # We DO NOT want a double slash at the beginnings of these paths.
    # We need to manually escape ampersands (%26) and pound signs (%23) because these are not always handled by Addressable::URI.encode()
    ds_location = Addressable::URI.encode('file:' + path_to_final_save_location).gsub('&', '%26').gsub('#', '%23')
    content_ds = @fedora_object.create_datastream(ActiveFedora::Datastream, 'content', controlGroup: 'E', mimeType: BestType.mime_type.for_file_name(original_filename), dsLabel: original_filename, versionable: true)
    content_ds.dsLocation = ds_location
    @fedora_object.datastreams["DC"].dc_source = path_to_final_save_location
    @fedora_object.add_datastream(content_ds)

    # Add checksum property to content datastream using :has_message_digest predicate
    @fedora_object.rels_int.add_relationship(content_ds, :has_message_digest, "urn:sha256:#{import_file_sha256_hexdigest}")

    # Add size property to content datastream using :extent predicate
    @fedora_object.rels_int.add_relationship(content_ds, :extent, import_file_size.to_s, true) # last param *true* means that this is a literal value rather than a relationship

    # Add original filename property to content datastream using <info:fedora/fedora-system:def/model#downloadFilename> relationship
    @fedora_object.rels_int.add_relationship(content_ds, 'info:fedora/fedora-system:def/model#downloadFilename', original_filename, true) # last param *true* means that this is a literal value rather than a relationship

    # Assume top-left orientation at upload time. This can be corrected later in the app.
    @fedora_object.rels_int.add_relationship(content_ds, :orientation, 'top-left', true) # last param *true* means that this is a literal value rather than a relationship

    self.original_file_path = (@import_file_original_file_path || @import_file_import_path) # This also updates the 'content' datastream label
  end

  def copy_and_verify_file(import_file)
    if [DigitalObject::Asset::IMPORT_TYPE_INTERNAL, DigitalObject::Asset::IMPORT_TYPE_POST_DATA].include? @import_file_import_type
      return copy_and_verify_internal_file(import_file)
    elsif @import_file_import_type == DigitalObject::Asset::IMPORT_TYPE_EXTERNAL
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
end
