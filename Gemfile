# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '~> 5.2.2'

# Databases
gem 'mysql2', '~> 0.5'
gem 'sqlite3', '~> 1.3.13'

# Fedora 3 related gems
gem 'rubydora'
gem 'noid', '>= 0.7.1' # For unique, opaque id generation

gem 'bootsnap', '>= 1.1.0', require: false # Reduces boot times through caching; required in config/boot.rb
gem 'best_type', '0.0.4'
gem 'cancancan', '~> 2.0'
gem 'devise', '~> 4.6'
gem 'graphql'
gem 'graphql-errors'
gem 'rainbow', '~> 3.0'
gem 'jbuilder', '~> 2.5' # Do we need this?
gem 'puma', '~> 3.12'
gem 'sass-rails', '~> 5.0'
gem 'olive_branch'
gem 'uglifier', '>= 1.3.0'
gem 'uri_service-client'
gem 'webpacker'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rubocul', git: 'https://github.com/cul/rubocul', branch: 'cgalarza-merge-exclude-array'
  gem 'equivalent-xml'
  gem 'jettywrapper', '>=1.4.0', git: 'https://github.com/samvera-deprecated/jettywrapper.git', branch: 'master'
  gem 'solr_wrapper', '~> 2.0'
end

group :development do
  gem 'capistrano', '~> 3.11', require: false
  gem 'capistrano-cul', require: false
  gem 'capistrano-passenger', '~> 0.1', require: false
  gem 'capistrano-rails', '~> 1.4', require: false
  gem 'capistrano-rvm', '~> 0.1', require: false

  gem 'graphiql-rails'

  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'chromedriver-helper'
  gem 'factory_bot_rails'
  gem 'json_spec'
  gem 'rspec-rails', '~> 3.8'
  gem 'rspec-its'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
