module Hyacinth
  module DigitalObject
    class Resource
      attr_accessor :import_location, :import_method, :import_checksum,
                    :location, :checksum

      def initialize
      end

      def has_valid_import?
        import_location.present? && import_method.present?
      end

      def process_import_if_present!
        return unless has_valid_import?
        if import_method == :track
          resource.location = resource.import_location
        else

        end

        resource.with_import_file do |input_file|
          Hyacinth.config.storage_adapter.write(location_uri) do |output_file|
            # TODO: Do import
          end
        end
      end

      def self.from_json(json)
        self.new.tap do |resource|
          ['location', 'checksum'].each do |attribute|
            resource[attribute] = json[attribute]
          end
        end
      end

      def as_json
        return {} unless location
        {
          'location' => location,
          'checksum' => checksum
        }
      end
    end
  end
end
