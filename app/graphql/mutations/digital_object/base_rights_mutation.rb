# frozen_string_literal: true

module Mutations
  module DigitalObject
    class BaseRightsMutation < Mutations::BaseMutation
      TERM_INPUT_TYPE = GraphQL::InputObjectType.define do
        name "TermInput"

        argument :id, types.ID
        argument :prefLabel, !types.String, as: :pref_label
        argument :altLabels, types[types.String], as: :alt_label
        argument :authority, types.String
        argument :uri, !types.String
        argument :termType, Types::TermCategory.to_non_null_type, as: :term_type
        argument :customFields, types[Types::CustomFieldAttributes], as: :custom_fields
      end

      DYNAMIC_FIELD_TYPE_TO_GRAPHQL_INPUT_TYPE = {
        'string'   => GraphQL::Types::String,
        'date'     => GraphQL::Types::String,
        'boolean'  => GraphQL::Types::Boolean,
        'textarea' => GraphQL::Types::String,
        'select'   => GraphQL::Types::String,
        'controlled_term' => TERM_INPUT_TYPE
      }.freeze

      def self.define_dynamic_field_group_input(dynamic_field_group)
        GraphQL::InputObjectType.define do
          name "#{dynamic_field_group[:string_key].camelize(:lower)}Input"

          dynamic_field_group[:children].each do |child|
            if child[:type] == "DynamicField"
              argument child[:string_key].camelize(:lower), DYNAMIC_FIELD_TYPE_TO_GRAPHQL_INPUT_TYPE[child[:field_type]], as: child[:string_key]
            elsif child[:type] == "DynamicFieldGroup"
              input_type = Mutations::DigitalObject::BaseRightsMutation.define_dynamic_field_group_input(child)
              argument child[:string_key].camelize(:lower), types[input_type], as: child[:string_key]
            end
          end
        end
      end
    end
  end
end
