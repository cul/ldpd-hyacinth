# frozen_string_literal: true

module Types
  class DynamicFieldCollationType < Types::BaseUnion
    description 'Properties of a Collation of Dynamic Fields'
    possible_types DynamicFieldCategoryType, DynamicFieldGroupType

    def self.resolve_type(object, _context)
      if object.is_a?(DynamicFieldCategory)
        DynamicFieldCategoryType
      elsif object.is_a?(DynamicFieldGroup)
        DynamicFieldGroupType
      end
    end
  end
end
