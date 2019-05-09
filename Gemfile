source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.2'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.3.13'
# Enable mysql as the database for Active Record
gem 'mysql2', '~> 0.5'

# Use Puma as the app server
gem 'puma', '~> 3.12'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Devise for authentication, cancancan for authorization
gem 'cancancan', '~> 2.0'
gem 'devise', '~> 4.6'

# Text coloring
gem 'rainbow', '~> 3.0'

gem 'uri_service-client'
gem 'olive_branch'


gem 'best_type', '0.0.4'

# Fedora 3 related gems
gem 'rubydora'
# For unique, opaque id generation
gem 'noid', '>= 0.7.1'

# Bootstrap 3 and jQuery (TODO: Remove these when we switch fully to the new React UI, which pulls in its own css/js via node)
gem 'bootstrap-sass', '~> 3.3'
gem 'autoprefixer-rails' # Recommended by bootstrap-sass
gem 'jquery-rails', '~> 4.3' # Required by bootstrap

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # bixby (i.e. rubocop presets) for code analysis/formatting
  gem 'bixby', '2.0.0.pre.beta1'
  gem 'solr_wrapper', '~> 2.0'
  gem 'equivalent-xml'
  gem 'jettywrapper', '>=1.4.0', git: 'https://github.com/samvera-deprecated/jettywrapper.git', branch: 'master'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
end

group :test do
  gem 'rspec-rails', '~> 3.8'
  gem 'rspec-its'
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
  # Check test coverage
  gem 'simplecov', require: false
  gem 'factory_bot_rails'
  gem 'json_spec'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
