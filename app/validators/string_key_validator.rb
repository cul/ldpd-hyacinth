# frozen_string_literal: true

class StringKeyValidator < ActiveModel::EachValidator
  ALPHANUMERIC_UNDERSCORE_KEY_REGEX = /\A(?=.{1,240}$)[a-z]{1}[a-z0-9]*(?:_[a-z0-9]+)*\z/
  MESSAGE = 'values must be up to 240 characters long, start with a lowercase letter, groupings ' \
            'of lowercase letters and numbers can be seperated by ONE underscore'

  def validate_each(record, attribute, value)
    return if value.nil?

    record.errors[attribute] << (options[:message] || MESSAGE) unless value.match? ALPHANUMERIC_UNDERSCORE_KEY_REGEX
  end
end
