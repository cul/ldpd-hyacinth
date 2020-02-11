# frozen_string_literal: true

module DigitalObjectConcerns
  module DigitalObjectData
    module Setters
      module DynamicFieldData
        extend ActiveSupport::Concern

        def set_dynamic_field_data(new_digital_object_data, merge_dynamic_fields)
          return unless new_digital_object_data.key?('dynamic_field_data')
          new_dynamic_field_data = new_digital_object_data['dynamic_field_data']

          if merge_dynamic_fields
            # During a merge, new top level key-value pairs are added and existing top level keys have their values replace by new values
            self.dynamic_field_data.merge!(new_dynamic_field_data)
          else
            # Replace existing dynamic_field_data with newly supplied value
            self.dynamic_field_data = new_dynamic_field_data
          end
        end

        # TODO: Implement this method and its sub-methods
        # # Normalizes controlled term fields by removing existing non-uri properties
        # # and retrieving and re-adding non-uri properties from the term datastore (i.e. URI Service).
        # def normalize_controlled_term_fields(df_data)
        #   remove_extra_controlled_term_uri_data_from_dynamic_field_data!(df_data)
        #   add_extra_controlled_term_uri_data_to_dynamic_field_data!(df_data)
        # end

        # Trims whitespace and removes blank fields from dynamic field data.
        def clean_dynamic_field_data!
          Hyacinth::Utils::Clean.trim_whitespace!(dynamic_field_data)
          Hyacinth::Utils::Clean.remove_blank_fields!(dynamic_field_data)
        end
      end
    end
  end
end
