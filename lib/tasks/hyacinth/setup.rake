namespace :hyacinth do
  namespace :setup do
    desc "Set up hyacinth config files"
    task :config_files do # rubocop:disable Rails/RakeEnvironment
      config_template_dir = Rails.root.join('config', 'templates')
      config_dir = Rails.root.join('config')
      Dir.foreach(config_template_dir) do |entry|
        next unless entry.end_with?('.yml')
        src_path = File.join(config_template_dir, entry)
        dst_path = File.join(config_dir, entry.gsub('.template', ''))
        if File.exist?(dst_path)
          puts Rainbow("File already exists (skipping): #{dst_path}").blue.bright + "\n"
        else
          FileUtils.cp(src_path, dst_path)
          puts Rainbow("Created file at: #{dst_path}").green
        end
      end
    end

    desc "Set up hyacinth core records (DigitalObjectType, XmlDatastream, etc.) "
    task default_users: :environment do
        puts 'Creating default user accounts...'
        YAML.load_file('config/default_user_accounts.yml').each {|user_entry, user_info|
          user = User.create!(
            uid: user_info['uid'],
            email: user_info['email'],
            first_name: user_info['first_name'],
            last_name: user_info['last_name'],
            # is_admin: user_info['is_admin'],
            account_type: user_info['account_type']
          )

          user.reload
          puts user.inspect
        }

        user = User.create!(
          uid: 'abc123',
          email: 'abc123@columbia.edu',
          first_name: 'ABC',
          last_name: '123',
          is_admin: true,
          account_type: 'service'
        )
        user.reload
          puts user.inspect
    end

    desc "Set up hyacinth core records (DigitalObjectType, User, XmlDatastream, etc.) "
    task core_records: :environment do
      # If there are no DigitalObjectTypes the system, run the setup code below.
      # This check is in place to ensure that this task is never run for an environment that
      # already ran the core record setup (because running it twice would be bad!).
      if DigitalObjectType.count == 0
        # Create default PidGenerator
        puts 'Creating default PidGenerator...'
        PidGenerator.create!(namespace: HYACINTH[:default_pid_generator_namespace])

        puts 'Creating default DigitalObjectTypes...'
        # Create DigitalObjectTypes
        DigitalObjectType.create!(string_key: 'item', display_label: 'Item', sort_order: 0)
        DigitalObjectType.create!(string_key: 'group', display_label: 'Group', sort_order: 1)
        DigitalObjectType.create!(string_key: 'asset', display_label: 'Asset', sort_order: 2)
        DigitalObjectType.create!(string_key: 'file_system', display_label: 'FileSystem', sort_order: 3)

        puts 'Creating default XmlDatastream...'
        # Create XmlDatastreams
        XmlDatastream.create(string_key: 'descMetadata', display_label: 'descMetadata',
          xml_translation: {
            "element" => "mods:mods",
            "attrs" => {
              "xmlns:xlink" => "http://www.w3.org/1999/xlink",
              "version" => "3.5",
              "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
              "xmlns:mods" => "http://www.loc.gov/mods/v3",
              "xsi:schemaLocation" => "http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd"
            },
            "content" => [
              {
                "yield" => "title"
              },
              {
                "yield" => "name"
              },
              {
                "element" => "mods:originInfo"
              }
            ]
          }.to_json
        )

        # Create DynamicFieldGroupCategories
        puts 'Creating default DynamicFieldGroupCategories...'
        dfc_descriptive_metadata = DynamicFieldGroupCategory.create!(display_label: 'Descriptive Metadata')
        dfc_identifiers = DynamicFieldGroupCategory.create!(display_label: 'Identifiers')
        dfc_physical_information = DynamicFieldGroupCategory.create!(display_label: 'Physical Information')
        dfc_location_and_holdings = DynamicFieldGroupCategory.create!(display_label: 'Location and Holdings')
        dfc_subject_data = DynamicFieldGroupCategory.create!(display_label: 'Subject Data')
        dfc_geographic_data = DynamicFieldGroupCategory.create!(display_label: 'Geographic Data')
        dfc_notes = DynamicFieldGroupCategory.create!(display_label: 'Notes')
        dfc_digitization = DynamicFieldGroupCategory.create!(display_label: 'Digitization')
        dfc_contextual_data = DynamicFieldGroupCategory.create!(display_label: 'Contextual Data')
        dfc_record_info = DynamicFieldGroupCategory.create!(display_label: 'Record Information')
        dfc_other = DynamicFieldGroupCategory.create!(display_label: 'Other')
        dfc_asset_data = DynamicFieldGroupCategory.create!(display_label: 'Asset Data')

        puts 'Creating default DynamicFieldGroups, DynamicFields and controlled vocabularies...'
        # Create core DynamicFieldGroups and DynamicFields
        title = DynamicFieldGroup.create!(string_key: 'title', display_label: 'Title', dynamic_field_group_category: dfc_descriptive_metadata, is_repeatable: false,
          xml_translation: {
            "element" => "mods:titleInfo",
            "content" => [
              {
                "element" => "mods:nonSort",
                "content" => "{{title_non_sort_portion}}"
              },
              {
                "element" => "mods:title",
                "content" => "{{title_sort_portion}}"
              }
            ]
          }.to_json
        )
        title.dynamic_fields.create!(string_key: 'title_non_sort_portion', display_label: 'Non-Sort Portion', dynamic_field_type: DynamicField::Type::STRING)
        title.dynamic_fields.create!(string_key: 'title_sort_portion', display_label: 'Sort Portion', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true, is_searchable_title_field: true)

        # Create various controlled vocabularies if they don't already exist
        {
          'collection' => 'Collection',
          'form' => 'Form',
          'genre' => 'Genre',
          'language' => 'Language',
          'location' => 'Location',
          'name' => 'Name',
            'name_role' => 'Name Role',
          'subject_geographic' => 'Subject Geographic',
          'subject_name' => 'Subject Name',
          'subject_temporal' => 'Subject Temporal',
          'subject_title' => 'Subject Title',
          'subject_topic' => 'Subject Topic'
          }.each do |string_key, display_label|
          if UriService.client.find_vocabulary(string_key).nil?
            @controlled_vocabulary = ControlledVocabulary.new
            @controlled_vocabulary.string_key = string_key
            @controlled_vocabulary.display_label = display_label
            @controlled_vocabulary.save
          end
        end

        #collection
        collection = DynamicFieldGroup.create!(string_key: 'collection', display_label: 'Collection', dynamic_field_group_category: dfc_descriptive_metadata)
        collection.dynamic_fields.create!(string_key: 'collection_term', display_label: 'Value', dynamic_field_type: DynamicField::Type::CONTROLLED_TERM, controlled_vocabulary_string_key: 'collection', is_facet_field: true, is_single_field_searchable: true, standalone_field_label: 'Collection')

        #form
        form = DynamicFieldGroup.create!(string_key: 'form', display_label: 'Form', dynamic_field_group_category: dfc_physical_information, is_repeatable: true)
        form.dynamic_fields.create!(string_key: 'form_term', display_label: 'Value', dynamic_field_type: DynamicField::Type::CONTROLLED_TERM, controlled_vocabulary_string_key: 'form', is_facet_field: true, standalone_field_label: 'Format')

        #location
        location = DynamicFieldGroup.create!(string_key: 'location', display_label: 'Location', dynamic_field_group_category: dfc_location_and_holdings, is_repeatable: true)
        location.dynamic_fields.create!(string_key: 'location_term', display_label: 'Value', dynamic_field_type: DynamicField::Type::CONTROLLED_TERM, controlled_vocabulary_string_key: 'location', is_facet_field: true, standalone_field_label: 'Location')

        #name
        name = DynamicFieldGroup.create!(string_key: 'name', display_label: 'Name', dynamic_field_group_category: dfc_descriptive_metadata, is_repeatable: true,
          xml_translation: {
            "element" => "mods:name",
            "attrs" => {
              "valueUri" => "{{name_term.uri}}"
            },
            "content" => [
              {
                "element" => "mods:namePart",
                "content" => "{{name_term.value}}"
              },
              {
                "yield" => "name_role"
              }
            ]
          }.to_json
        )
        name.dynamic_fields.create!(string_key: 'name_term', display_label: 'Value', dynamic_field_type: DynamicField::Type::CONTROLLED_TERM, controlled_vocabulary_string_key: 'name', is_facet_field: true, standalone_field_label: 'Name')
        # --> Child DynamicFieldGroups for name
        name_role = DynamicFieldGroup.create!(string_key: 'name_role', display_label: 'Role', is_repeatable: true, parent_dynamic_field_group: name,
          xml_translation: {
            "element" => "mods:role",
            "content" => [
              {
                "element" => "mods:roleTerm",
                "attrs" => {
                    "valueUri" => "{{name_role_term.uri}}"
                },
                "content" => "{{name_role_term.value}}"
              }
            ]
          }.to_json
        )
        name_role.dynamic_fields.create!(string_key: 'name_role_term', display_label: 'Value', dynamic_field_type: DynamicField::Type::CONTROLLED_TERM, controlled_vocabulary_string_key: 'name_role')

      end

      if DigitalObjectType.find_by(string_key: 'publish_target').nil?
        puts 'Creating default publish targets...'
        DigitalObjectType.create!(string_key: 'publish_target', display_label: 'Publish Target', sort_order: 4)
        publish_targets_project = Project.new(string_key: 'publish_targets', display_label: 'Publish Targets', pid_generator: PidGenerator.default_pid_generator)
        publish_targets_project.save
        # # Enable title field for publish targets
        dot_publish_target = DigitalObjectType.find_by(string_key: 'publish_target')
        # Enable title fields for Items, Groups and Assets
        (DynamicFieldGroup.find_by(string_key: 'title').dynamic_fields).each do |dynamic_field|
          publish_targets_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: dynamic_field, digital_object_type: dot_publish_target)
        end
      end
    end
  end
end
