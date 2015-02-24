require 'addressable/uri'

class DigitalObject::Asset < DigitalObject::Base

  VALID_DC_TYPES = ['Unknown', 'Dataset', 'MovingImage', 'Software', 'Sound', 'StillImage', 'Text']
  DIGITAL_OBJECT_TYPE_STRING_KEY = 'asset'

  def initialize(*args)
    super(*args)

    # Default to 'Unknown' dc_type.  We expect other code to properly set this
    # once the asset file type is known, but this avoid a blank value for dc_type
    # and helps to identify errors when a dc_type has been improperly set.
    self.dc_type ||= VALID_DC_TYPES.first
  end

  # Called during save, after all validations have passed
  def get_new_fedora_object

    pid = self.next_pid
    generic_resource = GenericResource.new(:pid => pid)

    generic_resource.datastreams["DC"].dc_identifier = [pid]

    return generic_resource
  end

  def valid?
    super # Always run shared parent class validation

    ## Assets must have at least one parent Item
    # Update: This is not necessarily true.
    #if self.state == 'A' && parent_digital_object_pids.length == 0
    #  @errors.add(:parent_digital_object_pids, 'An Asset must have at least one parent Item')
    #end

    # Assets can only be children of DigitalObject::Item objects
    parent_digital_object_pids.each {|parent_digital_object_pid|
      parent_digital_object = DigitalObject::Base.find(parent_digital_object_pid)
      unless parent_digital_object.is_a?(DigitalObject::Item)
        @errors.add(:parent_digital_object_pids, 'Assets are only allowed to be children of Items.  Found parent of type: ' + parent_digital_object.digital_object_type.display_label)
      end
    }

    return @errors.blank?
  end

  def set_file_and_file_size_and_original_file_path_and_calculate_checksum(path_to_file, original_file_path, file_size)

    # "controlGroup => 'E'" below means "External Referenced Content" -- as in, a file that's referenced by Fedora but not stored internally
    ds_location = Addressable::URI.encode('file:' + path_to_file) # Note: This will result in paths like "file:/something%20great/here.txt"  We DO NOT want a double slash at the beginnings of these paths.
    original_filename = File.basename(path_to_file)
    content_ds = @fedora_object.create_datastream(ActiveFedora::Datastream, 'content', :controlGroup => 'E', :mimeType => DigitalObject::Asset.filename_to_mime_type(original_filename), :dsLabel => original_filename, :versionable => true)
    content_ds.dsLocation = ds_location
    @fedora_object.datastreams["DC"].dc_source = ds_location

    # Calculate checksum for file, using 4096-byte buffered approach to save memory for large files
    sha256 = Digest::SHA256.new
    File.open(path_to_file, 'r') do |file|
      while buff = file.read(4096)
        sha256.update(buff)
      end
    end

    content_ds.checksum = sha256.hexdigest
    content_ds.checksumType = 'SHA-256'

    @fedora_object.add_datastream(content_ds)

    # Add size property to content datastream using :extent predicate
    @fedora_object.rels_int.add_relationship(content_ds, :extent, file_size.to_s, true) # last param *true* means that this is a literal value rather than a relationship

    # Add original_filename property to content datastream using <info:fedora/fedora-system:def/model#downloadFilename> relationship
    @fedora_object.rels_int.add_relationship(content_ds, 'info:fedora/fedora-system:def/model#downloadFilename', original_filename, true) # last param *true* means that this is a literal value rather than a relationship

    # TODO: Eventually set true orientations, but we're setting everything as upright ('top-left') for now, just to have a value
    @fedora_object.rels_int.add_relationship(content_ds, :orientation, 'top-left', true) # last param *true* means that this is a literal value rather than a relationship

    set_original_file_path(original_file_path) # This also updates the 'content' datastream label

  end

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
