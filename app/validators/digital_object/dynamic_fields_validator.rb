# frozen_string_literal: true

# This class provided the logic for validating dynamic fields against a map generated by DynamicFieldMap.
class DigitalObject::DynamicFieldsValidator < ActiveModel::EachValidator
  private

    def generate_errors(digital_object, attribute, value, map, enablable = false)
      #enabled checks are skipped for rights validation
      if enablable
        enabled_field_errors(value, digital_object).each { |a| 
            digital_object.errors.add(a[0], a[1]) 
          }
      end
      errors_for(map, value, attribute).each { |a| digital_object.errors.add(a[0], a[1]) }
    end

    # Returns errors that should be recorded for any of the fields in the data given.
    # Errors include: invalid fields appearing in the data given, field values containing the wrong type of data.
    def errors_for(field_map, data, path = nil)
      errors = []

      data.each do |field_or_group_key, value|
        new_path = [path, field_or_group_key].compact.join('.')
        unless field_map.key?(field_or_group_key)
          errors.append([new_path, "is not a valid field"])
          next
        end

        reduced_map = field_map[field_or_group_key]
        case reduced_map[:type]
        when 'DynamicFieldGroup'
          unless value.is_a?(Array)
            errors.append([new_path, "must contain an array"])
            next
          end

          dynamic_field_group = DynamicFieldGroup.find_by(string_key: field_or_group_key)
          if dynamic_field_group
            if dynamic_field_group.is_repeatable
              if value.length > 1
                errors.append([new_path, "is not repeatable"])
              end
            end
          end

          
          value.each_with_index do |v, i|
            errors.concat errors_for(reduced_map[:children], v, "#{new_path}[#{i}]")
          end
        when 'DynamicField'
          if (e = field_errors(reduced_map, value))
            errors.concat e.map { |i| [new_path, i] }
          end
        end
      end

      errors
    end

    # Returns any errors that are present for the field and value combination.
    #
    # @return [String] if there are errors
    # @return false if there are no errors
    def field_errors(configuration, value)
      send("errors_for_#{configuration[:field_type]}_field", configuration, value)
    end

    def enabled_field_errors(data, digital_object)
      errors = []
      dynamic_field_paths = []
      data.each do |df_group, children|
        children.each do |child|
          child.each do |df_name, value|
            # only check field if a value is provided
            if value
              dynamic_field_paths << "#{df_group}/#{df_name}"
            end
          end
        end

        dynamic_field_paths.each do |dynamic_field_path|
            if (e = is_disabled(dynamic_field_path, digital_object))
              errors.concat e.map { |i| [dynamic_field_path, i] }
            end
          end
      end

      errors = check_required_fields(dynamic_field_paths, digital_object, errors)

      errors
    end      

    def is_disabled(dynamic_field_path, digital_object)
      no_match = true
      dynamic_field = DynamicField.find_by(path: dynamic_field_path)
      puts "is disabled ... "
      DynamicField.all.each do |df|
        puts df.display_label
      end
      if dynamic_field
        # puts dynamic_field.id
        # puts digital_object.primary_project.id
        # puts digital_object.digital_object_type
      else
        puts "no  dyna field for "
        puts dynamic_field_path
      end
      if dynamic_field && EnabledDynamicField.where(dynamic_field: dynamic_field.id, 
                                  project: digital_object.primary_project, 
                                  digital_object_type: digital_object.digital_object_type)
          no_match = false
      end

      return ['field must be enabled'] if no_match
      false
    end

    def check_required_fields(dynamic_field_paths, digital_object, errors)
      required_enabled_fields = EnabledDynamicField.where(project: digital_object.primary_project,
                                    digital_object_type: digital_object.digital_object_type, required: true)

      required_enabled_fields.each do |enabled_field|  
          unless dynamic_field_paths.include? enabled_field.dynamic_field.path
            errors.concat ['is required'].map { |i| [enabled_field.dynamic_field.path, i] }
          end
        end

        errors
    end

    def errors_for_string_field(_configuration, value)
      value.is_a?(String) ? false : ['must be a string']
    end

    def errors_for_textarea_field(configuration, value)
      errors_for_string_field(configuration, value)
    end

    def errors_for_date_field(_configuration, value)
      return ['must be a string'] unless value.is_a?(String)
      return ['must be in YYYY-MM-DD format'] unless value.match?(/^-?\d{4}(-(0[1-9]|1[0-2])(-(0[1-9]|[1,2][0-9]|3[0,1]))?)?/)

      begin
        Date.parse(value)
      rescue
        return ['is an invalid date']
      end

      false
    end

    def errors_for_select_field(configuration, value)
      valid_options = JSON.parse(configuration[:select_options]).map { |option| option['value'] }
      valid_options.include?(value) ? false : ["has invalid value: '#{value}'"]
    end

    def errors_for_integer_field(_configuration, value)
      value.is_a?(Integer) ? false : ['must be an integer']
    end

    def errors_for_boolean_field(_configuration, value)
      value.is_a?(TrueClass) || value.is_a?(FalseClass) ? false : ['must be a boolean']
    end

    def errors_for_controlled_term_field(configuration, value)
      return ['must be a controlled term'] unless value.is_a?(Hash)
      return ['must contain a uri or pref_label'] unless value['uri'] || value['pref_label']

      # Check that every value provided is a core field or a valid custom field value for that vocabulary.
      custom_fields = custom_fields_for(configuration[:controlled_vocabulary])
      return ["#{configuration[:controlled_vocabulary]} is not a valid vocabulary"] if custom_fields.nil?

      valid_fields = Term::CORE_FIELDS + custom_fields

      errors = (value.keys - valid_fields).map { |f| "has invalid key, \"#{f}\" in hash" }

      errors.empty? ? false : errors
    end

    # Returns nil if vocabulary is not represented in hash
    def custom_fields_for(vocabulary)
      vocabulary_to_custom_fields_map.fetch(vocabulary, nil)
    end

    def vocabulary_to_custom_fields_map
      @vocabulary_to_custom_fields_map ||= Vocabulary.all.map { |v| [v.string_key, v.custom_fields.keys] }.to_h
    end
end
