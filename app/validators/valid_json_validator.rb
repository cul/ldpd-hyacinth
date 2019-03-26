class ValidJsonValidator < ActiveModel::EachValidator
  ALPHANUMERIC_UNDERSCORE_KEY_REGEX = /\A[a-z]{1}[a-z0-9_]{0,240}\z/
  MESSAGE = 'does not validate as JSON'.freeze

  def validate_each(record, attribute, value)
    return if value.nil?
    unless Hyacinth::Utils::Json.valid_json?(value)
      record.errors[attribute] << (options[:message] || MESSAGE)
    end
  end
end
