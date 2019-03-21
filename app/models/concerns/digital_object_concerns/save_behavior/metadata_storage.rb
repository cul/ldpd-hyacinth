module DigitalObjectConcerns
  module SaveBehavior
    module MetadataStorage
      extend ActiveSupport::Concern

      def write_to_metadata_storage
        Hyacinth.config.metadata_storage.write(self.digital_object_record.metadata_location_uri, JSON.generate(self.to_serialized_form))
      end

      def metadata_exists?
        self.digital_object_record.metadata_location_uri.present? && Hyacinth.config.metadata_storage.exists?(self.digital_object_record.metadata_location_uri)
      end
    end
  end
end
