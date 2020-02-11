# frozen_string_literal: true

module Types
  module DigitalObject
    class BaseRights < Types::BaseObject
      DYNAMIC_FIELD_TYPE_TO_GRAPHQL_TYPE = {
        'string'   => GraphQL::Types::String,
        'date'     => GraphQL::Types::String,
        'boolean'  => GraphQL::Types::Boolean,
        'textarea' => GraphQL::Types::String,
        'select'   => GraphQL::Types::String,
        'controlled_term' => Types::TermType
      }.freeze

      def self.define_dynamic_field_group_type(dynamic_field_group)
        GraphQL::ObjectType.define do
          name dynamic_field_group[:string_key].camelize

          dynamic_field_group[:children].each do |child|
            if child[:type] == 'DynamicField'
              field child[:string_key].camelize(:lower), DYNAMIC_FIELD_TYPE_TO_GRAPHQL_TYPE[child[:field_type]], hash_key: child[:string_key]
            elsif child[:type] == 'DynamicFieldGroup'
              field child[:string_key].camelize(:lower), types[Types::DigitalObject::BaseRights.define_dynamic_field_group_type(child)], hash_key: child[:string_key]
            end
          end
        end
      end
    end
  end
end
