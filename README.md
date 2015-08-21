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

### First Time Setup:
```sh
git clone https://github.com/cul/hyacinth.git # Clone the repo
cd hyacinth # Switch to the application directory
bundle install # Install gem dependencies
bundle exec rake hyacinth:setup:config_files # Set up required config files
bundle exec rake db:migrate # Run database migrations
bundle exec rake jetty:clean # Download and unpack a new Hyacinth hydra-jetty instance
bundle exec rake jetty:start # Start jetty (which includes Fedora and Solr, running on port 9983)
bundle exec rake hyacinth:fedora:reload_cmodels # Import required content models into Fedora
bundle exec rake db:seed # Set up default data (including default users)
rails s -p 3000 # Start the application using rails server
```

Then navigate to http://localhost:3000 in your browser and log in using the "Email" method.

**Default admin credentials:**

Email: hyacinth-admin@library.columbia.edu

Password: iamtheadmin

**Stopping hydra-jetty:**

To stop jetty later on, run:

```sh
bundle exec rake jetty:start
```

### Running Integration Tests:

```sh
bundle exec rake hyacinth:ci
```

Note: Hyacinth requires JavaScript for integration tests and uses the capybara and poltergrist gems.  You'll need to install PhantomJS and have it available on your PATH.
