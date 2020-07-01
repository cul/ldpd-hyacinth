# frozen_string_literal: true

module DynamicFieldsHelper
  module_function

  def load_sample_item_rights_fields!
    rights_fields = {
      dynamic_field_categories: [
        {
          display_label: "Item Rights",
          metadata_form: 'item_rights',
          dynamic_field_groups: [
            {
              string_key: 'copyright_status',
              display_label: 'Copyright Status',
              dynamic_fields: [
                { string_key: 'copyright_statement', display_label: 'Copyright Statement', field_type: DynamicField::Type::CONTROLLED_TERM, controlled_vocabulary: 'rights_statement' },
                { string_key: 'note', display_label: 'Note', field_type: DynamicField::Type::TEXTAREA },
                { string_key: 'copyright_expiration_date', display_label: 'Copyright Expiration Date', field_type: DynamicField::Type::DATE }
              ]
            }
          ]
        }
      ]
    }

    Hyacinth::DynamicFieldsLoader.load_fields!(rights_fields)
  end

  def load_title_fields!
    title_fields = {
      dynamic_field_categories: [
        {
          display_label: "Descriptive Metadata",
          dynamic_field_groups: [
            {
              string_key: 'title',
              display_label: 'Title',
              dynamic_fields: [
                { string_key: 'sort_portion', display_label: 'Sort Portion', field_type: DynamicField::Type::STRING },
                { string_key: 'non_sort_portion', display_label: 'Non-Sort Portion', field_type: DynamicField::Type::STRING }
              ]
            }
          ]
        }
      ]
    }

    Hyacinth::DynamicFieldsLoader.load_fields!(title_fields)
  end

  def load_abstract_fields!
    abstract_fields = {
      dynamic_field_categories: [
        {
          display_label: "Descriptive Metadata",
          dynamic_field_groups: [
            {
              string_key: 'abstract',
              display_label: 'Abstract',
              dynamic_fields: [
                { string_key: 'value', display_label: 'Value', field_type: DynamicField::Type::STRING }
              ]
            }
          ]
        }
      ]
    }

    Hyacinth::DynamicFieldsLoader.load_fields!(abstract_fields)
  end

  def load_name_fields!
    name_fields = {
      dynamic_field_categories: [
        {
          display_label: "Descriptive Metadata",
          dynamic_field_groups: [
            {
              string_key: 'name',
              display_label: 'Name',
              dynamic_fields: [
                { string_key: 'term', display_label: 'Value', field_type: DynamicField::Type::CONTROLLED_TERM, controlled_vocabulary: 'name', is_keyword_searchable: true },
                { string_key: 'is_primary', display_label: 'Is Primary?', field_type: DynamicField::Type::BOOLEAN }
              ],
              dynamic_field_groups: [
                {
                  string_key: 'role',
                  display_label: 'Role',
                  dynamic_fields: [
                    { string_key: 'term', display_label: 'Value', field_type: DynamicField::Type::CONTROLLED_TERM, controlled_vocabulary: 'name_role' }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }

    Hyacinth::DynamicFieldsLoader.load_fields!(name_fields)
  end

  def load_alternate_title_fields!
    alternate_title_fields = {
      dynamic_field_categories: [
        {
          display_label: "Descriptive Metadata",
          dynamic_field_groups: [
            {
              string_key: 'alternate_title',
              display_label: 'Alternate Title',
              dynamic_fields: [
                { string_key: 'value', display_label: 'Value', field_type: DynamicField::Type::STRING, is_keyword_searchable: true, is_title_searchable: true }
              ]
            }
          ]
        }
      ]
    }

    Hyacinth::DynamicFieldsLoader.load_fields!(alternate_title_fields)
  end

  def load_isbn_fields!
    isbn_fields = {
      dynamic_field_categories: [
        {
          display_label: "Descriptive Metadata",
          dynamic_field_groups: [
            {
              string_key: 'isbn',
              display_label: 'ISBN',
              dynamic_fields: [
                { string_key: 'value', display_label: 'Value', field_type: DynamicField::Type::STRING, is_identifier_searchable: true }
              ]
            }
          ]
        }
      ]
    }

    Hyacinth::DynamicFieldsLoader.load_fields!(isbn_fields)
  end
end
