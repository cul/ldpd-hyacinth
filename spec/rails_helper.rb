# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require File.expand_path("../rails_4_ruby_26_fix", __FILE__)
require 'webdrivers'
require 'capybara/rails'

Capybara.javascript_driver = :selenium_chrome_headless
Capybara.default_max_wait_time = 30 # Some ajax requests might take longer than the default waut time of 2 seconds.

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  # Remove these two lines if you're not using ActiveRecord or ActiveRecord fixtures
  config.include ActionDispatch::TestProcess
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false # We don't want to run specs in transactions because this will cause DigitalObject DB/Fedora/Solr records to get out of sync

  # additional factory_girl configuration
  config.before(:suite) do
    FactoryGirl.lint
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

  # Added so that we can test Devise logins
  config.include Devise::Test::ControllerHelpers, :type => :controller # Cannot use this for request/feature specs
  def sign_in_admin_user_controller_spec()
    sign_in(FactoryGirl.create(:admin_user))
  end

  ## Set Warden (which backs devise) in test mode for
  #config.include Warden::Test::Helpers
  #config.before :suite do
  #  Warden.test_mode!
  #end
  #config.after :each do
  #  Warden.test_reset!
  #end

  def feature_spec_sign_in_admin_user
    visit '/users/sign_in'
    within("#new_user") do
      fill_in 'user_email', :with => 'hyacinth-test@library.columbia.edu'
      fill_in 'user_password', :with => 'iamthetest'
    end
    click_button 'Sign in'
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
