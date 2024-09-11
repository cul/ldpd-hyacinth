source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1.0'
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
# Character encoding detection
gem 'charlock_holmes'

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
gem 'nokogiri', '~> 1.15.5'

# For authentication
gem 'devise', '~> 4.9.3'
# gem 'childprocess', '~> 2.0'

# CUL Fedora Dependencies and Content Models
gem 'cul_hydra', git: 'https://github.com/cul/cul_hydra', ref: 'remove_blacklight'
gem 'active-fedora', '8.6.0'
gem 'rubydora'
# Temporarily use specific commit because new version of gem hasn't been released yet.  Latest is 1.1.3.
gem 'rdf', '>= 1.1.5'
gem 'rdf-vocab'
gem 'uri_service', '0.6.0'
# gem 'uri_service', path: '../uri_service'
gem 'solrizer', '>= 3.4.1'

# Use wowza token gem for generating tokens
gem 'wowza-secure_token', '0.0.1'

# gem 'best_type', '~> 1.0'
# gem 'best_type', path: '../best_type'
gem 'best_type', git: 'https://github.com/cul/best_type.git', branch: 'LDPD-415-case-sensitive-comparisons'

# Specify min version for active_fedora_relsint because of a needed fix
gem 'active_fedora_relsint', git: 'https://github.com/cul/active_fedora_relsint', ref: '91114c78c9af344673f1e899624031da79b72693'

# URI Escaping
gem 'addressable', '~> 2.8.0'

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

# Forcing psych 3 (not 4) so that yaml aliases can be used with Rails 6.0
gem 'psych', '<4'

# For css and js compilation
gem 'vite_rails', '~> 3.0.17'

# Require net-http gem explicitly (and allow any version) to fix an issue where the net-protocol
# dependency is loaded twice.  See this: https://stackoverflow.com/a/75105591
# And this: https://github.com/ruby/net-imap/issues/16#issuecomment-803086765
gem 'net-http'

# Require uri gem explicitly and match the default.standard gem that comes with Ruby 2.7.8
# (otherwise we'll get an error about the bundle version not matching the installed version).
# See: https://stdgems.org/2.7.8/
# NOTE: This should be changed if you update to a newer version of ruby.
gem 'uri', '0.10.0.2'

# Gem min versions that are only specified here because of vulnerabilities in earlier versions:
gem 'rack-protection', '>= 1.5.5'
gem 'loofah', '~> 2.20.0'
gem 'rails-html-sanitizer', '>= 1.2'

# Amazon S3 SDK
gem 'aws-sdk-s3', '~> 1'
# Additional gem enabling the AWS SDK to calculate CRC32C checksums
gem 'aws-crt', '~> 0.2.0'
# Google Cloud Storage SDK
gem 'google-cloud-storage', '~> 1.49'

# Development and testing!
group :development, :test do
  gem 'byebug'
  gem 'rspec-rails', '~> 5.0'
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
  gem 'capistrano', '~> 3.18.0', require: false
  gem 'capistrano-cul', require: false
  gem 'capistrano-passenger', '~> 0.1', require: false
  gem 'capistrano-rails', '~> 1.4', require: false
end


# Alternate development webserver
gem 'puma', '~> 5.2', group: :development
# gem 'thin', group: :development
# gem 'unicorn', group: :development

gem "ejs", "~> 1.1"
