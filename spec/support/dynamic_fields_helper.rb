# frozen_string_literal: true

module DynamicFieldsHelper
  module_function

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
end
