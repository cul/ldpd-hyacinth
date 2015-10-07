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
        '<core name="hyacinth_' + env_name + '" instanceDir="hyacinth_test" />' + "\n" +
        '    <core name="hyacinth_hydra_' + env_name + '" instanceDir="hyacinth_hydra_test" />' + "\n" +
        '    <core name="uri_service_' + env_name + '" instanceDir="uri_service_test" />'
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
          'default_asset_home' => File.join(Rails.root, 'tmp/asset_home_' + env_name),
          'upload_directory' => File.join(Rails.root, 'tmp/upload_' + env_name),
          'publish_target_api_key_encryption_key' => 'some_encryption_key'
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
      
      # uri_service.yml
      uri_service_yml_file = File.join(Rails.root, 'config/uri_service.yml')
      FileUtils.touch(uri_service_yml_file) # Create if it doesn't exist
      uri_service_yml = YAML.load_file(uri_service_yml_file) || {}
      ['development', 'test'].each do |env_name|
        uri_service_yml[env_name] = {
          'local_uri_base' => 'http://id.library.columbia.edu/term/',
          'solr' => {
            'url' => 'http://localhost:' + (env_name == 'test' ? default_test_port : default_development_port).to_s + '/solr/uri_service_' + env_name,
            'pool_size' => 5,
            'pool_timeout' => 5000
          },
          'database' => {
            'adapter' => 'sqlite',
            'database' => 'db/' + env_name + '.sqlite3',
            'max_connections' => 5,
            'pool_timeout' => 5000
          }
        }
      end
      File.open(uri_service_yml_file, 'w') {|f| f.write uri_service_yml.to_yaml }
      
      # repository_cache.yml
      repository_cache_yml_file = File.join(Rails.root, 'config/repository_cache.yml')
      FileUtils.touch(repository_cache_yml_file) # Create if it doesn't exist
      repository_cache_yml = YAML.load_file(repository_cache_yml_file) || {}
      ['development', 'test'].each do |env_name|
        repository_cache_yml[env_name] = {
          'url' => 'http://localhost:3001',
          'username' => 'fake_user',
          'password' => 'fake_password',
        }
      end
      File.open(repository_cache_yml_file, 'w') {|f| f.write repository_cache_yml.to_yaml }

    end

    task :create_sample_digital_objects => :environment do

      test_project = Project.find_by(string_key: 'test')
      test_user = User.find_by(email: 'hyacinth-test@library.columbia.edu')

      number_of_records_to_create = 400
      counter = 0

      start_time = Time.now

      number_of_records_to_create.times {

        digital_object = DigitalObject::Item.new
        digital_object.projects << test_project
        digital_object.created_by = test_user
        digital_object.updated_by = test_user

        random_adj = RandomWord.adjs.next
        random_adj.capitalize if random_adj
        random_noun = RandomWord.nouns.next
        random_noun.capitalize if random_noun
        random_title = random_adj.to_s + ' ' + random_noun.to_s

        digital_object.update_dynamic_field_data(
          {
            'title' => [
              {
                'title_sort_portion' => random_title
              }
            ],
            'name' => [
              {
                'name_value' => Faker::Name.name
              },
              {
                'name_value' => Faker::Name.name
              }
            ],
            'note' => [
              {
                'note_value' => Faker::Lorem.paragraph
              }
            ]
          }
        )

        unless digital_object.save
          puts 'Errors: ' + digital_object.errors.inspect
        end

        counter += 1
        puts "Processed #{counter} of #{number_of_records_to_create}"

      }

      puts 'Done.  Took ' + (Time.now - start_time).to_s + ' seconds.'

    end

  end

end
