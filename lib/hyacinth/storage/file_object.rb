# frozen_string_literal: true

class Hyacinth::Storage::FileObject < Hyacinth::Storage::AbstractObject
  FILE_READ_CHUNK_SIZE = 5.megabytes
  attr_reader :path

  def initialize(location_uri)
    super(location_uri)
    @path = URI(location_uri).path
    puts "Initialize with location_uri: #{location_uri} and path: #{@path}"
  end

  def exist?
    File.exist?(self.path)
  end

  def filename
    File.basename(self.path)
  end

  def size
    raise "Path is: #{path}"
    File.size(self.path)
  end

  def content_type
    BestType.mime_type.for_file_name(self.path)
  end

  def read
    File.open(self.path, 'rb') do |file|
      buffer = String.new
      while file.read(FILE_READ_CHUNK_SIZE, buffer) != nil
        yield buffer
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
        buff = String.new
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
      raise "Error during file copy.  Copied file checksum (#{destination_file_sha256_hexdigest}) did not match "\
            "source file checksum (#{source_file_sha256_hexdigest}).  Please retry your file import."
    end

    source_file_sha256_hexdigest
  end
end
