module Hyacinth::DigitalObjectsController::CsvExportBehavior
  extend ActiveSupport::Concern
  DYNAMIC_ATTRIBUTE_SEPARATOR = ' ||| '
  DYNAMIC_ATTRIBUTE_PROPERTY_SEPARATOR = ' >>> '

  def get_dynamic_fields_for_csv_export_dialog
    respond_to do |format|
      format.json {
        render json: DynamicField.order(:display_label).map{|data_element| [data_element.string_key, data_element.display_label] }
      }
    end
  end

  def generate_csv_for_search(digital_objects, string_keys_for_dynamic_fields_to_include)

    return CSV.generate do |csv|

      csv << ['Digital Objects']
      csv << ['Field separator character: |||']
      csv << ['Subfield separator character: >>>']
      csv << ['Name field example: Smith, John >>> personal ||| Consumer Goods Company >>> corporate']
      csv << ['']

      # Get dynamic field string_keys to display_labels
      # AND
      # Get dyamic_subfield order
      dynamic_field_data = {}
      DynamicField.includes(:dynamic_subfields).order('dynamic_subfields.sort_order').each {|dynamic_field|
        dynamic_field_data[dynamic_field.string_key] = {
          :display_label => dynamic_field.display_label,
          :ordered_dynamic_subfields => dynamic_field.dynamic_subfields.map{|dynamic_subfield|
            [dynamic_subfield.string_key, dynamic_subfield.display_label]
          }
        }
      }

      key_row_arr = []
      display_label_row_arr = []

      always_present_csv_fields = {
        'pid' => 'PID',
        'project_display_label' => 'Project',
        'fedora_identifier' => 'Fedora Identifier',
        'digital_object_type' => 'Digital Object Type'
      }

      # Add always-present rows and labels

      always_present_csv_fields.each {|key, value|
        key_row_arr << key
        display_label_row_arr << value
      }

      unless string_keys_for_dynamic_fields_to_include.blank?
        string_keys_for_dynamic_fields_to_include.each {|dynamic_field_string_key|
          # Verify that all values in string_keys_for_dynamic_fields_to_include actually exist
          # Immediately cancel the export if the field is not found and write error to CSV
          if dynamic_field_data.has_key?(dynamic_field_string_key)
            key_row_arr << dynamic_field_string_key + '={' + dynamic_field_data[dynamic_field_string_key][:ordered_dynamic_subfields].map{|dynamic_subfield_string_key_and_display_label|dynamic_subfield_string_key_and_display_label[0]}.join(',') + '}'
            display_label_row_arr << dynamic_field_data[dynamic_field_string_key][:ordered_dynamic_subfields].map{|dynamic_subfield_string_key_and_display_label|dynamic_subfield_string_key_and_display_label[1]}.join(DYNAMIC_ATTRIBUTE_PROPERTY_SEPARATOR)
          else
            csv << ['']
            csv << ['ERROR: Could not find dynamic_field with string_key: ' + dynamic_field_string_key]
            net # break out of block
          end
        }
      end

      csv << ['--KEYS--']
      csv << key_row_arr
      csv << ['--LABELS--']
      csv << display_label_row_arr
      csv << ['--DATA--']

      digital_objects.each do |digital_object|

        csv_row = []

        # Include always-present fields
        csv_row << digital_object.pid
        csv_row << digital_object.project.display_label
        csv_row << digital_object.fedora_identifier
        csv_row << digital_object.digital_object_type.display_label

        unless string_keys_for_dynamic_fields_to_include.blank?
          item_json_hash = digital_object.as_json
          digital_object_dynamic_attributes = item_json_hash['dynamic_attributes']

          string_keys_for_dynamic_fields_to_include.each {|dynamic_field_string_key|
            if digital_object_dynamic_attributes.has_key?(dynamic_field_string_key)
              csv_row << digital_object_dynamic_attributes[dynamic_field_string_key].map{|single_dynamic_attribute_hash|
                values = []
                dynamic_field_data[dynamic_field_string_key][:ordered_dynamic_subfields].each {|subfield_string_key_and_display_label|
                  if single_dynamic_attribute_hash.has_key?(subfield_string_key_and_display_label[0])
                    values << single_dynamic_attribute_hash[subfield_string_key_and_display_label[0]]
                  else
                    values << ''
                  end
                }
                values.join(DYNAMIC_ATTRIBUTE_PROPERTY_SEPARATOR)
              }.join(DYNAMIC_ATTRIBUTE_SEPARATOR)
            else
              csv_row << ''
            end
          }
        end

        csv << csv_row

      end

    end
  end

end
