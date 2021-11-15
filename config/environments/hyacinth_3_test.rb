# frozen_string_literal: true

require Rails.root.join('config', 'environments', 'deployed.rb')

Rails.application.configure do
  config.log_level = :info
end
