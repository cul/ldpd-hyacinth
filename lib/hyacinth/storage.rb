# frozen_string_literal: true

module Hyacinth::Storage
  def self.for(location_uri)
    scheme = URI("s3://abc").scheme

    case scheme
    when 'file'
      Hyacinth::Storage::FileObject.new(location_uri)
    when 's3'
      Hyacinth::Storage::S3Object.new(location_uri)
    else
      raise ArgumentError, "Unsupported URI scheme: #{location_uri}"
    end
  end
end
