# Hyacinth

Your friendly, neighborhood metadata editor.

Supported Browsers:
- Chrome: 44+
- Firefox: 40+
- Safari: 8+
- Internet Explorer: 11+

### Requirements
Hyacinth 2.7.x has the following dependencies:
- Ruby 3.1 (tested with ruby 3.1.4)
- Sqlite3 or MySQL 8.x (tested with SQlite)
- Apache Solr (tested with 8.11)
- Fedora 3.8.x (though 3.8.1 is recommended because of a concurrent writing issue with 3.7 through 3.8.0)
- Docker (for development and testing)

Note: The Fedora ResourceIndex module must be turned on.  It is on by default in the docker image used by Hyacinth in development and test environments.

### First Time Setup:
```sh
git clone https://github.com/cul/hyacinth.git # Clone the repo
cd hyacinth # Switch to the application directory
bundle install # Install gem dependencies
bundle exec rake hyacinth:setup:config_files # Set up required config files
bundle exec rake hyacinth:docker:setup_config_files # Set up required Docker config files
bundle exec rake hyacinth:docker:start # Start docker (which includes Solr, Fedora, and Redis)
bundle exec rake hyacinth:fedora:reload_cmodels # Import required content models into Fedora (Note: It is safe to ignore any "404 Resource Not Found" output messages encountered during this step. These are expected because the content models do not already exist in Fedora and therefore cannot be found.)
bundle exec rake hyacinth:development:reset # Runs a bunch of other rake tasks to set up Hyacinth core data, including test projects
rails s -p 3000 # Start the application using rails server
yarn install # Install frontend dependencies
yarn start:dev # Start the Vite server
```

