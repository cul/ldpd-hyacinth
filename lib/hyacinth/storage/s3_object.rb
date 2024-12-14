# frozen_string_literal: true

class Hyacinth::Storage::S3Object < Hyacinth::Storage::AbstractObject
  DEFAULT_MULTIPART_THRESHOLD = 50.megabytes

  attr_reader :bucket_name, :key

  def initialize(location_uri)
    super(location_uri)

    uri = URI(location_uri)
    @bucket_name = uri.host
    @key = uri.path.gsub(/^\//, '') # Remove leading slash if present
  end

  def s3_object
    @s3_object ||= Aws::S3::Object.new(self.bucket_name, self.key, { client: S3_CLIENT })
  end

  def exist?
    self.s3_object.exists?
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
  end

  def write(source_file_path)
    # Calculate checksum for source file
    source_file_sha256_hexdigest = Digest::SHA256.file(source_file_path).hexdigest

    # Perform upload
    s3_location = "#{self.s3_object.bucket_name}/#{self.s3_object.key}"
    Rails.logger.debug("Uploading file to S3 at location: #{s3_location}")

    # This object should NOT already exist.  If it does, that's a problem and we should raise an error.
    raise FileOverwriteError, "Cancelling S3 write operation because a file already exists at: #{s3_location}" if self.s3_object.exists?

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

    return if upload_result

    raise FileImportError,
          "Error during file upload. Did not receive confirmation from AWS."
  end
end
