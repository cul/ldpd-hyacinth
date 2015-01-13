class Hyacinth::Utils::PathUtils

  def self.path_to_asset_file(pid, original_filename)
    pid_hexdigest = Digest::SHA256.hexdigest(pid)
    extension_with_dot = File.extname(original_filename)
    File.join(HYACINTH['default_asset_home'], pid_hexdigest[0,2], pid_hexdigest[2,2], pid_hexdigest[4,2], pid_hexdigest[6,2], pid_hexdigest + extension_with_dot)
  end

end
