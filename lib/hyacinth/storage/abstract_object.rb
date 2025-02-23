# frozen_string_literal: true

# This is an abstract class that defines the storage interface.
module Hyacinth::Storage
  class AbstractObject
    attr_reader :scheme, :location_uri

    def initialize(location_uri)
      @location_uri = location_uri
      @scheme = URI(location_uri).scheme

      if self.class == Hyacinth::Storage::AbstractObject
        raise NotImplementedError, "The #{Hyacinth::Storage::AbstractObject.name} class cannot be instantiated.  "\
              'You can only instantiate subclasses like #{Hyacinth::Storage::FileObject}'
      end
    end

    def exist?; raise NotImplementedError; end
    def filename; raise NotImplementedError; end
    def size; raise NotImplementedError; end
    def content_type; raise NotImplementedError; end
    def read(&block); raise NotImplementedError; end
    # Copies the file at source_file_path to storage and returns a SHA256 hexdigest checksum of the file content.
    def write(source_file_path); raise NotImplementedError; end
  end
end
