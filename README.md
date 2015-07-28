#Hyacinth

Your friendly, neighborhood metadata editor.

Supported Browsers:
- Chrome: 39+
- Firefox: 34+
- Safari: 7.1+
- Internet Explorer: 10+

### First Time Setup:
Hyacinth has the following dependencies:
- Ruby 1.9.3 or 2.x (tested with 1.9.3 and 2.1.3)
- Sqlite3 or MySQL (tested with MySQL 5.5)
- Apache Solr (tested with 4.9)
- Fedora 3.8.1

First, you'll need to import relevant content models into Fedora:
```sh
bundle exec rake hyacinth:fedora:reload_cmodels RAILS_ENV=development
```

Then run database migrations:
```sh
bundle exec rake db:drop RAILS_ENV=development; bundle exec rake db:create RAILS_ENV=development; bundle exec rake db:migrate RAILS_ENV=development
```

Then seed database with initial values:
```sh
bundle exec rake db:seed RAILS_ENV=development
```

### Running Integration Tests:

```sh
bundle exec rake hyacinth:ci
```

Note: Hyacinth requires JavaScript for integration tests and uses the capybara and poltergrist gems.  You'll need to install phantomjs and have it available on your PATH.
