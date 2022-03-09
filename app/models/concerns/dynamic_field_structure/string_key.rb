# frozen_string_literal: true

module DynamicFieldStructure
  module StringKey
    extend ActiveSupport::Concern

    # TODO: This restriction can be removed in the near future, as it is probably not necessary.
    RESERVED_STRING_KEYS = ['uri', 'pref_label'].freeze

    included do
      validates :string_key, presence: true, string_key: true, exclusion: { in: RESERVED_STRING_KEYS }
      validate :unique_string_key
    end

    private

      # Validate that the string_key is unique between all siblings.
      def unique_string_key
        if parent.instance_of?(DynamicFieldCategory)
          # Ensure unique top level string_key values across all immediate descendants of DynamicFieldCategories
          dynamic_field_group_ids_with_same_key = DynamicFieldGroup.unscoped.where(
            parent_type: DynamicFieldCategory.name,
            parent_id: DynamicFieldCategory.all.pluck(:id),
            string_key: string_key
          ).pluck(:id)

          # If a matching DynamicFieldGroup is found, add an error...unless the found DynamicFieldGroup IS the current object!
          add_path_error if dynamic_field_group_ids_with_same_key.length.positive? && dynamic_field_group_ids_with_same_key.first != self.id
        elsif siblings.map(&:string_key).include?(string_key)
          # Ensure unique string_key values across all siblings anywhere in the field hierarchy
          add_path_error
        end
      end

      def add_path_error
        errors.add(:string_key, 'is already in use by a sibling field or field group')
      end
  end
end
