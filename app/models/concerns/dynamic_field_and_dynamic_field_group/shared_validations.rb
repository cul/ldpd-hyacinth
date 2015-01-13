module DynamicFieldAndDynamicFieldGroup::SharedValidations
  extend ActiveSupport::Concern

  included do
    validate :validate_unique_df_and_dfg_string_key
    validates :display_label, presence: true
    validates :string_key, presence: true, format: { with: STRING_KEY_REGEX, message: "String key values must start with a letter, can only have up to 240 characters and can only contain lower case letters, numbers and underscores." }
  end

  def validate_unique_df_and_dfg_string_key
    # No dynamic_field or dynamic_field_group is allowed to have the same string_key

    if self.is_a?(DynamicField)

      if DynamicField.where(string_key: self.string_key).where(self.new_record? ? 'true' : 'id  != ' + self.id.to_s).length > 0
        errors.add(:string_key, "must be unique.  This string_key is already taken by another DynamicField.")
      end

      if DynamicFieldGroup.where(string_key: self.string_key).length > 0
        errors.add(:string_key, "must be unique.  This string_key is already taken by a DynamicFieldGroup.")
      end

    elsif self.is_a?(DynamicFieldGroup)

      if DynamicField.where(string_key: self.string_key).length > 0
        errors.add(:string_key, "must be unique.  This string_key is already taken by a DynamicField.")
      end

      if DynamicFieldGroup.where(string_key: self.string_key).where(self.new_record? ? 'true' : 'id  != ' + self.id.to_s).length > 0
        errors.add(:string_key, "must be unique.  This string_key is already taken by another DynamicFieldGroup.")
      end

    end
  end

end
