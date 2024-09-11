# frozen_string_literal: true

class Hyacinth::Storage::S3Object < Hyacinth::Storage::AbstractObject
  attr_reader :bucket_name, :key

  def initialize(location_uri)
    super(location_uri)

    uri = URI(location_uri)
    @bucket_name = uri.host
    @key = uri.path
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
end
