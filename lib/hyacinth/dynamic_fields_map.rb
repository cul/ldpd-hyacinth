# frozen_string_literal: true

module Hyacinth
  module DynamicFieldsMap
    # Generates map of dynamic fields for the given metadata form.
    #
    # @param [String|Array<String>] for_metadata_form limits map to fields related forms
    def self.generate(*for_metadata_form)
      valid_metadata_forms = DynamicFieldCategory.metadata_forms.keys
      raise ArgumentError, "for_metadata_form parameters must be one of #{valid_metadata_forms}" unless (for_metadata_form - valid_metadata_forms).blank?

      categories = DynamicFieldCategory.where(metadata_form: for_metadata_form)
                                       .includes(dynamic_field_groups: [:dynamic_field_groups, :dynamic_fields])

      return {} if categories.empty?

      field_map(categories.collect_concat(&:dynamic_field_groups)).with_indifferent_access
    end

    # Generates a map of dynamic fields groups and dynamic fields.
    def self.field_map(fields_or_groups)
      fields_or_groups.map { |field_or_group|
        case field_or_group
        when DynamicField
          value = field_or_group.as_json.except(:id, :string_key, :sort_order, :display_label, :filter_label)
        when DynamicFieldGroup
          value = { type: 'DynamicFieldGroup', children: field_map(field_or_group.children) }
        else
          raise 'Invalid type when generating field map'
        end

        [field_or_group.string_key, value]
      }.to_h
    end
  end
end
