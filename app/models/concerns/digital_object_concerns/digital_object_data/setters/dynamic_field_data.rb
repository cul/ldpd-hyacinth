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

        # Recursively removes blank fields from the given dynamic field data.
        # @param df_data [Hash or Array or Object] Dynamic field data
        def remove_blank_fields_from_dynamic_field_data!(df_data = self.dynamic_field_data)
          return if df_data.frozen? # We can't modify a frozen hash (e.g. uri-based controlled vocabulary field), so we won't attempt to.

          # Step 1: Recursively handle values on lower levels
          df_data.each do |_key, value|
            if value.is_a?(Array)
              # Recurse through non-empty elements
              value.each do |element|
                remove_blank_fields_from_dynamic_field_data!(element)
              end

              # Delete blank array element values on this array level (including empty object ({}) values)
              value.delete_if(&:blank?)
            elsif value.is_a?(Hash)
              # This code will run when we're dealing with something like a controlled
              # term field, which is a hash that contains a hash as a value.
              remove_blank_fields_from_dynamic_field_data!(value)
            end
          end

          # Step 2: Delete blank values on this object level
          df_data.delete_if { |_key, value| value.blank? }
        end

        # Recursively trims whitespace from nested values in the given dynamic field data.
        # @param df_data [Hash, Array, or String] Dynamic field data
        def trim_whitespace_for_dynamic_field_data!(df_data = self.dynamic_field_data)
          # Step 1: Recursively handle values on lower levels
          df_data.each do |_key, value|
            if value.is_a?(Array)
              value.each { |element| trim_whitespace_for_dynamic_field_data!(element) }
            elsif value.is_a?(Hash)
              trim_whitespace_for_dynamic_field_data!(value)
            elsif value.is_a?(String)
              value.strip!
            end
          end
        end
      end
    end
  end
end
