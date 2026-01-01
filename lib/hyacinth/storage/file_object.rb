# frozen_string_literal: true

class Hyacinth::Storage::FileObject < Hyacinth::Storage::AbstractObject
  FILE_READ_CHUNK_SIZE = 5.megabytes
  attr_reader :path

  def initialize(location_uri)
    super(location_uri)
    # Note: Need to decode location URI in order to convert %20 to space,
    # so that Ruby file operation methods can resolve paths.
    @path = Addressable::URI.unencode(URI(location_uri).path)
  end

  def exist?
    File.exist?(self.path)
  end

  def filename
    File.basename(self.path)
  end

  def size
    File.size(self.path)
  end

  def content_type
    BestType.mime_type.for_file_name(self.path)
  end

  def read(&block)
    read_range(0, &block)
  end

  def read_range(from, to = nil, &block)
    File.open(self.path, 'rb') do |file|
      file.seek(from) # Skip ahead and start reading at the `from` byte position

      read_position = from

      buffer = +''
      loop do
        size_of_next_chunk = to.nil? ? FILE_READ_CHUNK_SIZE : [FILE_READ_CHUNK_SIZE, (to - read_position + 1)].min
        break if size_of_next_chunk.zero?
        file.read(size_of_next_chunk, buffer)
        yield buffer
        read_position += size_of_next_chunk
      end
    end
  end

  def write(source_file_path)
    # Recursively make directories to the target path
    FileUtils.mkdir_p(File.dirname(self.path))

    # Generate checksum DURING the write operation so that we only need to read the source file once.
    source_file_sha256 = Digest::SHA256.new
    File.open(source_file_path, 'rb') do |source_file| # 'r' == read, 'b' == binary mode
      File.open(self.path, 'wb') do |new_file| # 'w' == write, 'b' == binary mode
        buff = +''
        while source_file.read(4096, buff)
          source_file_sha256.update(buff)
          new_file.write(buff)
        end
      end
    end
    source_file_sha256_hexdigest = source_file_sha256.hexdigest

    # Verify the file after copy
    destination_file_sha256_hexdigest = Digest::SHA256.file(self.path).hexdigest

    if destination_file_sha256_hexdigest != source_file_sha256_hexdigest
      FileUtils.rm(self.path) # Delete new file because it is invalid
      raise Hyacinth::Exceptions::FileImportError,
            "Error during file copy.  Copied file checksum (#{destination_file_sha256_hexdigest}) did not match "\
            "source file checksum (#{source_file_sha256_hexdigest}).  Please retry your file import."
    end

    source_file_sha256_hexdigest
  end

  def delete!
    File.delete(self.path)
  end
end
