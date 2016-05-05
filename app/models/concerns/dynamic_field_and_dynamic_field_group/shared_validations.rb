module DynamicFieldAndDynamicFieldGroup::SharedValidations
  extend ActiveSupport::Concern

  RESERVED_STRING_KEYS = ['uri', 'value']

  included do
    validate :validate_unique_df_and_dfg_string_key
    validate :validate_reserved_df_and_dfg_string_key
    validates :display_label, presence: true
    validates :string_key, presence: true, format: { with: STRING_KEY_REGEX, message: "String key values must start with a letter, can only have up to 240 characters and can only contain lower case letters, numbers and underscores." }
  end

  def validate_reserved_df_and_dfg_string_key
    # No dynamic_field or dynamic_field_group is allowed to have certain reserved string_keys
    errors.add(:string_key, "#{string_key} is a reserved key and cannot be used.  Please choose a different string_key.") if RESERVED_STRING_KEYS.include?(string_key)
  end

  def validate_unique_df_and_dfg_string_key
    # No dynamic_field or dynamic_field_group is allowed to have the same string_key
    validate_unique_df_and_dfg_string_key_for(DynamicField, DynamicFieldGroup) if self.is_a?(DynamicField)
    validate_unique_df_and_dfg_string_key_for(DynamicFieldGroup, DynamicField) if self.is_a?(DynamicFieldGroup)
  end

  def validate_unique_df_and_dfg_string_key_for(this_class, that_class)
    rel = this_class.where(string_key: string_key)
    rel = rel.where.not(id: id) unless new_record?
    errors.add(:string_key, "must be unique.  This string_key is already taken by another #{this_class.name}.") unless rel.empty?

    errors.add(:string_key, "must be unique.  This string_key is already taken by a #{that_class.name}.") unless that_class.where(string_key: string_key).empty?
  end
end
