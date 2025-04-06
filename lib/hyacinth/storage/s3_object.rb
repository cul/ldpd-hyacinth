# frozen_string_literal: true

class Hyacinth::Storage::S3Object < Hyacinth::Storage::AbstractObject
  DEFAULT_MULTIPART_THRESHOLD = 50.megabytes
  CHECKSUM_METADATA_KEY_PATTERN = /checksum-([^-]+)-hex/

  attr_reader :bucket_name, :key

  def initialize(location_uri)
    super(location_uri)

    uri = URI(location_uri)
    @bucket_name = uri.host
    @key = uri.path.gsub(/^\//, '') # Remove leading slash if present
  end

  def s3_object(reload: false)
    @s3_object = nil if reload
    @s3_object ||= Aws::S3::Object.new(self.bucket_name, self.key, { client: S3_CLIENT })
  end

  # Retrieves this object's whole file checksum from the object metadata, if present.
  # If no metadata checksum value is found, returns nil.
  def checksum_uri_from_metadata
    matching_metadata_pair = s3_object.metadata.find { |k, _v| k.match(CHECKSUM_METADATA_KEY_PATTERN) }
    return nil if matching_metadata_pair.nil?
    metadata_key, checksum_value = matching_metadata_pair
    checksum_type = metadata_key.match(CHECKSUM_METADATA_KEY_PATTERN)[1]
    "#{checksum_type}:#{checksum_value}" # NOTE: This is frequently sha256, but is not guaranteed to be sha256.
  end

  def exist?
    self.s3_object(reload: true).exists?
  end

  def filename
    File.basename(self.key)
  end

  def size
    self.s3_object.content_length
  end

  def content_type
    self.s3_object.content_type
  end

  def read
    obj = S3_CLIENT.get_object({ bucket: self.bucket_name, key: self.key }) do |chunk, _headers|
      yield chunk
    end
  end

  def write(source_file_path)
    # Calculate checksum for source file
    source_file_sha256_hexdigest = Digest::SHA256.file(source_file_path).hexdigest

    # Perform upload
    s3_location = "#{self.s3_object.bucket_name}/#{self.s3_object.key}"
    Rails.logger.debug("Uploading file to S3 at location: #{s3_location}")

    # This object should NOT already exist.  If it does, that's a problem and we should raise an error.
    raise Hyacinth::Exceptions::FileOverwriteError, "Cancelling S3 write operation because a file already exists at: #{s3_location}" if self.s3_object.exists?

    upload_result = self.s3_object.upload_file(
      source_file_path,
      {
        # NOTE: Supplying a checksum_algorithm option with value 'CRC32C' will make the AWS SDK
        # automatically calculate a local CRC32C checksum before sending the file to S3 (for both
        # multipart and single part uploads).  The upload will fail if the corresponding checksum
        # calculated by S3 does not match.
        checksum_algorithm: 'CRC32C',
        multipart_threshold: DEFAULT_MULTIPART_THRESHOLD,
        thread_count: 10, # The number of parallel multipart uploads
        content_type: BestType.mime_type.for_file_name(source_file_path),
        metadata: {
          "checksum-sha256-hex" => source_file_sha256_hexdigest
        }
      }
    )

    return source_file_sha256_hexdigest if upload_result

    raise Hyacinth::Exceptions::FileImportError,
          "Error during file upload. Did not receive confirmation from AWS."
  end

  def delete!
    if self.s3_object(reload: true).exists?
      self.s3_object.delete
      Rails.logger.info "Deleted S3 object (bucket=#{self.bucket_name}, key=#{self.key})"
    end
  end
end
