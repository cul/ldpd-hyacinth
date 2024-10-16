# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# Require 'webdrivers/chromedriver' so that chromedriver is automatically installed/updated
require 'webdrivers/chromedriver'
# Add additional requires below this line. Rails is not loaded until this point!
require 'webmock/rspec'
# Disable network connections because we want to mock them instead, but allow connections to
# the chromedriver download domain so that we can automatically install/update chromedriver.
# Also use net_http_connect_on_start to avoid "too many open files" issue.  For more info, see:
# https://github.com/bblimke/webmock/blob/master/README.md#connecting-on-nethttpstart
WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: 'chromedriver.storage.googleapis.com',
  net_http_connect_on_start: true
)

require 'capybara/rails'
Capybara.javascript_driver = :selenium_chrome_headless
Capybara.default_max_wait_time = 5 # Some ajax requests might take longer than the default wait time of 2 seconds.
Capybara.enable_aria_label = true
Capybara.default_set_options = { clear: :backspace } # This is a better way to clear fields for React apps

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.file_fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # Include helpers
  config.include JsonSpec::Helpers
  config.include HyacinthTestCleanup
  config.include DynamicFieldsHelper
  authenticatable_spec_types = [:feature, :request]
  authenticatable_spec_types.each do |spec_type|
    config.include Devise::Test::IntegrationHelpers, type: spec_type
    config.include AuthenticatedRequests, type: spec_type
    config.include AuthenticateUser, type: spec_type
  end
  config.include GraphQLHelper, type: :request

  config.before(:each, solr: true) do
    solr_cleanup
  end

  # Reset factory sequences between tests
  config.before do
    FactoryBot.rewind_sequences
  end
end
