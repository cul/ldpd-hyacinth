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
git clone git@github.com:cul/ldpd-hyacinth.git # Clone the repo
cd ldpd-hyacinth # Switch to the application directory
git checkout 3.x # Check out the branch for v3. If this has been merged to master this is no longer necessary.
# Note: Make sure rvm has selected the correct ruby version. You may need to move out of the directory and back into it force rvm to use the ruby version specified in .ruby_version.
bundle install # Install gem dependencies
yarn install # this assumes you have node and yarn installed (tested with Node 8 and Node 10)
bundle exec rake hyacinth:setup:config_files # Set up hyacinth config files like hyacinth.yml and database.yml
bundle exec rake db:migrate # Run database migrations
bundle exec rake hyacinth:setup:default_users # Set up default Hyacinth users
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

## Testing
Our testing suite runs Rubocop, starts up Fedora and Solr, and then runs all of our ruby tests. Travis CI will automatically run the test suite for every commit and pull request.

To run the continuous integration test suite locally on your machine run:
```
bundle exec rake hyacinth:ci
```

## Deployment
We use Capistrano for deployment. To deploy to our temporary dev instance run:
```
cap hyacinth_3_dev deploy
```
