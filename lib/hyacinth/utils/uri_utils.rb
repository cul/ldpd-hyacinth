class Hyacinth::Utils::UriUtils
  # Converts a file path to a location URI value
  def self.file_path_to_location_uri(path)
    raise ArgumentError, "Given path must be absolute.  Must start with a slash: #{path}" unless path.start_with?('/')

    "file://#{Addressable::URI.encode(path).gsub('&', '%26').gsub('#', '%23')}"
  end

  # Converts a file URI to a file path
  def self.location_uri_to_file_path(location_uri)
    parsed_uri = Addressable::URI.parse(location_uri)
    uri_scheme = parsed_uri.scheme
    unencoded_uri_path = Addressable::URI.unencode(parsed_uri.path)

    case uri_scheme
    when 'file'
      return unencoded_uri_path
    end

    raise ArgumentError, "Unhandled URI: #{location_uri}"
  end
end
