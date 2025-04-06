# frozen_string_literal: true

module Hyacinth::Storage
  FILE_SCHEME = 'file' # file://
  S3_SCHEME = 's3' # s3://
  STORAGE_SCHEMES = [FILE_SCHEME, S3_SCHEME]

  def self.storage_object_for(location_uri)
    scheme = URI(location_uri).scheme

    case scheme
    when FILE_SCHEME
      Hyacinth::Storage::FileObject.new(location_uri)
    when S3_SCHEME
      Hyacinth::Storage::S3ObjectWithGcpBackup.new(location_uri)
    else
      raise ArgumentError, "Unsupported URI scheme: #{location_uri}"
    end
  end

  def self.generate_location_uri_for(pid, project, local_file_path)
    scheme = project.default_storage_type

    case scheme
    when FILE_SCHEME
      "#{scheme}://" +
      File.join(
        HYACINTH[:default_asset_home],
        Hyacinth::Utils::PathUtils.relative_path_to_asset_file(pid, project, File.basename(local_file_path))
      )
    when S3_SCHEME
      "#{scheme}://" +
      File.join(
        HYACINTH[:default_asset_home_bucket_name],
        HYACINTH[:default_asset_home_bucket_path_prefix],
        Hyacinth::Utils::PathUtils.relative_path_to_asset_file(pid, project, File.basename(local_file_path))
      )
    else
      raise ArgumentError, "Unsupported scheme: #{scheme}"
    end
  end
end
