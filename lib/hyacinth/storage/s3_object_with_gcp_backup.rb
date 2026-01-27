# frozen_string_literal: true

# NOTE: This class isn't currently being used, but we might use it later.
class Hyacinth::Storage::S3ObjectWithGcpBackup < Hyacinth::Storage::S3Object
  def gcp_bucket
    @gcp_bucket ||= GCP_STORAGE_CLIENT.bucket(self.bucket_name)
  end

  def gcp_file(reload: false)
    @gcp_file = nil if reload
    @gcp_file ||= self.gcp_bucket.file(self.key)
  end

  def exist?
    aws_copy_exists = super
    # NOTE: Bucket#file returns nil if file is not found
    gcp_copy_exists = gcp_file(reload: true)&.exists?
    Rails.logger.error "AWS copy exists but GCP copy does not for: #{self.key}" if aws_copy_exists && !gcp_copy_exists
    aws_copy_exists # Since the AWS copy is the primary copy, this method is the primary indicator of existence
  end

  def write(source_file_path)
    source_file_sha256_hexdigest = super(source_file_path)

    Retriable.retriable(on: [Google::Cloud::UnavailableError], tries: 3, base_interval: 5) do
      self.gcp_bucket.create_file(
        source_file_path, self.key,
        content_type: BestType.mime_type.for_file_name(source_file_path),
        crc32c: checksum = Digest::CRC32c.file(source_file_path).base64digest,
        metadata: {
          "checksum-sha256-hex" => source_file_sha256_hexdigest
        }
      )
    end

    source_file_sha256_hexdigest
  rescue Google::Cloud::UnavailableError
    raise Hyacinth::Exceptions::FileImportError, "Error during file upload. Unable to reach Google Cloud."
  end

  # Deletes the object in the S3 and GCP buckets.  Warning: This action is irreversible.  Be very careful when using this.
  def delete!
    super # delete AWS copy
    if gcp_file(reload: true)&.exists? # delete GCP copy
      Rails.logger.info "Deleted GCP object (bucket=#{self.bucket_name}, key=#{self.key})"
      gcp_file.delete
    end
  end
end
