# frozen_string_literal: true

module DigitalObjectConcerns
  module AttributeAssignment
    module DescriptiveMetadata
      extend ActiveSupport::Concern

      def assign_descriptive_metadata(new_digital_object_data, merge_descriptive_metadata = true)
        return unless new_digital_object_data.key?('descriptive_metadata')
        new_descriptive_metadata = new_digital_object_data['descriptive_metadata']

        if merge_descriptive_metadata
          # During a merge, new top level key-value pairs are added and existing top level keys have their values replace by new values
          descriptive_metadata.merge!(new_descriptive_metadata)
        else
          # Replace existing descriptive_metadata with newly supplied value
          self.descriptive_metadata = new_descriptive_metadata
        end
      end

      # TODO: Implement this method and its sub-methods
      # # Normalizes controlled term fields by removing existing non-uri properties
      # # and retrieving and re-adding non-uri properties from the term datastore (i.e. URI Service).
      # def normalize_controlled_term_fields(df_data)
      #   remove_extra_controlled_term_uri_data_from_descriptive_metadata!(df_data)
      #   add_extra_controlled_term_uri_data_to_descriptive_metadata!(df_data)
      # end

      # Trims whitespace and removes blank fields from descriptive_metadata.
      def clean_descriptive_metadata!
        Hyacinth::Utils::Clean.trim_whitespace!(descriptive_metadata)
        Hyacinth::Utils::Clean.remove_blank_fields!(descriptive_metadata)
      end
    end
  end
end
