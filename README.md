# Hyacinth 3

Your friendly neighborhood digital object management system.

## Supported browsers

- Chrome (any version released within the last year)
- Firefox (any version released within the last year)
- Safari (any version released within the last year)
- Edge (any version released within the last year)

## Requirements

- Ruby 3.0
- Node 12
- Sqlite3 or MySQL (tested with MySQL 5.5)
- Redis 4/5/6/7 (provided by Docker)
- Apache Solr 6.3 (provided by Docker)
- Fedora 3.8.1 (provided by Docker, only required for publishing)
- Docker (for development environment and running tests)

## First-Time Setup (for developers)

```
git clone git@github.com:cul/ldpd-hyacinth.git # Clone the repo
cd ldpd-hyacinth # Switch to the application directory
git checkout 3.x # Check out the branch for v3. If this has been merged to master this is no longer necessary.
# Note: Make sure rvm has selected the correct ruby version. You may need to move out of the directory and back into it force rvm to use the ruby version specified in .ruby_version.
bundle install # Install gem dependencies
yarn install # this assumes you have node and yarn installed (tested with Node 8 and Node 10)

# This next line does A LOT (see development.rake file for full details).
# It's completely safe to run for a brand new setup, but note that it will drop and recreate your currently-configured development database in an existing setup.
# It will also automatically start a copy of Redis/Solr/Fedora by internally running `bundle exec rake hyacinth:docker:start`.
bundle exec rake hyacinth:development:reset

# This is optional. Creates some sample projects, sample publish targets, and 21 basic sample records.
bundle exec rake hyacinth:sample_content:create

# Start the application using rails server
rails s -p 3000
```
And, in a separate terminal window, run this to start the webpack dev server:

```
./bin/webpacker-dev-server
```

Then navigate to http://localhost:3000 in your browser and sign in using the "Email" method.

### Default Admin User Credentials

**Email:** hyacinth-admin@library.columbia.edu<br/>
**Password:** iamtheadmin

### And when you're done developing for the day, run:

```
bundle exec rake hyacinth:docker:stop # Stop Redis/Solr/Fedora
```

## To run Hyacinth locally again after the first time setup, all you need to do is run:

```
bundle exec rake hyacinth:docker:start # Start Redis/Solr/Fedora in the background
rails s -p 3000 # Start the application using rails server

# In a separate terminal window:
./bin/webpacker-dev-server # Start the webpack dev server
```

### And if you want to wipe our your local Solr cores, Fedora 3 data, and Redis data, run:

```
bundle exec rake hyacinth:docker:delete_volumes
```

### But it's usually better to use the hyacinth:development:reset task if you want to clear out all data and star from a fresh state:

```
# Remember, the command below also runs `bundle exec rake solr:start` (so that solr is available during digital object cleanup and setup), so don't forget to shut solr down when you're done with it.
bundle exec rake hyacinth:development:reset
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

## Development / WebPack

For performance in the deployed app and in system/feature tests, the non-development environments use chunked webpacks. There are some named chunks that are loaded dynamically in components to isolate large, rarely changing dependencies:
- fontAwesome: used to isolate the *FontAwesomeIcon* component and associated dependencies
- CSS is extracted

Please be careful not to `import` these components outside of a runtime function to prevent unnecessary loading of their dependencies! Use their lazy wrappers. For more information about React and webpack code-splitting, see: https://reactjs.org/docs/code-splitting.html

The CI suite expects that you have built the test packs. This happens automatically if you include an environment variable:

```bash
bundle exec rake hyacinth:ci WEBPACKER_RECOMPILE=true
```

You can also precompile it to save time if you are not working in the js app:
```bash
RAILS_ENV=test bundle exec rake webpacker:clobber webpacker:compile
bundle exec rake hyacinth:ci
```

If you *are* working on the js app, you can build and analyze the production packs from your development machine:
```bash
NODE_ENV=production RAILS_ENV=production bin/webpacker --profile --json > tmp/webpack-stats.json
npx webpack-bundle-analyzer tmp/webpack-stats.json public/packs
```
This will open a browser window with a treemap of chunked dependencies and size information.

## Development / IDE Notes

If you have an IDE that supports jsconfig.json files (e.g. Visual Studio Code), you can add the following (git ignored) jsconfig.json file to your local copy (top level) and it will enable js auto-imports:

```
{
  "compilerOptions": {
    "baseUrl": "app/javascript",
    "module": "commonjs",
    "target": "es2017",
    "jsx": "react",
    "checkJs": true,
  },
  "include": [
    "app/javascript"
  ]
}
```

Note that you may occasionally need to use a `// @ts-ignore` comment above certain lines in JS files when typescript complains about types.

## Development / Rubocop

When regenerating our .rubocop_todo.yml file, we use this command:
```
rubocop --auto-gen-config --auto-gen-only-exclude --exclude-limit 10000
```
