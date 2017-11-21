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

# Gem for nice multi-select widget
gem 'bootstrap-multiselect-rails'

# Pretty printing
gem 'coderay'

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
gem 'libv8', '>= 3.16.14.15' # Min version for Mac OS 10.11, XCode 8.0

# Use jquery as the JavaScript library
gem 'jquery-rails'

# jQuery extension gems
gem 'jquery-ui-rails'
gem 'jquery.fileupload-rails' # File uploads
gem 'chosen-rails' # Multiselect box

# Also use underscore JavaScript library
gem 'underscore-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'

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
gem 'nokogiri', '~> 1.6.5'
gem 'equivalent-xml'

# For authentication
gem 'devise', '>= 3.4.1'

# CUL Fedora Dependencies and Content Models
gem 'cul_hydra', '~> 1.4.7'
#gem 'cul_hydra', :path => '../cul_hydra'
gem 'jettywrapper', '>= 1.5.1'
# Temporarily use specific commit because new version of gem hasn't been released yet.  Latest is 1.1.3.
gem 'rdf-rdfxml', :github => 'ruby-rdf/rdf-rdfxml', :ref => '78c13fe5dbcecaf1f56abe9535d00f16c670a764'
gem 'uri_service', '0.5.3'
#gem 'uri_service', :path => '../uri_service'

# Specify min version for active_fedora_relsint because of a needed fix
gem 'active_fedora_relsint', '>= 0.4.1'

# URI Escaping
gem 'addressable'

# Use resque for background jobs
gem 'resque', '~> 1.27'

# For unique, opaque id generation
gem 'noid', '>= 0.7.1'

# Testing!
group :development, :test do
  gem 'byebug'
  gem 'rspec-rails', '~> 3.3'
  gem 'capybara', '>= 2.5'
  gem 'poltergeist', '>= 1.7' # For headless-browser JavaScript testing
  gem 'factory_girl_rails', '>= 4.4.1'
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
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

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end


# Alternate development webserver
gem 'puma', group: :development
#gem 'thin', group: :development
#gem 'unicorn', group: :development
