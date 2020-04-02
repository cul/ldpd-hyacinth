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
bundle exec rake hyacinth:rights_fields:load # Set up rights fields
bundle exec rake solr:start # Start a local solr server in the background
bundle exec rake jetty:start # Start a local jetty server for Fedora 3 in the background
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

### And when you're done developing for the day, run:

```
bundle exec rake solr:stop # Stop local solr
bundle exec rake jetty:stop # Stop local jetty / Fedora 3
```

## To run Hyacinth locally again after the first time setup, all you need to do is run:

```
bundle exec rake solr:start # Start a local solr server in the background
bundle exec rake jetty:start # Start a local jetty server for Fedora 3 in the background
rails s -p 3000 # Start the application using rails server
```

### And if you want to wipe our your local solr core and Fedora 3 instance, run:

```
bundle exec rake solr:clean # Wipe out and regenerate solr
bundle exec rake jetty:clean # Wipe out and regenerate jetty / Fedora 3
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

## Development / Naming Conventions

For JavaScript files:
- PascalCase.js for a file that exports a default constant that matches the file's capital-starting name (like a component)
- camelCase.js for a file that exports a default constant that matches that file's lower-starting name (like an exported plain function or variable) OR files that do not export a default constant
- snake_case for directories, to differentiate from js objects (convenient when searching through files and directories)

## Development / IDE Notes

If you have an IDE that supports jsconfig.json files (e.g. Visual Studio Code), you can add the following (git ignored) jsconfig.json file to your local copy (top level) and it will enable js import autocomplete for the @hyacinth_v1 alias:

```
{
  "compilerOptions": {
    "baseUrl": "app/javascript",
    "jsx": "react",
    "paths": {
      "@hyacinth_v1/*" : ["hyacinth_v1/*"]
    }
  },
  "include": [
    "app/javascript/**/*"
  ]
}
```

## Development / Rubocop

When regenerating our .rubocop_todo.yml file, we use this command:
```
rubocop --auto-gen-config --auto-gen-only-exclude --exclude-limit 10000
```

## Development / Running Local Development Solr While Running CI Tests
During development, it's often convenient to use the built-in solr rake task to run a local solr instance:
```
# start development solr
bundle exec rake solr:start

# stop development solr
bundle exec rake solr:stop
```

This development solr runs on a port specified in config/solr_wrapper.yml (8983 by default).

When you run the CI task (`bundle exec rake hyacinth:ci`), it temporarily spins up another solr in parallel while running tests, and this runs on a separate port (8993 by default).

One important thing to know is that solr's built-in start script defines a separate port for solr to listen on for stop commands, and this port is equal to your selected port **MINUS 1000**.  This normally isn't an issue, but note that if you set config/solr_wrapper.yml values for your development and test environments that are exactly 1000 apart, you'll run into problems.  So, for example, don't set the development port to 8983 and the test port to 9983.

This also means that you shouldn't set your solr ports to anything that conflicts with other running services.  If you development rails server runs on port 3000, don't set solr to run on port 4000.
