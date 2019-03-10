class StringKeyValidator < ActiveModel::EachValidator
  ALPHANUMERIC_UNDERSCORE_KEY_REGEX = /\A[a-z]+[a-z0-9_]*\z/

  def validate_each(record, attribute, value)
    return if value.nil?
    unless value.match? ALPHANUMERIC_UNDERSCORE_KEY_REGEX
      record.errors[attribute] << (options[:message] || "only allows lowercase alphanumeric characters and underscores and must start with a lowercase letter")
    end
  end
end
