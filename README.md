# Hyacinth 3

Your friendly neighborhood digital object management system.

## Supported browsers

- Chrome (any version released within the last year)
- Firefox (any version released within the last year)
- Safari (any version released within the last year)
- Edge (any version released within the last year)

## Requirements

- Ruby 2.5
- Sqlite3 or MySQL (tested with MySQL 5.5)
- Apache Solr 6.3
- Fedora 3.8.1 (for publishing)
- Java 8 (for Solr)

## First-Time Setup (for developers)

```
git clone https://github.com/cul/ldpd-hyacinth.git # Clone the repo
cd ldpd-hyacinth # Switch to the application directory
bundle install # Install gem dependencies
bundle exec rake db:migrate # Run database migrations
# TODO: Add other necessary steps as development continues
rails s -p 3000 # Start the application using rails server
```
And for faster React app recompiling during development, run this in a separate terminal window:

```
./bin/webpack-dev-server
```

Then navigate to http://localhost:3000 in your browser and sign in using the "Email" method.

### Default Admin User Credentials

**Email:** hyacinth-admin@library.columbia.edu<br/>
**Password:** iamtheadmin

## To start Hyacinth up again after the first time setup, all you need to do is run:

```
rails s -p 3000 # Start the application using rails server
```

Running The Continuous Integration Test Suite (for developers):
```
bundle exec rake hyacinth:ci
```
