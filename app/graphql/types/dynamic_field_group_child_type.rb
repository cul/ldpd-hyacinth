# frozen_string_literal: true


module Types
  class DynamicFieldGroupChildType < Types::BaseUnion
    description "objects that can be children of a dynamic field group"
    possible_types Types::DynamicFieldGroupType, Types::DynamicFieldType
    def self.resolve_type(object, _context)
      if object.is_a?(DynamicFieldGroup)
        Types::DynamicFieldGroupType
      else
        Types::DynamicFieldType
      end
    end
  end
end
