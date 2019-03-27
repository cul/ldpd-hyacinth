class ValidJsonValidator < ActiveModel::EachValidator
  MESSAGE = 'does not validate as JSON'.freeze

  def validate_each(record, attribute, value)
    return if value.nil?
    unless Hyacinth::Utils::Json.valid_json?(value)
      record.errors[attribute] << (options[:message] || MESSAGE)
    end
  end
end
