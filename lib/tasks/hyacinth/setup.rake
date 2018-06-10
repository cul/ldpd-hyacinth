namespace :hyacinth do

  namespace :setup do

    task :solr_cores do
      env_name = ENV['RAILS_ENV'] || 'development'

      ## Copy cores ##
      FileUtils.cp_r('spec/fixtures/solr_cores/hyacinth', File.join(Jettywrapper.jetty_dir, 'solr'))
      FileUtils.mv(File.join(Jettywrapper.jetty_dir, 'solr/hyacinth'), File.join(Jettywrapper.jetty_dir, 'solr/hyacinth_' + env_name))
      FileUtils.cp_r('spec/fixtures/solr_cores/hyacinth_hydra', File.join(Jettywrapper.jetty_dir, 'solr'))
      FileUtils.mv(File.join(Jettywrapper.jetty_dir, 'solr/hyacinth_hydra'), File.join(Jettywrapper.jetty_dir, 'solr/hyacinth_hydra_' + env_name))
      FileUtils.cp_r('spec/fixtures/solr_cores/uri_service', File.join(Jettywrapper.jetty_dir, 'solr'))
      FileUtils.mv(File.join(Jettywrapper.jetty_dir, 'solr/uri_service'), File.join(Jettywrapper.jetty_dir, 'solr/uri_service_' + env_name))
      ## Copy solr.xml template ##
      FileUtils.cp_r('spec/fixtures/solr.xml', File.join(Jettywrapper.jetty_dir, 'solr'))

      # Update solr.xml configuration file so that it recognizes this code
      solr_xml_data = File.read(File.join(Jettywrapper.jetty_dir, 'solr/solr.xml'))
      solr_xml_data.gsub!('<!-- ADD CORES HERE -->',
        '<core name="hyacinth_' + env_name + '" instanceDir="hyacinth_' + env_name + '" />' + "\n" +
        '    <core name="hyacinth_hydra_' + env_name + '" instanceDir="hyacinth_hydra_' + env_name + '" />' + "\n" +
        '    <core name="uri_service_' + env_name + '" instanceDir="uri_service_' + env_name + '" />'
      )
      File.open(File.join(Jettywrapper.jetty_dir, 'solr/solr.xml'), 'w') { |file| file.write(solr_xml_data) }
    end

    # Note: Don't include Rails environment for this task, since enviroment includes a check for the presence of database.yml
    task :config_files do

      # Set up files
      default_development_port = 8983
      default_test_port = 9983

      # database.yml
      database_yml_file = File.join(Rails.root, 'config/database.yml')
      FileUtils.touch(database_yml_file) # Create if it doesn't exist
      database_yml = YAML.load_file(database_yml_file) || {}
      ['development', 'test'].each do |env_name|
        database_yml[env_name] = {
          'adapter' => 'sqlite3',
          'database' => 'db/' + env_name + '.sqlite3',
          'pool' => 5,
          'timeout' => 5000
        }
      end
      File.open(database_yml_file, 'w') {|f| f.write database_yml.to_yaml }

      # fedora.yml
      fedora_yml_file = File.join(Rails.root, 'config/fedora.yml')
      FileUtils.touch(fedora_yml_file) # Create if it doesn't exist
      fedora_yml = YAML.load_file(fedora_yml_file) || {}
      ['development', 'test'].each do |env_name|
        fedora_yml[env_name] = {
          :user => 'fedoraAdmin',
          :password => 'fedoraAdmin',
          :url => 'http://localhost:' + (env_name == 'test' ? default_test_port : default_development_port).to_s + (env_name == 'test' ? '/fedora-test' : '/fedora'),
          :time_zone => 'America/New_York'
        }
      end
      File.open(fedora_yml_file, 'w') {|f| f.write fedora_yml.to_yaml }

      # hyacinth.yml
      hyacinth_yml_file = File.join(Rails.root, 'config/hyacinth.yml')
      FileUtils.touch(hyacinth_yml_file) # Create if it doesn't exist
      hyacinth_yml = YAML.load_file(hyacinth_yml_file) || {}
      ['development', 'test'].each do |env_name|
        hyacinth_yml[env_name] = {
          'solr_url' => 'http://localhost:' + (env_name == 'test' ? default_test_port : default_development_port).to_s + '/solr/' + 'hyacinth_' + env_name,
          'default_pid_generator_namespace' => 'cul',
          'data_directory' => File.join(Rails.root, 'tmp/data_' + env_name),
          'default_asset_home' => File.join(Rails.root, 'tmp/asset_home_' + env_name),
          'upload_directory' => File.join(Rails.root, 'tmp/upload_' + env_name),
          'csv_export_directory' => File.join(Rails.root, 'tmp/csv_exports_' + env_name),
          'processed_csv_import_directory' => File.join(Rails.root, 'tmp/processed_csv_imports_' + env_name),
          'publish_target_api_key_encryption_key' => 'some_encryption_key',
          'treat_fedora_resource_index_updates_as_immediate' => false,
          'queue_long_jobs' => (env_name == 'development' || env_name == 'test') ? false : true,
          'time_zone' => 'America/New_York',
          'solr_commit_after_each_csv_import_row' => true
        }
      end
      File.open(hyacinth_yml_file, 'w') {|f| f.write hyacinth_yml.to_yaml }

      # secrets.yml
      secrets_yml_file = File.join(Rails.root, 'config/secrets.yml')
      FileUtils.touch(secrets_yml_file) # Create if it doesn't exist
      secrets_yml = YAML.load_file(secrets_yml_file) || {}
      ['development', 'test'].each do |env_name|
        secrets_yml[env_name] = {
          'secret_key_base' => SecureRandom.hex(64),
          'session_store_key' =>  '_hyacinth_' + env_name + '_session_key'
        }
      end
      File.open(secrets_yml_file, 'w') {|f| f.write secrets_yml.to_yaml }

      # solr.yml
      solr_yml_file = File.join(Rails.root, 'config/solr.yml')
      FileUtils.touch(solr_yml_file) # Create if it doesn't exist
      solr_yml = YAML.load_file(solr_yml_file) || {}
      ['development', 'test'].each do |env_name|
        solr_yml[env_name] = {
          'url' => 'http://localhost:' + (env_name == 'test' ? default_test_port : default_development_port).to_s + '/solr/hyacinth_hydra_' + env_name
        }
      end
      File.open(solr_yml_file, 'w') {|f| f.write solr_yml.to_yaml }

      # term_additional_fields.yml
      term_additional_fields_yml_file = File.join(Rails.root, 'config/term_additional_fields.yml')
      FileUtils.touch(term_additional_fields_yml_file) # Create if it doesn't exist
      term_additional_fields_yml = YAML.load_file(term_additional_fields_yml_file) || {}
      ['development', 'test'].each do |env_name|
        term_additional_fields_yml[env_name] = {
          'collection' => {
            'clio_id' => {
              'display_label' => 'CLIO ID'
            }
          },
          'location' => {
            'code' => {
              'display_label' => 'Code'
            }
          },
          'name' => {
            'name_type' => {
              'display_label' => 'Name Type'
            }
          }
        }

      end
      File.open(term_additional_fields_yml_file, 'w') {|f| f.write term_additional_fields_yml.to_yaml }

      # uri_service.yml
      uri_service_yml_file = File.join(Rails.root, 'config/uri_service.yml')
      FileUtils.touch(uri_service_yml_file) # Create if it doesn't exist
      uri_service_yml = YAML.load_file(uri_service_yml_file) || {}
      ['development', 'test'].each do |env_name|
        uri_service_yml[env_name] = {
          'local_uri_base' => 'http://id.library.columbia.edu/term/',
          'temporary_uri_base' => 'temp:',
          'solr' => {
            'url' => 'http://localhost:' + (env_name == 'test' ? default_test_port : default_development_port).to_s + '/solr/uri_service_' + env_name,
            'pool_size' => 5,
            'pool_timeout' => 5000
          },
          'database' => {
            'adapter' => 'sqlite',
            'database' => 'db/uri_service_' + env_name + '.sqlite3',
            'max_connections' => 5,
            'pool_timeout' => 5000
          }
        }
      end
      File.open(uri_service_yml_file, 'w') {|f| f.write uri_service_yml.to_yaml }

      # image_server.yml
      image_server_yml_file = File.join(Rails.root, 'config/image_server.yml')
      FileUtils.touch(image_server_yml_file) # Create if it doesn't exist
      image_server_yml = YAML.load_file(image_server_yml_file) || {}
      ['development', 'test'].each do |env_name|
        image_server_yml[env_name] = {
          'url' => 'http://localhost:3001',
          'username' => 'fake_user',
          'password' => 'fake_password',
        }
      end
      File.open(image_server_yml_file, 'w') {|f| f.write image_server_yml.to_yaml }

      # redis.yml
      redis_yml_file = File.join(Rails.root, 'config/redis.yml')
      FileUtils.touch(redis_yml_file) # Create if it doesn't exist
      redis_yml = YAML.load_file(redis_yml_file) || {}
      ['development', 'test'].each do |env_name|
        redis_yml[env_name] = {
          'host' => 'localhost',
          'port' => 6379,
          'namespace' => 'hyacinth_local_' + env_name
        }
      end
      File.open(redis_yml_file, 'w') {|f| f.write redis_yml.to_yaml }

      # resque.yml
      resque_yml_file = File.join(Rails.root, 'config/resque.yml')
      FileUtils.touch(resque_yml_file) # Create if it doesn't exist
      resque_yml = YAML.load_file(resque_yml_file) || {}
      ['development', 'test'].each do |env_name|
        resque_yml[env_name] = {
          'workers' => 1
        }
      end
      File.open(resque_yml_file, 'w') {|f| f.write resque_yml.to_yaml }

      # ezid.yml
      #
      # 'ezid_test_user', 'ezid_test_password', and 'ezid_test_shoulder'
      # contain the official EZID test credentials and test shoulder
      #
      # 'user', 'password', and 'shoulder' contain the actual
      # credentials and shoulder. By default in development and
      # test, these are set to the EZID test credentials and shoulder
      #
      ezid_yml_file = File.join(Rails.root, 'config/ezid.yml')
      FileUtils.touch(ezid_yml_file) # Create if it doesn't exist
      ezid_yml = YAML.load_file(ezid_yml_file) || {}
      ['development', 'test'].each do |env_name|
        ezid_yml[env_name] = {
          'user' => 'apitest',
          'password' => 'apitest',
          'shoulder' => {
            'ark' => 'ark:99999/fk4',
            'doi' => 'doi:10.5072/FK2'
          },
          'ezid_test_user' => 'apitest',
          'ezid_test_password' => 'apitest',
          'ezid_test_shoulder' => {
            'ark' => 'ark:99999/fk4',
            'doi' => 'doi:10.5072/FK2'
          },
          'url' => 'https://ezid.cdlib.org',
          'ezid_publisher' => 'Columbia University',
	        'datacite' => {
	          'genre_to_resource_type_mapping' => {
              'http://vocab.getty.edu/aat/300048715' => {
                'attribute_general' => 'Text',
                'content' => 'Article'
              }
            }
          }
        }
      end
      File.open(ezid_yml_file, 'w') {|f| f.write ezid_yml.to_yaml }
    end

  end

end
