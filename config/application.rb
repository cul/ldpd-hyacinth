require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Hyacinth
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    # Rails will use the Eastern time zone
    # config.time_zone = 'Eastern Time (US & Canada)' # TODO: Enable this
    # Database will store dates in UTC (which is the rails default behavior)
    config.active_record.default_timezone = :utc

    config.generators do |g|
      g.test_framework :rspec, spec: true
    end

    # Custom directories with classes and modules you want to be autoloadable.
    config.eager_load_paths << Rails.root.join('lib')
    # Hyacinth Note - See: http://stackoverflow.com/questions/4928664/trying-to-implement-a-module-using-namespaces

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
