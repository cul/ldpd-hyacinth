require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Hyacinth
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.load_defaults 6.1

    config.generators do |g|
      g.test_framework :rspec, spec: true
    end

    # Custom directories with classes and modules you want to be autoloadable.
    config.eager_load_paths << Rails.root.join('lib')
    # Hyacinth Note - See: http://stackoverflow.com/questions/4928664/trying-to-implement-a-module-using-namespaces

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Custom precompiled asset manifests
    config.assets.precompile += [
      'digital_objects_app.js',
      '*.ejs'
    ]

    # Custom asset paths
    config.assets.paths << Rails.root.join("templates") # EJS Templates

    # Load locally-defined/temporary rake tasks outside source control
    rake_tasks do
      paths.add "local/tasks", glob: "**/*.rake"
      paths["local/tasks"].existent.sort.each { |ext| load(ext) }
    end
    # use Resque for ActiveJob
    config.active_job.queue_adapter = :resque
    config.active_job.queue_name_prefix = "hyacinth.#{Rails.env}"
    config.active_job.queue_name_delimiter = '.'
  end
end
