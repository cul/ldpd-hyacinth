# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app,
    :timeout => 20
  )
end


Capybara.javascript_driver = :poltergeist
Capybara.default_wait_time = 20 # Some ajax requests might take longer than the default waut time of 2 seconds.  Max out at 15 seconds when testing.

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

# This module authenticates users for request specs.
module ValidUserRequestHelper
  def request_spec_sign_in_admin_user
      @user ||= FactoryGirl.create(:admin_user)
      post_via_redirect user_session_path, 'user[email]' => @user.email, 'user[password]' => @user.password
  end
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # additional factory_girl configuration
  config.before(:suite) do
    FactoryGirl.lint
  end

  # We're having issues with PhantomJS timing out.  See: https://github.com/teampoltergeist/poltergeist/issues/375
  # Hopefully this will fix the problem.  Solution from: https://gist.github.com/afn/c04ccfe71d648763b306
  config.around(:each, type: :feature) do |ex|
    example = RSpec.current_example
    # Try four times
    4.times do |i|
      example.instance_variable_set('@exception', nil)
      self.instance_variable_set('@__memoized', nil) # clear let variables
      ex.run
      break unless example.exception.is_a?(Capybara::Poltergeist::TimeoutError)
      puts("\nCapybara::Poltergeist::TimeoutError at #{example.location}\n   Restarting phantomjs and retrying...")
      restart_phantomjs
    end
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
  config.include Devise::TestHelpers, :type => :controller # Don't use this for request specs.  Simulate real login mechanism for request specs.
  def sign_in_admin_user()
    sign_in(FactoryGirl.create(:admin_user))
  end

  config.include ValidUserRequestHelper, :type => :request


  def restart_phantomjs
    puts "-> Restarting phantomjs: iterating through capybara sessions..."
    session_pool = Capybara.send('session_pool')
    session_pool.each do |mode,session|
      msg = "  => #{mode} -- "
      driver = session.driver
      if driver.is_a?(Capybara::Poltergeist::Driver)
        msg += "restarting"
        driver.restart
      else
        msg += "not poltergeist: #{driver.class}"
      end
      puts msg
    end
  end
end
