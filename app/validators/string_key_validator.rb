class StringKeyValidator < ActiveModel::EachValidator
  ALPHANUMERIC_UNDERSCORE_KEY_REGEX = /\A[a-z]{1}[a-z0-9_]{0,240}\z/
  MESSAGE = 'values must start with a letter, can only have up to 240 characters and can only contain lower case letters, numbers and underscores'.freeze

  def validate_each(record, attribute, value)
    return if value.nil?
    unless value.match? ALPHANUMERIC_UNDERSCORE_KEY_REGEX
      record.errors[attribute] << (options[:message] || MESSAGE)
    end
  end
end
