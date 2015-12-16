module Hyacinth::Csv::Flatten
  extend ActiveSupport::Concern

  module ClassMethods
    def keys_for_document(document, omit_blank_values = false)
      document = document.clone
      df_data = document.delete(Hyacinth::Csv::Fields::Dynamic::DATA_KEY) || {}

      internals = pointers_for_hash(document, omit_blank_values)
      internals.map! { |pointer| Hyacinth::Csv::Fields::Internal.new(pointer) }
      dynamics = pointers_for_hash(df_data, omit_blank_values)
      dynamics.map! { |pointer| Hyacinth::Csv::Fields::Dynamic.new(pointer) }
      internals.map(&:to_header) + dynamics.map(&:to_header)
    end

    def pointers_for_hash(hash, omit_blank_values, prefix = [])
      keys = []
      hash.each do |key, value|
        if value.is_a?(Array)
          key_prefix = prefix + [key]
          keys += pointers_for_array(value, omit_blank_values, key_prefix)
        elsif value.is_a?(Hash)
          key_prefix = prefix + [key]
          keys += pointers_for_hash(value, omit_blank_values, key_prefix)
        else
          key = pointer_for_value(key, value, omit_blank_values, prefix)
          keys << key unless keys.include?(key) || key.nil?
        end
      end
      keys.uniq
    end

    def pointers_for_array(array, omit_blank_values, prefix)
      keys = []
      array.each_with_index do |value, index|
        if value.is_a? Hash
          keys += pointers_for_hash(value, omit_blank_values, prefix + [index])
        else
          key = pointer_for_value(index, value, omit_blank_values, prefix)
          keys << key unless keys.include?(key) || key.nil?
        end
      end
      keys
    end

    def pointer_for_value(key, value, omit_blank_values, prefix = [])
      return nil if omit_blank_values && value.blank?
      prefix + [key]
    end
  end
end