The setup above should start up a working instance of the application, but you may run into issues if you have other services running that use the same ports as Hyacinth and its Docker dependencies.  Check out `docker/docker-compose.development.yml` and `docker/docker-compose.test.yml` to see what ports are used (or if you haven't run the `hyacinth:docker:config_files` rake task yet, check out `docker/templates/docker-compose.development.yml` and `docker/templates/docker-compose.test.yml`).  You can modify these ports if you run into issues -- but if you do, you'll also need to update corresponding config/*.yml files to reference the updated ports.

Then navigate to http://localhost:3000 in your browser and sign in using the "Sign in with Developer UID" method.  On the screen that follows, just enter "admin" and click "Sign In".

**To stop docker later on, run:**

```sh
bundle exec rake hyacinth:docker:stop
```

### To start Hyacinth up again after the first time setup, all you need to do is run:
```sh
bundle exec rake hyacinth:docker:start # Start docker
rails s -p 3000 # Start the application using rails server
yarn start:dev # Start the Vite server
```

### Derivativo derivative generation and image thumbnails:

Hyacinth delegates image generation to a separate, asynchronous image processing application called "Derivativo," which can be found here: https://github.com/cul/ren-derivativo

Note: Hyacinth 2 is only compatible with Derivativo 1.x (NOT Derivativo 2.x).

If you want to run Derivativo locally, you'll need to modify your docker-compose.development.yml so that Fedora can read from your Hyacinth local file storage.  This is necessary because Derivativo 1.x reads 'content' and 'access' datastreams from Fedora and Fedora can't serve the content of these datastreams for files that exist outside of the Fedora docker development container.  Mounting your Hyacinth data directory in the Fedora docker container will fix this.  For example:

```
volumes:
  - fedora-data:/opt/fedora/data
  # Mount the Hyacinth development data directory (read-only) so that Fedora can read Hyacinth-managed files
  - /Users/elo2112/projects/hyacinth2/tmp/development:/Users/elo2112/projects/hyacinth2/tmp/development:ro
```

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

#### Testing out GitHub Actions locally (with `act`)

See: https://github.com/nektos/act

Quick setup:
- Download act with `brew install act`
- Run `act --container-architecture linux/amd64` on an M1 mac or just `act` on an x86_64 machine

### Other Development Notes

#### You can't use modern JS

Unfortunately, Hyacinth 2 is using an old version of Rails, and also an old version of the Uglifier JS compiler.  We'll be doing much more modern things in Hyacinth 3.  But for now, this means that if you try to use modern js (arrow functions, template literals, etc.), then Uglifier will raise an exception.  This happens when `rake assets:precompile` runs in production mode, during deployment.  When developing locally, you can troubleshoot issues with modern JS by running this in the Rails console:

```
2.6.10 :001 > Dir[Rails.root.join('app/assets/javascripts/**/*')].each {|file| next unless file.to_s.ends_with?('.js'); puts "Parsing #{file}"; Uglifier.compile(File.read(file)) }
```

The above line will iterate over all of the js files under `app/assets/javascripts` and try to run Uglifier on them.  If Uglifier runs into a file that can't be parsed, it'll raise an exception with info about where it got stuck.  Here's some example output:

```
...
...
...
Parsing /Users/elo2112/Columbia/Columbia-Projects/repositories/hyacinth-24-current/app/assets/javascripts/digital_objects_app/widgets/digital_object_synchronized_transcript_editor.js
Parsing /Users/elo2112/Columbia/Columbia-Projects/repositories/hyacinth-24-current/app/assets/javascripts/digital_objects_app/widgets/digital_object_transcript_editor.js
Parsing /Users/elo2112/Columbia/Columbia-Projects/repositories/hyacinth-24-current/app/assets/javascripts/digital_objects_app/widgets/digital_object_search.js
Traceback (most recent call last):
       16: from (irb):20:in `each'
       15: from (irb):20:in `block in irb_binding'
       14: from /Users/elo2112/.rvm/gems/ruby-2.6.10/gems/uglifier-2.7.0/lib/uglifier.rb:150:in `compile'
       13: from /Users/elo2112/.rvm/gems/ruby-2.6.10/gems/uglifier-2.7.0/lib/uglifier.rb:178:in `compile'
       12: from /Users/elo2112/.rvm/gems/ruby-2.6.10/gems/uglifier-2.7.0/lib/uglifier.rb:200:in `run_uglifyjs'
       11: from /Users/elo2112/.rvm/gems/ruby-2.6.10/gems/execjs-2.7.0/lib/execjs/external_runtime.rb:39:in `exec'
       10: from block_ ((execjs):2359:24599)
        9: from (execjs):2359:19957
        8: from (execjs):2359:20553
        7: from simple_statement ((execjs):2359:22580)
        6: from semicolon ((execjs):2359:19784)
        5: from unexpected ((execjs):2359:19311)
        4: from token_error ((execjs):2359:19223)
        3: from croak ((execjs):2359:19086)
        2: from js_error ((execjs):2359:10842)
        1: from new JS_Parse_Error ((execjs):2359:10623)
ExecJS::ProgramError (Unexpected token: name (a) (line: 256, col: 8, pos: 11480))
...
...
...
```

So in the above case, this means that we need to take a look at `/Users/elo2112/Columbia/Columbia-Projects/repositories/hyacinth-24-current/app/assets/javascripts/digital_objects_app/widgets/digital_object_search.js` because there was a parsing error on line `256`.


#### Intel MacOS Notes
If you installed mysql on macOS using homebrew, you may need to install mysql2 0.4.x with this command, otherwise you'll get an error (`dyld: lazy symbol binding failed: Symbol not found: _mysql_server_init`):

```
gem install mysql2 -v '0.4.10' -- --with-ldflags=-L/usr/local/opt/openssl/lib --with-cppflags=-I/usr/local/opt/openssl/include
```

#### ARM (M1/M2) MacOS Notes:

If Ruby 2.7.8 doesn't install for you, you may need to install it using this syntax:

`CFLAGS="-Wno-error=implicit-function-declaration" rvm install 2.7.8`

This was more of a problem with Ruby 2.4, so it may not be necessary for Ruby 2.7.

#### Ubuntu 22 setup notes

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
