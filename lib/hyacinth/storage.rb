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

  # Generates a path based on the given parameters.
  # @param uuid [String] A DigitalObject uuid.
  # @param project [Project] A project.
  # @param original_filename [String] The extension from this file is used as the extension in the generated path.
  # @resource_type [String] A resource type like 'main' or 'service'
  def self.generate_location_uri_for(uuid, project, file_extension, resource_type)
    raise "Unsupported resource_type: #{resource_type}" unless DigitalObject::Asset::VALID_RESOURCE_TYPES.include?(resource_type)

    scheme = project.default_storage_type
    path_pieces = []

    case scheme
    when FILE_SCHEME
      path_pieces << HYACINTH[:default_resource_storage_locations][resource_type.to_sym][:file][:base]
    when S3_SCHEME
      path_pieces << HYACINTH[:default_resource_storage_locations][resource_type.to_sym][:cloud][:base]
    else
      raise ArgumentError, "Unsupported scheme: #{scheme}"
    end

    path_pieces << Hyacinth::Utils::PathUtils.relative_resource_file_path_for_uuid(
      uuid,
      project,
      "-#{resource_type}",
      file_extension
    )

    File.join(*path_pieces)
  end
end
