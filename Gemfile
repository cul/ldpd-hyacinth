source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.0'
gem 'bootsnap', require: false
gem 'responders'

# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.4'
gem 'mysql2', '~> 0.5.3'

# Lock rake due to rspec/rubocop v11 incompatibilities
gem 'rake', '~> 10.0'

# Use SCSS for stylesheets
gem 'sass'
gem 'sass-rails'

# Bootstrap include
gem 'bootstrap-sass', '~> 3.4.1'
gem 'autoprefixer-rails' # Recommended by bootstrap-sass

# OHSynchronizer Dependencies
gem 'font-awesome-rails', '~> 4.7.0'

# Pretty printing
gem 'coderay'

# For diff display
gem 'diffy', '~> 3.1'

# Progress bar for rake tasks
gem 'ruby-progressbar'

# For generating random, fake data
gem 'random-word'
gem 'faker'

# For retrying code blocks that may return an error
gem 'retriable', '~> 2.1'

# Encrypting certain attributes
gem 'attr_encrypted', '>= 1.3.3'

# Mime Type detection
gem 'mime-types'
gem 'mime-types-data'
# Character encoding detection
gem 'charlock_holmes'

# Excel spreadsheets
gem 'spreadsheet'
gem 'rubyXL'

# Multithreaded tasks
gem 'thread'

# Use terser as compressor for JavaScript assets
gem 'terser'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'

# Use jquery as the JavaScript library
gem 'jquery-rails', '>= 4.0.4'

# jQuery extension gems
gem 'jquery-ui-rails'
gem 'jquery.fileupload-rails' # File uploads
gem 'chosen-rails' # Multiselect box

# Also use underscore JavaScript library
gem 'underscore-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby'

# Use debugger
# gem 'debugger', group: [:development, :test]

# Pagination Is Great
gem 'kaminari'

# For building and parsing XML
gem 'nokogiri', '~> 1.10.10'  # can't update to 1.11 because our server version of GLIBC is too old

# For authentication
gem 'devise', '>= 3.4.1'
gem 'childprocess', '~> 2.0'

# CUL Fedora Dependencies and Content Models
gem 'cul_hydra', git: 'https://github.com/cul/cul_hydra', ref: 'master'
gem 'active-fedora', '8.6.0'
# gem 'cul_hydra', path: '../cul_hydra'
gem 'rubydora'
# gem 'cul_hydra', path: '../cul_hydra'
# Temporarily use specific commit because new version of gem hasn't been released yet.  Latest is 1.1.3.
gem 'rdf', '>= 1.1.5'
gem 'rdf-vocab'
gem 'uri_service', '0.6.0'
# gem 'uri_service', path: '../uri_service'
gem 'solrizer', '>= 3.4.1'

# Use wowza token gem for generating tokens
gem 'wowza-secure_token', '0.0.1'

gem 'best_type', '~> 1.0'
# gem 'best_type', path: '../best_type'

# Specify min version for active_fedora_relsint because of a needed fix
gem 'active_fedora_relsint', git: 'https://github.com/cul/active_fedora_relsint', ref: '91114c78c9af344673f1e899624031da79b72693'

# URI Escaping
gem 'addressable', '~> 2.7.0'

# Use resque for background jobs
# We're pinning resque to 1.26.x because 1.27 does an eager load operation
# that doesn't work properly with the Blacklight gem dependency and raises:
# ActiveSupport::Concern::MultipleIncludedBlocks: Cannot define multiple 'included' blocks for a Concern
gem 'resque', '~> 1.26.0'
# Need to lock to earlier version of redis gem because resque is calling
# Redis.connect, and this method no longer exists in redis gem >= 4.0
gem 'redis', '< 4' # Need to lock to earlier version of redis gem because resque is calling Redis.connect, and this method no longer exists in redis gem >= 4.0

# For unique, opaque id generation
gem 'noid', '>= 0.7.1'

gem 'rubyzip', '>= 1.2.1'

gem 'rainbow', '~> 3.0'

# Gem min versions that are only specified here because of vulnerabilities in earlier versions:
gem 'rack-protection', '>= 1.5.5'
gem 'loofah', '~> 2.20.0'
gem 'rails-html-sanitizer', '>= 1.2'

# Development and testing!
group :development, :test do
  gem 'byebug'
  gem 'rspec-rails', '~> 4.0'
  gem 'rails-controller-testing'
  gem 'capybara', '~> 3.32'
  # For testing with chromedriver
  gem 'selenium-webdriver', '~> 4.0'
  # For automatically updating chromedriver
  gem 'webdrivers', '~> 5.3.0', require: false
  gem 'factory_girl_rails', '>= 4.4.1'
  gem 'rubocop', '~> 0.67.0', require: false
  gem 'rubocop-rspec', '~> 1.26.0', require: false
  gem 'rubocop-rails_config', '~> 0.1.3', require: false
  gem 'equivalent-xml'
  gem 'listen'
end

# Development!
group :development do
  # Use Capistrano for deployment
  gem 'capistrano', '~> 3.5.0', require: false
  # Rails and Bundler integrations were moved out from Capistrano 3
  gem 'capistrano-rails', '~> 1.1', require: false
  gem 'capistrano-bundler', '~> 1.1', require: false
  # "idiomatic support for your preferred ruby version manager"
  gem 'capistrano-rvm', '~> 0.1', require: false
  # The `deploy:restart` hook for passenger applications is now in a separate gem
  # Just add it to your Gemfile and require it in your Capfile.
  gem 'capistrano-passenger', '~> 0.1', require: false
  # Use net-ssh >= 4.2 to prevent warnings with Ruby 2.4
  gem 'net-ssh', '>= 4.2'
end


# Alternate development webserver
gem 'puma', '~> 5.2', group: :development
# gem 'thin', group: :development
# gem 'unicorn', group: :development

gem "ejs", "~> 1.1"
