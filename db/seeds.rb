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
dot_item = DigitalObjectType.create!(string_key: 'item', display_label: 'Item', sort_order: 0)
dot_group = DigitalObjectType.create!(string_key: 'group', display_label: 'Group', sort_order: 1)
dot_asset = DigitalObjectType.create!(string_key: 'asset', display_label: 'Asset', sort_order: 2)
dot_exhibition = DigitalObjectType.create!(string_key: 'exhibition', display_label: 'Exhibition', sort_order: 3)

# Create CUL PidGenerator
default_pid_generator = PidGenerator.create!(namespace: HYACINTH['default_pid_generator_namespace'])

# Create XmlDatastreams
desc_metadata_xml_ds = XmlDatastream.create(string_key: 'descMetadata', display_label: 'descMetadata',
  xml_translation_json: {
    'key' => 'value'
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

# Create ControlledVocabularies (and any pre-populated terms)
physical_location_controlled_vocabulary = ControlledVocabulary.create!(string_key: 'physical_location', display_label: 'Physical Location', pid_generator: default_pid_generator, authorized_terms: [])
collection_controlled_vocabulary = ControlledVocabulary.create!(string_key: 'collection', display_label: 'Collection', pid_generator: default_pid_generator, authorized_terms: [])

form_controlled_vocabulary = ControlledVocabulary.create!(string_key: 'form', display_label: 'Form', pid_generator: default_pid_generator, only_managed_by_admins: true, authorized_terms: [
  # From: https://wiki.cul.columbia.edu/display/metadata/Form+Terms
  AuthorizedTerm.new(value: 'albums', authority: 'aat', value_uri: 'http://id.loc.gov/vocabulary/graphicMaterials/tgm000229'),
  AuthorizedTerm.new(value: 'architectural drawings', authority: 'gmgpc', value_uri: 'http://id.loc.gov/vocabulary/graphicMaterials/tgm000455'),
  AuthorizedTerm.new(value: 'books', authority: 'aat', value_uri: 'http://id.loc.gov/vocabulary/graphicMaterials/tgm001221'),
  AuthorizedTerm.new(value: 'caricatures and cartoons', authority: 'lcsh', value_uri: 'http://id.loc.gov/authorities/subjects/sh99001244.html'),
  AuthorizedTerm.new(value: 'clippings', authority: 'gmgpc', value_uri: 'http://www.loc.gov/pictures/collection/tgm/item/tgm002169/'),
  AuthorizedTerm.new(value: 'corporation reports', authority: 'aat', value_uri: 'http://id.loc.gov/authorities/subjects/sh85032921.html'),
  AuthorizedTerm.new(value: 'correspondence', authority: 'aat', value_uri: 'http://vocab.getty.edu/aat/300026877'),
  AuthorizedTerm.new(value: 'drawings', authority: 'gmgpc', value_uri: 'http://id.loc.gov/vocabulary/graphicMaterials/tgm003279'),
  AuthorizedTerm.new(value: 'ephemera', authority: 'aat', value_uri: 'http://vocab.getty.edu/aat/300028881'),
  AuthorizedTerm.new(value: 'filmstrips', authority: 'aat', value_uri: 'http://vocab.getty.edu/aat/300028048'),
  AuthorizedTerm.new(value: 'illustrations', authority: 'gmgpc', value_uri: 'http://www.loc.gov/pictures/collection/tgm/item/tgm005314/'),
  AuthorizedTerm.new(value: 'lantern slides', authority: 'aat', value_uri: 'http://vocab.getty.edu/aat/300134977'),
  AuthorizedTerm.new(value: 'manuscripts', authority: 'lcsh', value_uri: 'http://id.loc.gov/authorities/subjects/sh85080672.html'),
  AuthorizedTerm.new(value: 'maps', authority: 'aat', value_uri: 'http://id.loc.gov/vocabulary/graphicMaterials/tgm006261'),
  AuthorizedTerm.new(value: 'minutes (administrative records)', authority: 'aat', value_uri: 'http://vocab.getty.edu/aat/300027440'),
  AuthorizedTerm.new(value: 'mixed materials', authority: 'local'),
  AuthorizedTerm.new(value: 'moving images', authority: 'aat', value_uri: 'http://vocab.getty.edu/aat/300263857'),
  AuthorizedTerm.new(value: 'music', authority: 'local'),
  AuthorizedTerm.new(value: 'negatives', authority: 'gmgpc', value_uri: 'http://id.loc.gov/vocabulary/graphicMaterials/tgm007029'),
  AuthorizedTerm.new(value: 'objects', authority: 'aat', value_uri: 'http://id.loc.gov/vocabulary/graphicMaterials/tgm007159'),
  AuthorizedTerm.new(value: 'oral histories', authority: 'local', value_uri: 'http://id.loc.gov/authorities/subjects/sh2008025718.html'),
  AuthorizedTerm.new(value: 'other', authority: 'local'),
  AuthorizedTerm.new(value: 'paintings', authority: 'gmgpc', value_uri: 'http://id.loc.gov/vocabulary/graphicMaterials/tgm007393'),
  AuthorizedTerm.new(value: 'pamphlets', authority: 'aat', value_uri: 'http://id.loc.gov/vocabulary/graphicMaterials/tgm007415'),
  AuthorizedTerm.new(value: 'papyri', authority: 'aat', value_uri: 'http://vocab.getty.edu/resource/aat/300055047'),
  AuthorizedTerm.new(value: 'periodicals', authority: 'aat', value_uri: 'http://id.loc.gov/vocabulary/graphicMaterials/tgm007641'),
  AuthorizedTerm.new(value: 'photographs', authority: 'aat', value_uri: 'http://id.loc.gov/vocabulary/graphicMaterials/tgm007721'),
  AuthorizedTerm.new(value: 'playing cards', authority: 'aat', value_uri: 'http://id.loc.gov/vocabulary/graphicMaterials/tgm007907'),
  AuthorizedTerm.new(value: 'postcards', authority: 'aat', value_uri: 'http://id.loc.gov/vocabulary/graphicMaterials/tgm008103'),
  AuthorizedTerm.new(value: 'posters', authority: 'aat', value_uri: 'http://id.loc.gov/vocabulary/graphicMaterials/tgm008104'),
  AuthorizedTerm.new(value: 'printed ephemera', authority: 'aat', value_uri: 'http://vocab.getty.edu/aat/300264821'),
  AuthorizedTerm.new(value: 'prints', authority: 'gmgpc', value_uri: 'http://id.loc.gov/vocabulary/graphicMaterials/tgm008237'),
  AuthorizedTerm.new(value: 'record covers', authority: 'aat', value_uri: 'http://vocab.getty.edu/aat/300247936'),
  AuthorizedTerm.new(value: 'scrapbooks', authority: 'aat', value_uri: 'http://id.loc.gov/vocabulary/graphicMaterials/tgm009266'),
  AuthorizedTerm.new(value: 'slides (photographs)', authority: 'aat', value_uri: 'http://vocab.getty.edu/resource/aat/300128371'),
  AuthorizedTerm.new(value: 'sound recordings', authority: 'aat', value_uri: 'http://id.loc.gov/vocabulary/graphicMaterials/tgm009874'),
  AuthorizedTerm.new(value: 'video recordings', authority: 'aat', value_uri: 'http://vocab.getty.edu/aat/300028682')
])

# Create core DynamicFieldGroups and DynamicFields
title = DynamicFieldGroup.create!(string_key: 'title', display_label: 'Title', xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_descriptive_metadata, is_repeatable: false,
  dynamic_fields: [
    DynamicField.new(string_key: 'title_non_sort_portion', display_label: 'Non-Sort Portion', dynamic_field_type: DynamicField::Type::STRING),
    DynamicField.new(string_key: 'title_sort_portion', display_label: 'Sort Portion', dynamic_field_type: DynamicField::Type::STRING, is_keyword_searchable: true, is_searchable_title_field: true)
  ]
)

collection = DynamicFieldGroup.create!(string_key: 'collection', display_label: 'Collection', xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_descriptive_metadata,
  dynamic_fields: [
    DynamicField.new(string_key: 'collection_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_VALUE, controlled_vocabulary: collection_controlled_vocabulary, is_facet_field: true, standalone_field_label: 'Collection'),
    DynamicField.new(string_key: 'collection_uri', display_label: 'Value URI', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_VALUE_URI),
    DynamicField.new(string_key: 'collection_authority', display_label: 'Authority', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_AUTHORITY),
    DynamicField.new(string_key: 'collection_authority_uri', display_label: 'Authority URI', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_AUTHORITY_URI)
  ]
)

form = DynamicFieldGroup.create!(string_key: 'form', display_label: 'Form', xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_physical_information, is_repeatable: true,
  dynamic_fields: [
    DynamicField.new(string_key: 'form_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_VALUE, controlled_vocabulary: form_controlled_vocabulary, is_facet_field: true, standalone_field_label: 'Format'),
    DynamicField.new(string_key: 'form_uri', display_label: 'Value URI', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_VALUE_URI),
    DynamicField.new(string_key: 'form_authority', display_label: 'Authority', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_AUTHORITY),
    DynamicField.new(string_key: 'form_authority_uri', display_label: 'Authority URI', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_AUTHORITY_URI)
  ]
)

physical_location = DynamicFieldGroup.create!(string_key: 'physical_location', display_label: 'Physical Location', xml_datastream: desc_metadata_xml_ds, dynamic_field_group_category: dfc_location_and_holdings,
  dynamic_fields: [
    DynamicField.new(string_key: 'physical_location_value', display_label: 'Value', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_VALUE, controlled_vocabulary: physical_location_controlled_vocabulary, is_facet_field: true, standalone_field_label: 'Physical Location'),
    DynamicField.new(string_key: 'physical_location_code', display_label: 'Code', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_CODE),
    DynamicField.new(string_key: 'physical_location_uri', display_label: 'Value URI', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_VALUE_URI),
    DynamicField.new(string_key: 'physical_location_authority', display_label: 'Authority', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_AUTHORITY),
    DynamicField.new(string_key: 'physical_location_authority_uri', display_label: 'Authority URI', dynamic_field_type: DynamicField::Type::AUTHORIZED_TERM_AUTHORITY_URI)
  ]
)

# Create the Exhibitions project, which is essential for publishing items
exhibitions_project = Project.create!(string_key: 'exhibitions', display_label: 'Exhibitions', pid_generator: default_pid_generator)
