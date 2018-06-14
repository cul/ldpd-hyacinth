class Hyacinth::Utils::PathUtils
  def self.path_to_asset_file(pid, project, original_filename)
    pid_hexdigest = Digest::SHA256.hexdigest(pid)
    File.join(project.asset_directory, *pairtree(pid_hexdigest, original_filename))
  end

  def self.pairtree(digest, original_filename)
    stored_filename = digest + File.extname(original_filename)
    [digest[0, 2], digest[2, 2], digest[4, 2], digest[6, 2], stored_filename]
  end

  def self.uuid_pairtree(uuid)
    # uuid format: "cc092507-6baf-4c81-9cba-ea97cc0b30f2"
    [uuid[0, 2], uuid[2, 2], uuid[4, 2], uuid[6, 2], uuid[9, 2], uuid[11, 2]]
  end

  def self.data_file_path_for_uuid(uuid)
    File.join(data_directory_path_for_uuid(uuid), uuid + '.json')
  end

  def self.data_directory_path_for_uuid(uuid)
    File.join(HYACINTH['digital_object_data_directory'], uuid_pairtree(uuid), uuid)
  end
end
