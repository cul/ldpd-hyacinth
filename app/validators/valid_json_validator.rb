class ValidJsonValidator < ActiveModel::EachValidator
  MESSAGE = 'does not validate as JSON'.freeze

  def validate_each(record, attribute, value)
    return if value.nil?

    record.errors[attribute] << (options[:message] || MESSAGE) unless valid_json?(value)
  end

  private

    def valid_json?(value)
      Hyacinth::Utils::Json.valid_json?(value)
    end
end
