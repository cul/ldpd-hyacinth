# frozen_string_literal: true

module DynamicFieldsHelper
  module_function

  def fields_for_category_definitions(field_definitions)
    fields = []
    field_definitions[:dynamic_field_categories].each do |category_config|
      display_label = category_config.delete(:display_label)
      dynamic_field_groups = category_config.delete(:dynamic_field_groups)

      category = DynamicFieldCategory.find_by!(display_label: display_label)
      dynamic_field_groups.each do |group_config|
        fields.concat(fields_for_group_definition(category, group_config))
      end
    end
    fields
  end

  def fields_for_group_definition(parent, group_config)
    fields = []
    dynamic_fields = group_config.delete(:dynamic_fields)
    dynamic_field_groups = group_config.delete(:dynamic_field_groups)
    string_key = group_config.delete(:string_key)

    group = DynamicFieldGroup.find_by!(string_key: string_key, parent: parent)

    fields.concat dynamic_fields.map { |field_config| field_for_definition(group, field_config) } if dynamic_fields
    dynamic_field_groups&.each do |child_group_config|
      fields.concat(fields_for_group_definition(group, child_group_config))
    end
    fields
  end

  def field_for_definition(group, field_config)
    string_key = field_config.fetch(:string_key, nil)
    DynamicField.find_by!(string_key: string_key, dynamic_field_group: group)
  end

  def load_and_return!(field_definitions)
    Hyacinth::DynamicFieldsLoader.load_fields!(field_definitions.deep_dup)
    fields_for_category_definitions(field_definitions)
  end

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

    load_and_return!(rights_fields)
  end

  def simple_value_field_data(string_key, **opts)
    field_data = {
      dynamic_field_categories: [
        {
          display_label: opts.fetch(:category_label, "Descriptive Metadata"),
          dynamic_field_groups: [
            {
              string_key: string_key,
              display_label: string_key.send(opts.fetch(:label_from, :titleize)),
              dynamic_fields: [
                { string_key: 'value', display_label: 'Value', field_type: opts.fetch(:field_type, DynamicField::Type::STRING) }.merge(opts.fetch(:index, {}))
              ]
            }
          ]
        }
      ]
    }
    if opts[:with_language_tags]
      dynamic_fields_path = [:dynamic_field_categories, 0, :dynamic_field_groups, 0, :dynamic_fields]
      field_data.dig(*dynamic_fields_path) << language_tag_for('value')
    end
    field_data
  end

  def language_tag_for(string_key)
    { string_key: "#{string_key}_lang", display_label: "#{string_key.titleize} Language", field_type: DynamicField::Type::LANG }
  end

  def load_abstract_fields!(**opts)
    field_data = simple_value_field_data('abstract', opts)
    load_and_return!(field_data)
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

    load_and_return!(name_fields)
  end

  def load_alternative_title_fields!(**opts)
    default_opts = { index: { is_keyword_searchable: true, is_title_searchable: true } }
    opts = default_opts.merge(opts)
    field_data = simple_value_field_data('alternative_title', opts)
    load_and_return!(field_data)
  end

  def load_isbn_fields!(**opts)
    default_opts = { index: { is_identifier_searchable: true }, label_from: :upcase }
    opts = default_opts.merge(opts)
    field_data = simple_value_field_data('isbn', opts)
    load_and_return!(field_data)
  end

  def load_note_fields!
    opts = { category_label: "Notes", field_type: DynamicField::Type::TEXTAREA }
    field_data = simple_value_field_data('note', opts)
    load_and_return!(field_data)
  end

  def enable_dynamic_fields(digital_object_type, project, dynamic_fields = DynamicField.all)
    dynamic_fields.each do |df|
      attrs = {
        project: project,
        dynamic_field: df,
        digital_object_type: digital_object_type
      }
      next if EnabledDynamicField.exists?(attrs)
      EnabledDynamicField.create!(attrs)
    end
  end
end
