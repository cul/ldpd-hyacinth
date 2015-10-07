#Hyacinth

Your friendly, neighborhood metadata editor.

Supported Browsers:
- Chrome: 44+
- Firefox: 40+
- Safari: 8+
- Internet Explorer: 11+

### Requirements
Hyacinth has the following dependencies:
- Ruby 1.9.3 or 2.x (tested with 1.9.3 and 2.1.3, though ruby 2.0+ is recommended because 1.9.3 has reached EOL)
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
bundle exec rake jetty:clean # Download and unpack a new Hyacinth hydra-jetty instance
bundle exec rake hyacinth:setup:solr_cores # Copy required cores to newly-unpacked hydra-jetty instance
bundle exec rake jetty:start # Start jetty, which includes Fedora and Solr (running on port 8983 in the development environment). This will take a minute.
bundle exec rake hyacinth:fedora:reload_cmodels # Import required content models into Fedora (Note: It is safe to ignore any "404 Resource Not Found" output messages encountered during this step. These are expected because the content models do not already exist in Fedora and therefore cannot be found.)
bundle exec rake db:migrate # Run database migrations
bundle exec rake db:seed # Set up default data (including default users)
rails s -p 3000 # Start the application using rails server
```

Then navigate to http://localhost:3000 in your browser and sign in using the "Email" method.

When you're done, stop the rails server by pressing press ctrl + c and stop jetty by running:
```sh
bundle exec rake jetty:stop
```

### To start Hyacinth back up again after the first time setup, all you need to do is run:
```sh
bundle exec rake jetty:start # Start jetty
rails s -p 3000 # Start the application using rails server
```

**Default admin credentials:**

Email: hyacinth-admin@library.columbia.edu

Password: iamtheadmin

**To stop jetty later on, run:**

```sh
bundle exec rake jetty:stop
```

### Running Integration Tests (for developers):

Integration tests are great and we should run them.  Here's how:

```sh
bundle exec rake hyacinth:ci
```

Note 1: By default, jetty will run on port 8983 in the development environment and 9983 in the test environment.

Note 2: Hyacinth requires JavaScript for integration tests and uses the capybara and poltergrist gems.  You'll need to install PhantomJS and have it available on your PATH.
