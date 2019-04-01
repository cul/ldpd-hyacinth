module DigitalObjectConcerns
  module SaveBehavior
    module MetadataStorage
      extend ActiveSupport::Concern

      def metadata_exists?
        self.digital_object_record.metadata_location_uri.present? && Hyacinth.config.metadata_storage.exists?(self.digital_object_record.metadata_location_uri)
      end
    end
  end
end
