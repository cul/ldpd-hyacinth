class Hyacinth::Utils::PathUtils
  def self.uuid_pairtree(uuid)
    # uuid format: "cc092507-6baf-4c81-9cba-ea97cc0b30f2"
    # equivalent pairtree format /cc/09/25/07/
    # NOTE: This will result in the creation of a maximum of 4,228,250,625 pairtree intermediate directories (255^4).
    # [uuid[0, 2], uuid[2, 2], uuid[4, 2], uuid[6, 2]]

    # Rather than going four levels deep in the code above, we're going to go six directory levels deep to maintain
    # compatibility with an earlier version of Hyacinth.  We probably don't need that many levels, and it creates
    # a lot of extra intermediate directories, but compatibility is important.
    # Later on, if we switch to four directory levels deep, we can write a script to move files around appropriately.

    # uuid format: "cc092507-6baf-4c81-9cba-ea97cc0b30f2"
    # equivalent pairtree format /cc/09/25/07/6b/af/
    # NOTE: This will result in the creation of a maximum of 274,941,996,890,625
    # pairtree intermediate directories (255^6).
    [uuid[0, 2], uuid[2, 2], uuid[4, 2], uuid[6, 2], uuid[9, 2], uuid[11, 2]]
  end

  def self.relative_resource_file_path_for_uuid(uuid, suffix, extension, mkdir: false)
    # Clean the extension so it only contains periods, letters a-z and A-Z, and numbers
    clean_extension = extension.downcase.gsub(/[^\.a-z0-9]/, '')
    # Remove any leading period (in case the caller supplied a period)
    clean_extension = clean_extension.sub(/^\./, '')
    filename = "#{uuid}#{suffix}.#{clean_extension}"

    File.join(relative_resource_directory_path_for_uuid(uuid), filename)
  end

  def self.relative_resource_directory_path_for_uuid(uuid)
    File.join(
      uuid_pairtree(uuid),
      uuid
    )
  end

  def self.data_file_path_for_uuid(uuid)
    File.join(data_directory_path_for_uuid(uuid), uuid + '.json')
  end

  def self.data_directory_path_for_uuid(uuid)
    File.join(HYACINTH[:digital_object_data_directory], uuid_pairtree(uuid), uuid)
  end
end
