class Hyacinth::Utils::PathUtils
  def self.path_to_asset_file(pid, project, original_filename)
    pid_hexdigest = Digest::SHA256.hexdigest(pid)
    File.join(project.get_asset_directory, *pairtree(pid_hexdigest, original_filename))
  end

  def self.pairtree(digest, original_filename)
    stored_filename = digest + File.extname(original_filename)
    [digest[0, 2], digest[2, 2], digest[4, 2], digest[6, 2], stored_filename]
  end
end
