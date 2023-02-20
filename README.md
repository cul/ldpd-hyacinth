# Hyacinth

Your friendly, neighborhood metadata editor.

Supported Browsers:
- Chrome: 44+
- Firefox: 40+
- Safari: 8+
- Internet Explorer: 11+

### Requirements
Hyacinth has the following dependencies:
- Ruby 2.4 (tested with ruby 2.4.2)
- Sqlite3 or MySQL (tested with MySQL 5.5)
- Apache Solr (tested with 4.9)
- Fedora 3.7 through 3.8.x (though 3.8.1 is recommended because of a concurrent writing issue with 3.7 through 3.8.0)
- Java 8 for running CI tests (using hydra-jetty).

Note: The Fedora ResourceIndex module must be turned on.  It is on by default in the Hyacinth hydra-jetty instance, but not in standalone Fedora installations.

### First Time Setup:
```sh
git clone https://github.com/cul/hyacinth.git # Clone the repo
cd hyacinth # Switch to the application directory
bundle install # Install gem dependencies
bundle exec rake hyacinth:setup:config_files # Set up required config files
bundle exec rake jetty:clean # Download and unpack a new hydra-jetty instance
bundle exec rake hyacinth:setup:solr_cores # Copy required cores to newly-unpacked hydra-jetty instance
bundle exec rake jetty:start # Start jetty, which includes Fedora and Solr (running on port 8983 in the development environment). This will take a minute.
bundle exec rake hyacinth:fedora:reload_cmodels # Import required content models into Fedora (Note: It is safe to ignore any "404 Resource Not Found" output messages encountered during this step. These are expected because the content models do not already exist in Fedora and therefore cannot be found.)
bundle exec rake uri_service:db:setup # Set up required UriService tables
bundle exec rake db:migrate # Run database migrations
bundle exec rake db:seed # Set up default data (including default users)
rails s -p 3000 # Start the application using rails server
```

Then navigate to http://localhost:3000 in your browser and sign in using the "Email" method.

**Default admin credentials:**

Email: hyacinth-admin@library.columbia.edu

Password: iamtheadmin

**To stop jetty later on, run:**

```sh
bundle exec rake jetty:stop
```

### To start Hyacinth up again after the first time setup, all you need to do is run:
```sh
bundle exec rake jetty:start # Start jetty
rails s -p 3000 # Start the application using rails server
```

### A Note About Image Thumbnails:

Hyacinth delegates image generation to a separate, asynchronous image processing application called "Derivativo," which can be found here: https://github.com/cul/ren-derivativo

### Sqlite and UriService/Rails:

If you're using sqlite, avoid using the same sqlite database file for UriService and your standard ActiveRecord tables.  See: https://github.com/cul/uri_service#problems-when-sharing-an-sqlite-database-with-rails

### Running Tests (for developers):

Tests are great and we should run them.  You'll need to install chromedriver for javascript tests.

With Homebrew: brew cask install chromedriver

And on macOS Catalina (10.15) and later, you'll need to update security settings to allow chromedriver to run because the first-time run will tell you that "the developer cannot be verified." See: https://stackoverflow.com/a/60362134

Then run the test suite with:

```sh
bundle exec rake hyacinth:ci
```

Note 1: By default, jetty will run on port 8983 in the development environment and 9983 in the test environment.

### Other Development Notes

# Intel MacOS Notes
If you installed mysql on macOS using homebrew, you may need to install mysql2 0.4.x with this command, otherwise you'll get an error (`dyld: lazy symbol binding failed: Symbol not found: _mysql_server_init`):

```
gem install mysql2 -v '0.4.10' -- --with-ldflags=-L/usr/local/opt/openssl/lib --with-cppflags=-I/usr/local/opt/openssl/include
```

# ARM (M1/M2) MacOS Notes:

You need to install Ruby 2.4.1 using this syntax:

`CFLAGS="-Wno-error=implicit-function-declaration" rvm install 2.4.1`

# Ubuntu 22 setup notes

On Ubuntu 22, Ruby 2.4.1 will fail to install because Ubuntu comes with OpenSSL 3 and our dependencies require OpenSSL 1.  To solve this problem, you need to install Ruby 2.4.1 with an RVM-provided version of OpenSSL:

```
rvm pkg install openssl
rvm uninstall 2.4.1 # if you previously tried to install it and it failed to install properly
rvm install 2.4.1 --with-openssl-dir=$HOME/.rvm/usr
```

You'll also need to install these apt packages:
```
libmysql-client-dev openjdk-8-jre
```

Maybe also `python2`, but try without it first.
