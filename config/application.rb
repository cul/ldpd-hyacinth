# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Hyacinth
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Custom directories with classes and modules you want to be eager loaded.
    config.eager_load_paths += %W[#{config.root}/lib]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Don't generate system test files.
    config.generators.system_tests = true

    config.middleware.use OliveBranch::Middleware

    config.active_job.queue_adapter = :resque
    config.active_job.queue_name_prefix = "hyacinth.#{Rails.env}"
    config.active_job.queue_name_delimiter = '.'

    # Rails will use the Eastern time zone
    config.time_zone = 'Eastern Time (US & Canada)'
    # Database will store dates in UTC (which is the rails default behavior)
    config.active_record.default_timezone = :utc
  end
end
