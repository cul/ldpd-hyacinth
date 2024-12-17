class Hyacinth::Utils::UriUtils
  # Converts a file path to a location URI value
  def self.file_path_to_location_uri(path)
    raise ArgumentError, "Given path must be absolute.  Must start with a slash: #{path}" unless path.start_with?('/')
    'file://' + Addressable::URI.encode(path).gsub('&', '%26').gsub('#', '%23')
  end

  def self.location_uri_to_file_path(location_uri)
    # NOTE: Although I'd like to assume that all file URIs start with 'file:///', some older ones will start with 'file:/'.
    raise ArgumentError, "Not a valid file URI: #{location_uri}" unless location_uri.start_with?('file:/')
    Addressable::URI.unencode(Addressable::URI.parse(location_uri).path)
  end
end
