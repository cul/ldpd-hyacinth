# frozen_string_literal: true

module DigitalObjectConcerns
  module AttributeAssignment
    module Descriptive
      extend ActiveSupport::Concern

      def assign_descriptive(new_digital_object_data, merge_descriptive = true)
        return unless new_digital_object_data.key?('descriptive')
        new_descriptive = new_digital_object_data['descriptive']

        if merge_descriptive
          # During a merge, new top level key-value pairs are added and existing top level keys have their values replace by new values
          descriptive.merge!(new_descriptive)
        else
          # Replace existing descriptive with newly supplied value
          self.descriptive = new_descriptive
        end
      end

      # TODO: Implement this method and its sub-methods
      # # Normalizes controlled term fields by removing existing non-uri properties
      # # and retrieving and re-adding non-uri properties from the term datastore (i.e. URI Service).
      # def normalize_controlled_term_fields(df_data)
      #   remove_extra_controlled_term_uri_data_from_descriptive!(df_data)
      #   add_extra_controlled_term_uri_data_to_descriptive!(df_data)
      # end

      # Trims whitespace and removes blank fields from dynamic field data.
      def clean_descriptive!
        Hyacinth::Utils::Clean.trim_whitespace!(descriptive)
        Hyacinth::Utils::Clean.remove_blank_fields!(descriptive)
      end
    end
  end
end
