class Hyacinth::Utils::PathUtils
  def self.uuid_pairtree(uuid)
    # uuid format: "cc092507-6baf-4c81-9cba-ea97cc0b30f2"
    # equivalent pairtree format /cc/09/25/07
    # NOTE: This will result in the creation of a maximum of 4,228,250,625 pairtree intermediate directories (255^4).
    [uuid[0, 2], uuid[2, 2], uuid[4, 2], uuid[6, 2]]
  end

  def self.relative_resource_file_path_for_uuid(uuid, project, suffix, extension, mkdir: false)
    # Clean the extension so it only contains periods, letters a-z and A-Z, and numbers
    clean_extension = extension.downcase.gsub(/[^\.a-z0-9]/, '')
    # Remove any leading period (in case the caller supplied a period)
    clean_extension = clean_extension.sub(/^\./, '')
    filename = "#{uuid}#{suffix}.#{clean_extension}"

    File.join(relative_resource_directory_path_for_uuid(uuid, project), filename)
  end

  def self.relative_resource_directory_path_for_uuid(uuid, project)
    File.join(
      project.relative_asset_directory,
      uuid_pairtree(uuid),
      uuid
    )
  end

  # def self.asset_file_pairtree(digest, suffix, extension)
  #   # Clean the extension so it only contains periods, letters a-z and A-Z, and numbers
  #   clean_extension = extension.downcase.gsub(/[^\.a-z0-9]/, '')
  #   # Remove any leading period (in case the caller supplied a period)
  #   clean_extension = clean_extension.sub(/^\./, '')
  #   stored_filename = "#{digest}#{suffix}.#{clean_extension}"
  #   [digest[0, 2], digest[2, 2], digest[4, 2], digest[6, 2], stored_filename]
  # end





  def self.data_file_path_for_uuid(uuid)
    File.join(data_directory_path_for_uuid(uuid), uuid + '.json')
  end

  def self.data_directory_path_for_uuid(uuid)
    File.join(HYACINTH[:digital_object_data_directory], uuid_pairtree(uuid), uuid)
  end

  # def self.access_directory_path_for_uuid(uuid)
  #   File.join(HYACINTH[:access_copy_directory], uuid_pairtree(uuid), uuid)
  # end

  # def self.access_directory_path_for_uuid!(uuid)
  #   dest_dir = access_directory_path_for_uuid(uuid)
  #   # Make sure that any recursively generated new directories have group permissions set to 0775.
  #   # When Derivativo 3 is released and Derivativo 1 is retired, this can change to 0755 permissions.
  #   FileUtils.mkdir_p(dest_dir, mode: 0755)
  #   dest_dir
  # end
end
