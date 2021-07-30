# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '~> 6.0.4'

# Databases
gem 'mysql2', '~> 0.5'
gem 'sqlite3', '~> 1.4'

# Fedora 3 related gems
gem 'noid', '>= 0.7.1' # For unique, opaque id generation
gem 'rubydora'

gem 'best_type', '0.0.10'
gem 'bootsnap', '>= 1.4.5', require: false # Reduces boot times through caching; required in config/boot.rb
gem 'cancancan', '~> 3.0'
gem 'concurrent-ruby', '~> 1.1.8'
gem 'devise', '~> 4.7'
gem 'edtf', '~> 3.0'
gem 'faraday', '~> 1.1'
gem 'graphql', '~> 1.9.12'
gem 'graphql-errors'
gem 'json_csv', '~> 1.0.0'
gem 'nokogiri', '~> 1.10.10' # can't update to 1.11 because our server version of GLIBC is too old
gem 'olive_branch'
gem 'puma', '~> 5.2'
gem 'rainbow', '~> 3.0'
gem 'resque', '~> 2.0'
gem 'rsolr', '~> 2.3'
gem 'sass-rails', '~> 5.0'
gem 'timecop', '~> 0.9.1'
gem 'uglifier', '>= 1.3.0'
gem 'webpacker'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'equivalent-xml'
  gem 'jettywrapper', '>=1.4.0', git: 'https://github.com/samvera-deprecated/jettywrapper.git', branch: 'master'
  gem 'rubocul', '2.0.1'
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
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'chromedriver-helper'
  gem 'factory_bot_rails'
  gem 'json_spec'
  gem 'rspec-its'
  gem 'rspec-rails', '~> 3.8'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'webmock'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
