# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [
  :passw,
  :secret,
  :token,
  # it's good to filter out things that match '_key', but we don't want to filter out things that
  # contain 'string_key' or 'keyword'
  /(?<!string)_key(?!word)/,
  :crypt,
  :salt,
  :certificate,
  :otp,
  :ssn
]
