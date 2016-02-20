# Create default user accounts
YAML.load_file('config/default_user_accounts.yml').each {|service_user_entry, service_user_info|
  User.create!(
    :email => service_user_info['email'],
    :password => service_user_info['password'],
    :password_confirmation => service_user_info['password'],
    :first_name => service_user_info['first_name'],
    :last_name => service_user_info['last_name'],
    :is_admin => service_user_info['is_admin']
  )
}

# Create DigitalObjectTypes
DigitalObjectType.create!(string_key: 'item', display_label: 'Item', sort_order: 0)
DigitalObjectType.create!(string_key: 'group', display_label: 'Group', sort_order: 1)
DigitalObjectType.create!(string_key: 'asset', display_label: 'Asset', sort_order: 2)
DigitalObjectType.create!(string_key: 'file_system', display_label: 'FileSystem', sort_order: 3)

# Create CUL PidGenerator
PidGenerator.create!(namespace: HYACINTH['default_pid_generator_namespace'])

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

# Create core DynamicFieldGroups and DynamicFields
title = DynamicFieldGroup.create!(string_key: 'title', display_label: 'Title', dynamic_field_group_category: dfc_descriptive_metadata, is_repeatable: false,
  dynamic_fields: [
    DynamicField.new(string_key: 'title_non_sort_portion', display_label: 'Non-Sort Portion', dynamic_field_type: DynamicField::Type::STRING),
    DynamicField.new(string_key: 'title_sort_portion', display_label: 'Sort Portion', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true, is_searchable_title_field: true)
  ],
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
collection = DynamicFieldGroup.create!(string_key: 'collection', display_label: 'Collection', dynamic_field_group_category: dfc_descriptive_metadata,
  dynamic_fields: [
    DynamicField.new(string_key: 'collection_term', display_label: 'Value', dynamic_field_type: DynamicField::Type::CONTROLLED_TERM, controlled_vocabulary_string_key: 'collection', is_facet_field: true, is_single_field_searchable: true, standalone_field_label: 'Collection'),
    #DynamicField.new(string_key: 'collection_preferred_label', display_label: 'Preferred Label', dynamic_field_type: DynamicField::Type::STRING),
  ]
)

#form
form = DynamicFieldGroup.create!(string_key: 'form', display_label: 'Form', dynamic_field_group_category: dfc_physical_information, is_repeatable: true,
  dynamic_fields: [
    DynamicField.new(string_key: 'form_term', display_label: 'Value', dynamic_field_type: DynamicField::Type::CONTROLLED_TERM, controlled_vocabulary_string_key: 'form', is_facet_field: true, standalone_field_label: 'Format'),
    #DynamicField.new(string_key: 'form_preferred_label', display_label: 'Preferred Label', dynamic_field_type: DynamicField::Type::STRING),
  ]
)

#location
location = DynamicFieldGroup.create!(string_key: 'location', display_label: 'Location', dynamic_field_group_category: dfc_location_and_holdings, is_repeatable: true,
  dynamic_fields: [
    DynamicField.new(string_key: 'location_term', display_label: 'Value', dynamic_field_type: DynamicField::Type::CONTROLLED_TERM, controlled_vocabulary_string_key: 'location', is_facet_field: true, standalone_field_label: 'Location'),
    #DynamicField.new(string_key: 'location_preferred_label', display_label: 'Preferred Label', dynamic_field_type: DynamicField::Type::STRING),
  ]
)

#name
name = DynamicFieldGroup.create!(string_key: 'name', display_label: 'Name', dynamic_field_group_category: dfc_descriptive_metadata, is_repeatable: true,
  dynamic_fields: [
    DynamicField.new(string_key: 'name_term', display_label: 'Value', dynamic_field_type: DynamicField::Type::CONTROLLED_TERM, controlled_vocabulary_string_key: 'name', is_facet_field: true, standalone_field_label: 'Name'),
    #DynamicField.new(string_key: 'name_preferred_label', display_label: 'Preferred Label', dynamic_field_type: DynamicField::Type::STRING),
  ],
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
# --> Child DynamicFieldGroups for name
DynamicFieldGroup.create!(string_key: 'name_role', display_label: 'Role', is_repeatable: true, parent_dynamic_field_group: name,
  dynamic_fields: [
    DynamicField.new(string_key: 'name_role_term', display_label: 'Value', dynamic_field_type: DynamicField::Type::CONTROLLED_TERM, controlled_vocabulary_string_key: 'name_role')
  ],
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
