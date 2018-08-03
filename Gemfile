source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.8'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'
gem 'mysql2', '0.4.5'

# Lock rake due to rspec/rubocop v11 incompatibilities
gem 'rake', '~> 10.0'

# Use SCSS for stylesheets
gem 'sass'
gem 'sass-rails'

# Bootstrap include
gem 'bootstrap-sass', '~> 3.3'
gem 'autoprefixer-rails' # Recommended by bootstrap-sass

# OHSynchronizer Dependencies
gem 'font-awesome-rails', '~> 4.7.0'
#gem 'jquery-ui-rails' # Maybe needed?

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

# Character encoding detection
gem 'charlock_holmes'

# Excel spreadsheets
gem 'spreadsheet'
gem 'rubyXL'

# Multithreaded tasks
gem 'thread'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', '>= 0.12.3',  platforms: :ruby
gem 'libv8', '>= 3.16.14.19' # Min version for Mac OS 10.11, XCode 9.0, Ruby 2.4

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
gem 'jbuilder', '~> 1.2'

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
gem 'nokogiri', '~> 1.8.1'

# For authentication
gem 'devise', '>= 3.4.1'

# CUL Fedora Dependencies and Content Models
gem 'cul_hydra', '~> 1.5.0'
gem 'rubydora', git: 'https://github.com/elohanlon/rubydora', branch: 'datastream_dissemination_with_headers'
# gem 'cul_hydra', path: '../cul_hydra'
gem 'jettywrapper', '>= 1.5.1'
# Temporarily use specific commit because new version of gem hasn't been released yet.  Latest is 1.1.3.
gem 'rdf-rdfxml', git: 'https://github.com/ruby-rdf/rdf-rdfxml', ref: '78c13fe5dbcecaf1f56abe9535d00f16c670a764'
gem 'uri_service', '0.5.5'
# gem 'uri_service', path: '../uri_service'
gem 'solrizer', '>= 3.4.1'


gem 'best_type', '0.0.3'

# Specify min version for active_fedora_relsint because of a needed fix
gem 'active_fedora_relsint', '>= 0.4.1'

# URI Escaping
gem 'addressable'

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

# Gem min versions that are only specified here because of vulnerabilities in earlier versions:
gem 'rubyzip', '>= 1.2.1'
gem 'rack-protection', '>= 1.5.5'
gem 'loofah', '>= 2.2.1'

# Development and testing!
group :development, :test do
  gem 'byebug'
  gem 'rspec-rails', '~> 3.3'
  gem 'capybara', '>= 2.5'
  gem 'poltergeist', '>= 1.7' # For headless-browser JavaScript testing
  gem 'factory_girl_rails', '>= 4.4.1'
  gem 'rubocop', '~> 0.51.0', require: false
  gem 'rubocop-rspec', '>= 1.20.1', require: false
  gem 'rubocop-rails', '>= 1.1.0',  require: false
  gem 'equivalent-xml'
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

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end


# Alternate development webserver
gem 'puma', group: :development
# gem 'thin', group: :development
# gem 'unicorn', group: :development
