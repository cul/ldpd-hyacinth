# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'spec_helper'
require 'rspec/rails'
require 'selenium-webdriver'
require 'capybara/rails'

Capybara.javascript_driver = :selenium_chrome_headless
# Capybara.javascript_driver = :selenium_chrome # switch to this line if you want to see the browser while tests run
Capybara.default_max_wait_time = 30 # Some ajax requests might take longer than the default waut time of 2 seconds.

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [Rails.root.join('/spec/fixtures')]

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # NOTE: We don't want to run specs in transactions because this will cause DigitalObject DB/Fedora/Solr records
  # to get out of sync.  We might enable this later on after we decouple Hyacinth and Fedora.
  config.use_transactional_fixtures = false

  # additional factory_bot configuration
  config.before(:suite) do
    FactoryBot.lint
  end

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

  # Allow us to call sign_in(user) before tests
  config.include Warden::Test::Helpers
  # Include controller helpers for controller tests
  config.include Devise::Test::ControllerHelpers, type: :controller
  ## Set Warden (which backs devise) in test mode for
  config.before :suite do
   Warden.test_mode!
  end
  config.after :each do
    # Important: Automatically sign out after every test
    Warden.test_reset!
    # We need to sleep for a moment to allow Warden.test_reset! to sign the user out,
    # otherwise the test might end too quickly and we'll still be logged in for the next test.
    sleep 0.1
  end

  def controller_test_sign_in_admin_user
    sign_in FactoryBot.create(:admin_user)
  end

  def request_test_sign_in_admin_user
    login_as(FactoryBot.create(:admin_user))
  end

  def destroy_all_hyacinth_groups_items_and_assets
    DigitalObjectRecord.all.each do |digital_object_record|
      begin
        digital_object = DigitalObject::Base.find(digital_object_record.pid)
        digital_object.destroy(true, true) if digital_object.is_a?(DigitalObject::Group) || digital_object.is_a?(DigitalObject::Item) || digital_object.is_a?(DigitalObject::Asset)
      rescue Hyacinth::Exceptions::AssociatedFedoraObjectNotFoundError
      end
    end
  end

end
