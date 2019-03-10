module Hyacinth
  module DigitalObject
    class Resource
      attr_accessor :import_location, :import_method, :import_checksum,
                    :location, :checksum

      attr_reader :import_succeeded

      def initialize(opts = {})
        opts.each do |opt_name, opt_value|
          setter_method = "#{opt_name}=".to_sym
          self.send(setter_method, opt_value) if self.respond_to?(setter_method)
        end
        @import_succeeded = false
      end

      def has_valid_import?
        import_location.present? && import_method.present?
      end

      # Clears the fields related to an import. This method is generally called
      # after an import has succeeded and the importing process does not intend
      # to roll back that import.
      def clear_import_data
        self.import_location = nil
        self.import_method = nil
        self.import_checksum = nil
      end

      # If a successful import just occurred, it was of type :copy, delete that copied file
      def undo_last_successful_import_if_copy
        if self.import_succeeded && self.import_method == :copy
          Rails.application.config.storage_adapter.delete(location_uri)
        end
      end

      def process_import_if_present(object_uid, resource_name)
        return unless has_valid_import?

        # Regardless of import type, we need to calculate a checksum for this file.
        # TODO: Consider queueing a checksum generation job here for asynchronous
        # checksum generation, though the downside of that is that we wouldn't be able
        # to verify the checksum of a copied file.  One other option to consider is
        # allowing users to optionally submit checksums as part of the import process,
        # and in those cases we actually could import the file and supplied checksum
        # without doing checksum verification, but queue an asynchronous checksum
        # verification job in the background and only send an alert if that checksum
        # match fails. For now though, we'll keep things simple by just
        # calculating/verifying checksums during import.
        self.checksum = checksum_for_file(resource.import_location)
        # TODO: Finish checksum code


        if import_method == :track
          # When tracking files, there's no need to write the file.
          resource.location = resource.import_location
        else
          # Non-tracking import operations require a file copy
          resource.with_import_file do |input_file|
            save_location = Hyacinth.config.resource_storage.generate_new_location_uri(uid, resource_name)

            Hyacinth.config.resource_storage.write(save_location) do |output_file|
              # TODO: Do import
            end
            @import_succeeded = true
          end
        end
      end

      def checksum_for_file(file_import_location)
        # TODO: Implement this
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
