module DynamicFieldStructure
  module StringKey
    extend ActiveSupport::Concern

    RESERVED_STRING_KEYS = ['uri', 'value']

    included do
      validates :string_key, presence: true,  string_key: true, exclusion: { in: RESERVED_STRING_KEYS }
      validate :unique_string_key
    end

    private

      # Validate that the string_key is unique between all siblings.
      def unique_string_key
        sibling_string_keys = siblings.map(&:string_key)
        errors.add(:string_key, 'is already in use by a sibling field or field group') if sibling_string_keys.include?(string_key)
      end
  end
end
