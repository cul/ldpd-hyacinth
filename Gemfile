# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '~> 7.0.2'

# Databases
gem 'mysql2', '~> 0.5'
gem 'sqlite3', '~> 1.4'

# Fedora 3 related gems
gem 'noid', '>= 0.7.1' # For unique, opaque id generation
gem 'rubydora'

gem 'best_type', '0.0.10'
gem 'bootsnap', '>= 1.4.5', require: false # Reduces boot times through caching; required in config/boot.rb
gem 'cancancan', '~> 3.3'
gem 'concurrent-ruby', '~> 1.1.8'
gem 'devise', '~> 4.7'
gem 'edtf', '~> 3.0'
gem 'faraday', '~> 2.2'
gem 'graphql', '~> 2.0.0'
gem 'json_csv', '~> 1.0.0'
gem 'nokogiri', '~> 1.10.10' # can't update to 1.11 because our server version of GLIBC is too old
gem 'olive_branch', '~> 4.0.1'
gem 'puma', '~> 5.2'
gem 'rainbow', '~> 3.0'
gem 'resque', '~> 2.0'
gem 'rsolr', '~> 2.3'
gem 'sass-rails', '~> 5.0' # TODO: Maybe remove?
gem 'timecop', '~> 0.9.1'
gem 'uglifier', '>= 1.3.0'
gem 'webpacker'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'equivalent-xml'
  gem 'jettywrapper', git: 'https://github.com/cul/jettywrapper.git', branch: 'ruby-3'
  gem 'rubocul', '~> 4.0.2'
  gem 'solr_wrapper', '~> 3.1.2'
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
end

group :test do
  gem 'capybara', '~> 3.35'
  gem 'factory_bot_rails'
  gem 'json_spec'
  gem 'rspec', '>= 3.11'
  gem 'rspec-its'
  gem 'rspec-rails', '~> 5.1'
  gem 'selenium-webdriver', '~> 3.142'
  gem 'simplecov', require: false
  gem 'webdrivers', '~> 4.0', require: false
  gem 'webmock'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
