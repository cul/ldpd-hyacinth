namespace :hyacinth do
  namespace :projects do

    # Durst namespace for Durst project tasks
    namespace :durst do

      task :setup => :environment do

        # Load certain records that we'll be referencing

        cul_pid_generator = PidGenerator.find_by(namespace: 'cul')

        dot_item = DigitalObjectType.find_by(string_key: 'item')
        dot_group = DigitalObjectType.find_by(string_key: 'group')
        dot_asset = DigitalObjectType.find_by(string_key: 'asset')

        desc_metadata_xml_ds = XmlDatastream.find_by(string_key: 'descMetadata')

        dfc_identifiers = DynamicFieldGroupCategory.find_by(display_label: 'Identifiers')
        dfc_descriptive_metadata = DynamicFieldGroupCategory.find_by(display_label: 'Descriptive Metadata')
        dfc_physical_information = DynamicFieldGroupCategory.find_by(display_label: 'Physical Information')
        dfc_location_and_holdings = DynamicFieldGroupCategory.find_by(display_label: 'Location and Holdings')
        dfc_subject_data = DynamicFieldGroupCategory.find_by(display_label: 'Subject Data')
        dfc_geographic_data = DynamicFieldGroupCategory.find_by(display_label: 'Geographic Data')
        dfc_notes = DynamicFieldGroupCategory.find_by(display_label: 'Notes')
        dfc_digitization = DynamicFieldGroupCategory.find_by(display_label: 'Digitization')
        dfc_contextual_data = DynamicFieldGroupCategory.find_by(display_label: 'Contextual Data')
        dfc_record_info = DynamicFieldGroupCategory.find_by(display_label: 'Record Information')
        dfc_other = DynamicFieldGroupCategory.find_by(display_label: 'Other')
        dfc_asset_data = DynamicFieldGroupCategory.find_by(display_label: 'Asset Data')




        # Create Durst project
        durst_project = Project.create!(string_key: 'durst', display_label: 'Durst', pid_generator: cul_pid_generator)

        possible_durst_user_file = File.join(Rails.root, '/config/durst_user_accounts.yml')
        if File.exists?(possible_durst_user_file)
          YAML.load_file(possible_durst_user_file).each {|service_user_entry, service_user_info|
            User.create!(
              :email => service_user_info['email'],
              :password => service_user_info['password'],
              :password_confirmation => service_user_info['password'],
              :first_name => service_user_info['first_name'],
              :last_name => service_user_info['last_name'],
              :is_admin => service_user_info['is_admin']
            )
          }
        end

        # Create AuthorizedTerms and add them to the correct ControlledVocabularies
        AuthorizedTerm.create!(
          value: 'Avery Architectural & Fine Arts Library, Columbia University',
          code: 'NNC-A',
          authority: 'marcorg',
          controlled_vocabulary: ControlledVocabulary.find_by(string_key: 'physical_location')
        )
        AuthorizedTerm.create!(
          value: 'Seymour B. Durst Old York Library Collection',
          controlled_vocabulary: ControlledVocabulary.find_by(string_key: 'collection')
        )

        # Create required dynamic fields that don't currently exist

        marc_005_last_modified = DynamicFieldGroup.create!(string_key: 'marc_005_last_modified', display_label: 'Marc 005 Last Modified', xml_datastream: nil, dynamic_field_group_category: dfc_other, is_repeatable: false,
          dynamic_fields: [DynamicField.new(string_key: 'marc_005_last_modified_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_single_field_searchable: true)]
        )

        alternative_title = DynamicFieldGroup.create!(string_key: 'alternative_title', display_label: 'Alternative Title', xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_descriptive_metadata, is_repeatable: true,
          dynamic_fields: [
            DynamicField.new(string_key: 'alternative_title_non_sort_portion', display_label: 'Non-Sort Portion', dynamic_field_type: DynamicField::Type::STRING),
            DynamicField.new(string_key: 'alternative_title_sort_portion', display_label: 'Sort Portion', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true, is_searchable_title_field: true)
          ]
        )

        abstract = DynamicFieldGroup.create!(string_key: 'abstract', display_label: 'Abstract', xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_descriptive_metadata, is_repeatable: false,
          dynamic_fields: [DynamicField.new(string_key: 'abstract_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::TEXTAREA, is_keyword_searchable: true)]
        )

        name = DynamicFieldGroup.create!(string_key: 'name', display_label: 'Name', xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_descriptive_metadata, is_repeatable: true,
          dynamic_fields: [
            DynamicField.new(string_key: 'name_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_facet_field: true, facet_field_label: 'Name', is_keyword_searchable: true, is_single_field_searchable: true),
            DynamicField.new(string_key: 'name_value_uri', display_label: 'Value URI', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_VALUE_URI, is_single_field_searchable: true),
            DynamicField.new(string_key: 'name_authority', display_label: 'Authority', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_AUTHORITY),
            DynamicField.new(string_key: 'name_authority_uri', display_label: 'Authority URI', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_AUTHORITY_URI)
          ]
        )
          # --> Start Child DynamicFieldGroups
            DynamicFieldGroup.create!(string_key: 'name_role', display_label: 'Role', is_repeatable: true, parent_dynamic_field_group: name, dynamic_fields: [
              DynamicField.new(string_key: 'name_role_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_single_field_searchable: true),
              DynamicField.new(string_key: 'name_role_type', display_label: 'Type', dynamic_field_type: DynamicField::Type::SELECT, is_single_field_searchable: true, additional_data_json: {
                select_options: [
                  {value: '', display_label: '- Select an Option -'},
                  {value: 'text', display_label: 'text'},
                  {value: 'code', display_label: 'code'}
                ]
              }.to_json)
            ])
          # --> End Child DynamicFieldGroups

        publisher = DynamicFieldGroup.create!(string_key: 'publisher', display_label: 'Publisher', xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_descriptive_metadata, is_repeatable: true,
          dynamic_fields: [DynamicField.new(string_key: 'publisher_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true, is_single_field_searchable: true)]
        )

        place_of_origin = DynamicFieldGroup.create!(string_key: 'place_of_origin', display_label: 'Place of Origin', xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_descriptive_metadata, is_repeatable: true,
          dynamic_fields: [DynamicField.new(string_key: 'place_of_origin_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true, is_single_field_searchable: true)]
        )

        date_other = DynamicFieldGroup.create!(string_key: 'date_other', display_label: 'Date Other', xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_descriptive_metadata, is_repeatable: true,
          dynamic_fields: [
            DynamicField.new(string_key: 'date_other_point', display_label: 'Point', dynamic_field_type: DynamicField::Type::SELECT, is_single_field_searchable: true, additional_data_json: {
              select_options: [
                {value: '', display_label: 'Single Point or Textual Date'},
                {value: 'start', display_label: 'start'},
                {value: 'end', display_label: 'end'}
              ]
            }.to_json),
            DynamicField.new(string_key: 'date_other_key_date', display_label: 'Key Date', dynamic_field_type: DynamicField::Type::SELECT, additional_data_json: {
              select_options: [
                {value: '', display_label: 'no'},
                {value: 'yes', display_label: 'yes'}
              ]
            }.to_json),
            DynamicField.new(string_key: 'date_other_value', display_label: 'Date', dynamic_field_type: DynamicField::Type::DATE, is_single_field_searchable: true),
            DynamicField.new(string_key: 'date_other_type', display_label: 'Type', dynamic_field_type: DynamicField::Type::SELECT, additional_data_json: {
              select_options: [
                {value: '', display_label: '- Not Specified -'},
                {value: 'approximate', display_label: 'Approximate'},
                {value: 'inferred', display_label: 'Inferred'},
                {value: 'questionable', display_label: 'Questionable'}
              ]
            }.to_json)
          ]
        )

        edition = DynamicFieldGroup.create!(string_key: 'edition', display_label: 'Edition', xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_descriptive_metadata, is_repeatable: false,
          dynamic_fields: [DynamicField.new(string_key: 'edition_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true, is_single_field_searchable: true)]
        )

        table_of_contents = DynamicFieldGroup.create!(string_key: 'table_of_contents', display_label: 'Table of Contents', xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_descriptive_metadata, is_repeatable: false,
          dynamic_fields: [DynamicField.new(string_key: 'table_of_contents_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::TEXTAREA, is_keyword_searchable: true)]
        )

        subject_topic = DynamicFieldGroup.create!(string_key: 'subject_topic', display_label: 'Subject Topic', xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_subject_data, is_repeatable: true,
          dynamic_fields: [
            DynamicField.new(string_key: 'subject_topic_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_facet_field: true, facet_field_label: 'Subject Topic', is_keyword_searchable: true, is_single_field_searchable: true),
            DynamicField.new(string_key: 'subject_topic_value_uri', display_label: 'Value URI', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_VALUE_URI, is_single_field_searchable: true),
            DynamicField.new(string_key: 'subject_topic_authority', display_label: 'Authority', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_AUTHORITY),
            DynamicField.new(string_key: 'subject_topic_authority_uri', display_label: 'Authority URI', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_AUTHORITY_URI)
          ]
        )

        subject_temporal = DynamicFieldGroup.create!(string_key: 'subject_temporal', display_label: 'Subject Temporal', xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_subject_data, is_repeatable: true,
          dynamic_fields: [
            DynamicField.new(string_key: 'subject_temporal_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_facet_field: true, facet_field_label: 'Subject Temporal', is_keyword_searchable: true, is_single_field_searchable: true),
            DynamicField.new(string_key: 'subject_temporal_value_uri', display_label: 'Value URI', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_VALUE_URI, is_single_field_searchable: true),
            DynamicField.new(string_key: 'subject_temporal_authority', display_label: 'Authority', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_AUTHORITY),
            DynamicField.new(string_key: 'subject_temporal_authority_uri', display_label: 'Authority URI', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_AUTHORITY_URI)
          ]
        )

        subject_name = DynamicFieldGroup.create!(string_key: 'subject_name', display_label: 'Subject Name', xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_subject_data, is_repeatable: true,
          dynamic_fields: [
            DynamicField.new(string_key: 'subject_name_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_facet_field: true, facet_field_label: 'Subject Name', is_keyword_searchable: true, is_single_field_searchable: true),
            DynamicField.new(string_key: 'subject_name_value_uri', display_label: 'Value URI', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_VALUE_URI, is_single_field_searchable: true),
            DynamicField.new(string_key: 'subject_name_authority', display_label: 'Authority', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_AUTHORITY),
            DynamicField.new(string_key: 'subject_name_authority_uri', display_label: 'Authority URI', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_AUTHORITY_URI)
          ]
        )

        subject_title = DynamicFieldGroup.create!(string_key: 'subject_title', display_label: 'Subject Title', xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_subject_data, is_repeatable: true,
          dynamic_fields: [
            DynamicField.new(string_key: 'subject_title_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_facet_field: true, facet_field_label: 'Subject Title', is_keyword_searchable: true, is_single_field_searchable: true),
            DynamicField.new(string_key: 'subject_title_value_uri', display_label: 'Value URI', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_VALUE_URI, is_single_field_searchable: true),
            DynamicField.new(string_key: 'subject_title_authority', display_label: 'Authority', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_AUTHORITY),
            DynamicField.new(string_key: 'subject_title_authority_uri', display_label: 'Authority URI', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_AUTHORITY_URI)
          ]
        )

        subject_geographic = DynamicFieldGroup.create!(string_key: 'subject_geographic', display_label: 'Subject Place', xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_geographic_data, is_repeatable: true,
          dynamic_fields: [
            DynamicField.new(string_key: 'subject_geographic_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_facet_field: true, facet_field_label: 'Subject Geographic', is_keyword_searchable: true, is_single_field_searchable: true),
            DynamicField.new(string_key: 'subject_geographic_value_uri', display_label: 'Value URI', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_VALUE_URI, is_single_field_searchable: true),
            DynamicField.new(string_key: 'subject_geographic_authority', display_label: 'Authority', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_AUTHORITY),
            DynamicField.new(string_key: 'subject_geographic_authority_uri', display_label: 'Authority URI', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_AUTHORITY_URI)
          ]
        )

        subject_hierarchical_geographic = DynamicFieldGroup.create!(string_key: 'subject_hierarchical_geographic', display_label: 'Subject Hierarchical Geographic', xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_geographic_data, is_repeatable: true)
          # --> Start Child DynamicFieldGroups
            DynamicFieldGroup.create!(string_key: 'subject_hierarchical_geographic_country', display_label: 'Country', parent_dynamic_field_group: subject_hierarchical_geographic, is_repeatable: false,
              dynamic_fields: [
                DynamicField.new(string_key: 'subject_hierarchical_geographic_country_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true)
              ]
            )
            DynamicFieldGroup.create!(string_key: 'subject_hierarchical_geographic_province', display_label: 'Province', parent_dynamic_field_group: subject_hierarchical_geographic, is_repeatable: false,
              dynamic_fields: [
                DynamicField.new(string_key: 'subject_hierarchical_geographic_province_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true)
              ]
            )
            DynamicFieldGroup.create!(string_key: 'subject_hierarchical_geographic_region', display_label: 'Region', parent_dynamic_field_group: subject_hierarchical_geographic, is_repeatable: false,
              dynamic_fields: [
                DynamicField.new(string_key: 'subject_hierarchical_geographic_region_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true)
              ]
            )
            DynamicFieldGroup.create!(string_key: 'subject_hierarchical_geographic_state', display_label: 'State', parent_dynamic_field_group: subject_hierarchical_geographic, is_repeatable: false,
              dynamic_fields: [
                DynamicField.new(string_key: 'subject_hierarchical_geographic_state_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true)
              ]
            )
            DynamicFieldGroup.create!(string_key: 'subject_hierarchical_geographic_county', display_label: 'County', parent_dynamic_field_group: subject_hierarchical_geographic, is_repeatable: false,
              dynamic_fields: [
                DynamicField.new(string_key: 'subject_hierarchical_geographic_county_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true)
              ]
            )
            DynamicFieldGroup.create!(string_key: 'subject_hierarchical_geographic_borough', display_label: 'Borough', parent_dynamic_field_group: subject_hierarchical_geographic, is_repeatable: false,
              dynamic_fields: [
                DynamicField.new(string_key: 'subject_hierarchical_geographic_borough_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true)
              ]
            )
            DynamicFieldGroup.create!(string_key: 'subject_hierarchical_geographic_city', display_label: 'City', parent_dynamic_field_group: subject_hierarchical_geographic, is_repeatable: false,
              dynamic_fields: [
                DynamicField.new(string_key: 'subject_hierarchical_geographic_city_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true)
              ]
            )
            DynamicFieldGroup.create!(string_key: 'subject_hierarchical_geographic_city_section', display_label: 'City Section', parent_dynamic_field_group: subject_hierarchical_geographic, is_repeatable: true,
              dynamic_fields: [
                DynamicField.new(string_key: 'subject_hierarchical_geographic_city_section_type', display_label: 'Type', dynamic_field_type: DynamicField::Type::SELECT, additional_data_json: {
                  select_options: [
                    {value: '', display_label: '- Not Specified -'},
                    {value: 'zip code', display_label: 'zip code'},
                    {value: 'street', display_label: 'street'},
                  ]
                }.to_json),
                DynamicField.new(string_key: 'subject_hierarchical_geographic_city_section_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true)
              ]
            )
          # --> End Child DynamicFieldGroups

        coordinates = DynamicFieldGroup.create!(string_key: 'coordinates', display_label: 'Coordinates', is_repeatable: true, xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_geographic_data,
          dynamic_fields: [
            DynamicField.new(string_key: 'coordinates_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true)
          ]
        )

        scale = DynamicFieldGroup.create!(string_key: 'scale', display_label: 'Scale', is_repeatable: true, xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_physical_information,
          dynamic_fields: [
            DynamicField.new(string_key: 'scale_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true)
          ]
        )

        genre = DynamicFieldGroup.create!(string_key: 'genre', display_label: 'Genre', is_repeatable: true, xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_descriptive_metadata,
          dynamic_fields: [
            DynamicField.new(string_key: 'genre_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true)
          ]
        )

        view_direction = DynamicFieldGroup.create!(string_key: 'view_direction', display_label: 'View Direction', is_repeatable: false, xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_notes, xml_extraction_priority: 1,
          dynamic_fields: [
            DynamicField.new(string_key: 'view_direction_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true)
          ]
        )

        note = DynamicFieldGroup.create!(string_key: 'note', display_label: 'Note', is_repeatable: true, xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_notes,
          dynamic_fields: [
            DynamicField.new(string_key: 'note_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::TEXTAREA, is_keyword_searchable: true),
            DynamicField.new(string_key: 'note_type', display_label: 'Type', dynamic_field_type: DynamicField::Type::STRING)
          ]
        )

        extent = DynamicFieldGroup.create!(string_key: 'extent', display_label: 'Extent', is_repeatable: true, xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_physical_information,
          dynamic_fields: [
            DynamicField.new(string_key: 'extent_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true)
          ]
        )

        orientation = DynamicFieldGroup.create!(string_key: 'orientation', display_label: 'Orientation', is_repeatable: false, xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_notes, xml_extraction_priority: 1,
          dynamic_fields: [
            DynamicField.new(string_key: 'orientation_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true)
          ]
        )

        series = DynamicFieldGroup.create!(string_key: 'series', display_label: 'Series', is_repeatable: true, xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_contextual_data,
          dynamic_fields: [
            DynamicField.new(string_key: 'series_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true)
          ]
        )

        box_title = DynamicFieldGroup.create!(string_key: 'box_title', display_label: 'Box Title', is_repeatable: false, xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_contextual_data,
          dynamic_fields: [
            DynamicField.new(string_key: 'box_title_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true)
          ]
        )

        group_title = DynamicFieldGroup.create!(string_key: 'group_title', display_label: 'Group Title', is_repeatable: false, xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_contextual_data,
          dynamic_fields: [
            DynamicField.new(string_key: 'group_title_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true)
          ]
        )

        clio_identifier = DynamicFieldGroup.create!(string_key: 'clio_identifier', display_label: 'CLIO ID', is_repeatable: true, xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_identifiers, xml_extraction_priority: 1,
          dynamic_fields: [
            DynamicField.new(string_key: 'clio_identifier_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_single_field_searchable: true, is_searchable_identifier_field: true)
          ]
        )

        dims_identifier = DynamicFieldGroup.create!(string_key: 'dims_identifier', display_label: 'DIMS ID', is_repeatable: true, xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_identifiers, xml_extraction_priority: 1,
          dynamic_fields: [
            DynamicField.new(string_key: 'dims_identifier_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_single_field_searchable: true, is_searchable_identifier_field: true)
          ]
        )

        local_durst_identifier = DynamicFieldGroup.create!(string_key: 'local_durst_identifier', display_label: 'Durst Postcard Identifier', is_repeatable: false, xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_identifiers, xml_extraction_priority: 1,
          dynamic_fields: [
            DynamicField.new(string_key: 'local_durst_identifier_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_single_field_searchable: true, is_searchable_identifier_field: true)
          ]
        )

        local_nnc_identifier = DynamicFieldGroup.create!(string_key: 'local_nnc_identifier', display_label: '[CUL-Assigned] Postcard Identifier', is_repeatable: false, xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_identifiers, xml_extraction_priority: 1,
          dynamic_fields: [
            DynamicField.new(string_key: 'local_nnc_identifier_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_single_field_searchable: true, is_searchable_identifier_field: true)
          ]
        )

        # This information will be available in any child items
        #filename_front_identifier = DynamicFieldGroup.create!(string_key: 'filename_front_identifier', display_label: 'Filename Front Identifier', is_repeatable: false, xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_identifiers, xml_extraction_priority: 1,
        #  dynamic_fields: [
        #    DynamicField.new(string_key: 'filename_front_identifier_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_single_field_searchable: true, is_searchable_identifier_field: true)
        #  ]
        #)
        #
        # This information will be available in any child items
        #filename_back_identifier = DynamicFieldGroup.create!(string_key: 'filename_back_identifier', display_label: 'Filename Back Identifier', is_repeatable: false, xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_identifiers, xml_extraction_priority: 1,
        #  dynamic_fields: [
        #    DynamicField.new(string_key: 'filename_back_identifier_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_single_field_searchable: true, is_searchable_identifier_field: true)
        #  ]
        #)

        isbn_identifier = DynamicFieldGroup.create!(string_key: 'isbn_identifier', display_label: 'ISBN', is_repeatable: false, xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_identifiers, xml_extraction_priority: 1,
          dynamic_fields: [
            DynamicField.new(string_key: 'isbn_identifier_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_single_field_searchable: true, is_searchable_identifier_field: true)
          ]
        )

        issn_identifier = DynamicFieldGroup.create!(string_key: 'issn_identifier', display_label: 'ISSN', is_repeatable: false, xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_identifiers, xml_extraction_priority: 1,
          dynamic_fields: [
            DynamicField.new(string_key: 'issn_identifier_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_single_field_searchable: true, is_searchable_identifier_field: true)
          ]
        )

        # TODO: This is temporary.  Location information should be stored in a set of nested DynamicFieldGroups.
        shelf_location = DynamicFieldGroup.create!(string_key: 'shelf_location', display_label: 'Shelf Location', is_repeatable: false, xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_location_and_holdings,
          dynamic_fields: [
            DynamicField.new(string_key: 'shelf_location_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true)
          ]
        )

        # TODO: This is temporary.  Location information should be stored in a set of nested DynamicFieldGroups.
        enumeration_and_chronology = DynamicFieldGroup.create!(string_key: 'enumeration_and_chronology', display_label: 'Enumeration and Chronology', is_repeatable: true, xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_location_and_holdings,
          dynamic_fields: [
            DynamicField.new(string_key: 'enumeration_and_chronology_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true)
          ]
        )

        # TODO: This is temporary.  Location information should be stored in a set of nested DynamicFieldGroups.
        sublocation = DynamicFieldGroup.create!(string_key: 'sublocation', display_label: 'Sublocation', is_repeatable: true, xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_location_and_holdings,
          dynamic_fields: [
            DynamicField.new(string_key: 'sublocation_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true)
          ]
        )

        url = DynamicFieldGroup.create!(string_key: 'url', display_label: 'URL', is_repeatable: true, xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_location_and_holdings,
          dynamic_fields: [
            DynamicField.new(string_key: 'url_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_single_field_searchable: true, is_searchable_identifier_field: true)
          ]
        )

        durst_favorite = DynamicFieldGroup.create!(string_key: 'durst_favorite', display_label: 'Durst Favorite', xml_datastream: nil, dynamic_field_group_category: dfc_other, is_repeatable: false,
          dynamic_fields: [
            DynamicField.new(string_key: 'durst_favorite_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::BOOLEAN, is_single_field_searchable: true)
          ]
        )

        type_of_resource = DynamicFieldGroup.create!(string_key: 'type_of_resource', display_label: 'Type of Resource', xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_other, is_repeatable: false,
          dynamic_fields: [
            DynamicField.new(string_key: 'type_of_resource_value', display_label: 'Type of Resource', dynamic_field_type: DynamicField::Type::SELECT, is_single_field_searchable: true, additional_data_json: {
              select_options: [
                {value: '', display_label: '- Select a type -'},
                {value: 'cartographic', display_label: 'cartographic'},
                {value: 'mixed material', display_label: 'mixed material'},
                {value: 'moving image', display_label: 'moving image'},
                {value: 'multimedia', display_label: 'multimedia'},
                {value: 'music', display_label: 'music'},
                {value: 'notated', display_label: 'notated'},
                {value: 'recording-nonmusical', display_label: 'recording-nonmusical'},
                {value: 'software', display_label: 'software'},
                {value: 'sound recording', display_label: 'sound recording'},
                {value: 'sound recording-musical', display_label: 'sound recording-musical'},
                {value: 'still image', display_label: 'still image'},
                {value: 'text', display_label: 'text'},
                {value: 'three dimensional object', display_label: 'three dimensional object'},
              ]
            }.to_json),
            DynamicField.new(string_key: 'type_of_resource_is_collection', display_label: 'Is Collection?', dynamic_field_type: DynamicField::Type::SELECT, is_single_field_searchable: true, additional_data_json: {
              select_options: [
                {value: '', display_label: 'no'},
                {value: 'yes', display_label: 'yes'},
              ]
            }.to_json)
          ]
        )

        record_content_source = DynamicFieldGroup.create!(string_key: 'record_content_source', display_label: 'Record Content Source (Institutional Record Creator)', xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_record_info, is_repeatable: false,
          dynamic_fields: [DynamicField.new(string_key: 'record_content_source_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_single_field_searchable: true)]
        )

        record_origin = DynamicFieldGroup.create!(string_key: 'record_origin', display_label: 'Record Origin', xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_descriptive_metadata, is_repeatable: false,
          dynamic_fields: [DynamicField.new(string_key: 'record_origin_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::TEXTAREA, is_keyword_searchable: true)]
        )

        language_of_cataloging = DynamicFieldGroup.create!(string_key: 'language_of_cataloging', display_label: 'Language of Cataloging', xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_record_info, is_repeatable: false,
          dynamic_fields: [DynamicField.new(string_key: 'language_of_cataloging_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_single_field_searchable: true)]
        )

        cul_scan_note = DynamicFieldGroup.create!(string_key: 'cul_scan_note', display_label: 'CUL Scan Note', xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_record_info, is_repeatable: false,
          dynamic_fields: [DynamicField.new(string_key: 'cul_scan_note_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::STRING, is_single_field_searchable: true)]
        )



        # Enable title fields for Items, Groups and Assets
        (DynamicFieldGroup.find_by(string_key: 'title').dynamic_fields).each do |dynamic_field|
          durst_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: dynamic_field, digital_object_type: dot_item)
          durst_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: dynamic_field, digital_object_type: dot_group)
          durst_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: dynamic_field, digital_object_type: dot_asset)
        end

        (
          DynamicFieldGroup.find_by(string_key: 'collection').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'form').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'physical_location').dynamic_fields +

          DynamicFieldGroup.find_by(string_key: 'marc_005_last_modified').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'alternative_title').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'abstract').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'name').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'name_role').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'publisher').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'place_of_origin').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'date_other').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'edition').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'table_of_contents').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'subject_topic').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'subject_temporal').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'subject_name').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'subject_title').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'subject_geographic').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'subject_hierarchical_geographic').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'subject_hierarchical_geographic_country').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'subject_hierarchical_geographic_province').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'subject_hierarchical_geographic_region').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'subject_hierarchical_geographic_state').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'subject_hierarchical_geographic_county').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'subject_hierarchical_geographic_borough').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'subject_hierarchical_geographic_city').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'subject_hierarchical_geographic_city_section').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'coordinates').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'scale').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'genre').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'view_direction').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'note').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'extent').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'orientation').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'series').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'box_title').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'group_title').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'clio_identifier').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'dims_identifier').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'local_durst_identifier').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'local_nnc_identifier').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'isbn_identifier').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'issn_identifier').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'shelf_location').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'enumeration_and_chronology').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'sublocation').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'url').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'durst_favorite').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'type_of_resource').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'record_content_source').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'record_origin').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'language_of_cataloging').dynamic_fields +
          DynamicFieldGroup.find_by(string_key: 'cul_scan_note').dynamic_fields
        ).each do |dynamic_field|
          durst_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: dynamic_field, digital_object_type: dot_item)
        end

        # TODO: Create PublishTarget for Test project

      end

    end
  end
end
