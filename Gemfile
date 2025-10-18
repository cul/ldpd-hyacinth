source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.0.8'
gem 'bootsnap', require: false
# gem 'responders'

# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.4'
gem 'mysql2', '~> 0.5.6'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

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

# Excel spreadsheets
gem 'spreadsheet'
gem 'rubyXL'

# Multithreaded tasks
gem 'thread'

# Use terser as compressor for JavaScript assets
gem 'terser'

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

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby'

# Use debugger
# gem 'debugger', group: [:development, :test]

# Pagination Is Great
gem 'kaminari'

# For building and parsing XML
gem 'nokogiri', '~> 1.18', '>= 1.18.10', force_ruby_platform: true

# For authentication
gem 'devise', '~> 4.9'
# gem 'childprocess', '~> 2.0'

# CUL Fedora Dependencies and Content Models
gem 'cul_hydra', git: 'https://github.com/cul/cul_hydra', ref: 'wip-upgrade-deps'
gem 'active-fedora', git: 'https://github.com/cul/active_fedora', ref: 'remove_deprecation_lib'
gem 'multi_json', '~> 1.14.0'
gem 'ebnf', '~> 1.0.0'
gem 'rubydora'
# Temporarily use specific commit because new version of gem hasn't been released yet.  Latest is 1.1.3.
gem 'rdf', '>= 1.1.5'
gem 'rdf-vocab', '~>0.8.8'
gem 'uri_service', '0.6.0'
# gem 'uri_service', path: '../uri_service'
gem 'solrizer', '>= 3.4.1'

# Use wowza token gem for generating tokens
gem 'wowza-secure_token', '0.0.1'

gem 'best_type', '~>1.0.1'

# Specify min version for active_fedora_relsint because of a needed fix
gem 'active_fedora_relsint', git: 'https://github.com/cul/active_fedora_relsint', ref: '91114c78c9af344673f1e899624031da79b72693'

# URI Escaping
gem 'addressable', '~> 2.8.0'

gem 'redis', '~> 4.8' # NOTE: Updating the redis gem to v5 breaks the current redis namespace setup
gem 'redis-namespace', '~> 1.11'
# Resque for queued jobs
gem 'resque', '~> 2.6'

# For unique, opaque id generation
gem 'noid', '>= 0.7.1'

gem 'rubyzip', '>= 1.2.1'

gem 'rainbow', '~> 3.0'

# Forcing psych 3 (not 4) so that yaml aliases can be used with Rails 6.0
gem 'psych', '<4'

# For css and js compilation
gem 'vite_rails', '~> 3.0.19'

# Require net-http gem explicitly (and allow any version) to fix an issue where the net-protocol
# dependency is loaded twice.  See this: https://stackoverflow.com/a/75105591
# And this: https://github.com/ruby/net-imap/issues/16#issuecomment-803086765
gem 'net-http'

# Gem min versions that are only specified here because of vulnerabilities in earlier versions:
gem 'rack-protection', '>= 1.5.5'
gem 'loofah', '~> 2.20.0'
gem 'rails-html-sanitizer', '>= 1.2'

# Amazon S3 SDK
gem 'aws-sdk-s3', '~> 1.0'
# Additional gem enabling the AWS SDK to calculate CRC32C checksums
gem 'aws-crt'
# Google Cloud Storage SDK
gem 'google-cloud-storage', '~> 1.49'

# Remove the pin below once you update to Rails 7.0 or later.
# See: https://github.com/rails/rails/issues/54263
gem 'concurrent-ruby', '1.3.4'

gem 'msgpack', '~> 1.7.2' # Currently having an issue building msgpack 1.8 on AlmaLinux 8 servers

# Development and testing!
group :development, :test do
  gem 'byebug'
  gem 'rspec-rails', '~> 7.0'
  gem 'rails-controller-testing'
  gem 'capybara', '~> 3.32'
  # For testing with chromedriver
  gem 'selenium-webdriver', '~> 4.0'
  # For automatically updating chromedriver
  gem 'webdrivers', '~> 5.3.0', require: false
  gem 'factory_bot_rails', '~> 4.9'
  gem 'rubocop', '~> 0.67.0', require: false
  gem 'rubocop-rspec', '~> 1.26.0', require: false
  gem 'rubocop-rails_config', '~> 0.2.3', require: false
  gem 'equivalent-xml'
  gem 'listen'
end

# Development!
group :development do
  # Use Capistrano for deployment
  gem 'capistrano', '~> 3.19.2', require: false
  gem 'capistrano-cul', require: false
  gem 'capistrano-passenger', '~> 0.1', require: false
  gem 'capistrano-rails', '~> 1.4', require: false
end


# Alternate development webserver
gem 'puma', '~> 6.5', group: :development
# gem 'thin', group: :development
# gem 'unicorn', group: :development

gem "ejs", "~> 1.1"
