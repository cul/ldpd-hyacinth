# frozen_string_literal: true

module DigitalObjectConcerns
  module MetadataStorageSerialization
    extend ActiveSupport::Concern

    METADATA_SERIALIZATION_VERSION = 2

    def delete_from_metadata_storage
      Hyacinth::Config.metadata_storage.delete(self.metadata_location_uri)
    end

    def write_fields_to_metadata_storage
      Hyacinth::Config.metadata_storage.write(self.metadata_location_uri, JSON.generate(self.as_metadata_storage_json))
    end

    def load_fields_from_metadata_storage
      assign_metadata_storage_attributes(JSON.parse(Hyacinth::Config.metadata_storage.read(self.metadata_location_uri)))
    end

    def rollback_metadata_storage
      return unless Hyacinth::Config.metadata_storage.exists?(self.backup_metadata_location_uri)

      Hyacinth::Config.metadata_storage.write(
        self.metadata_location_uri,
        Hyacinth::Config.metadata_storage.read(self.backup_metadata_location_uri)
      )
    end

    def write_metadata_storage_backup
      return unless Hyacinth::Config.metadata_storage.exists?(self.metadata_location_uri)

      Hyacinth::Config.metadata_storage.write(
        self.backup_metadata_location_uri,
        Hyacinth::Config.metadata_storage.read(self.metadata_location_uri)
      )
    end

    def as_metadata_storage_json
      {}.tap do |json_var|
        # Although we don't read the uid from the file, it's good to put in there anyway so we
        # know the associated uid when looking at the metadata file in a standalone context.
        json_var['uid'] = self.uid

        # We write this version number to the file to make future metadata file format updates
        # easier, so we can tell which metadata files have been upgraded and which haven't.
        json_var['serialization_version'] = METADATA_SERIALIZATION_VERSION

        json_var['metadata'] = self.metadata_attributes.each_with_object({}) do |(metadata_attribute_name, type_def), hsh|
          hsh[metadata_attribute_name.to_s] = type_def.to_serialized_form(self.send(metadata_attribute_name))
        end

        json_var['resources'] = self.resource_attribute_names.each_with_object({}) do |resource_attribute_name, hsh|
          resource = resources[resource_attribute_name]
          next if resource.blank?
          hsh[resource_attribute_name.to_s] = resource.to_serialized_form
        end
      end
    end

    private

      def assign_metadata_storage_attributes(json_var)
        (json_var['metadata'] || {}).tap do |serialized_metadata|
          self.metadata_attributes.map do |metadata_attribute_name, type_def|
            val = type_def.from_serialized_form(serialized_metadata[metadata_attribute_name.to_s])
            self.send("#{metadata_attribute_name}=", val.present? ? val : type_def.default_value)
          end
        end

        (json_var['resources'] || {}).tap do |serialized_resources|
          self.resource_attribute_names.map(&:to_s).map do |resource_name|
            self.resources[resource_name] = Hyacinth::DigitalObject::Resource.from_serialized_form(serialized_resources[resource_name])
          end
        end
      end
  end
end
