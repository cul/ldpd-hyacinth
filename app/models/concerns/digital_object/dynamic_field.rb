module DigitalObject::DynamicField
  extend ActiveSupport::Concern

  def update_dynamic_field_data(new_dynamic_field_data, merge)
    if merge
      # During a merge, new top level key-value pairs are added and existing top level keys have their values replace by new values
      @dynamic_field_data.merge!(new_dynamic_field_data)
    else
      # Replace existing dynamic_fiel_data with newly supplied value
      @dynamic_field_data = new_dynamic_field_data
    end
    
    # Remove blank fields (all-whitespace fields DO count as blank)
    remove_blank_fields_from_dynamic_field_data!(@dynamic_field_data)
    
    # Trim whitespace for all remaining String fields
    trim_whitespace_for_dynamic_field_data!(@dynamic_field_data)
    
    # Handle URI fields:
    
    # 1) Register any non-existent newly-supplied URIs, adding URIs as needed
    self.register_new_uris_and_values_for_dynamic_field_data!(@dynamic_field_data)
    
    # 2) Correct associated URI fields (value, etc.), regardless of what user entered,
    # by running remove_extra_uri_data_from_dynamic_field_data!() followed by
    # add_extra_uri_data_to_dynamic_field_data!()
    self.remove_extra_uri_data_from_dynamic_field_data!(@dynamic_field_data)
    self.add_extra_uri_data_to_dynamic_field_data!(@dynamic_field_data)
    
  end

  def remove_blank_fields_from_dynamic_field_data!(df_data=@dynamic_field_data)
    # Step 1: Recursively handle values on lower levels
    df_data.each {|key, value|
      if value.is_a?(Array)

        # Recurse through non-empty elements
        value.each {|element|
          remove_blank_fields_from_dynamic_field_data!(element)
        }

        # Delete blank array element values on this array level (including empty object ({}) values)
        value.delete_if{|element|
          element.blank?
        }
      elsif value.is_a?(Hash)
        # This code will run when we're dealing with something like a controlled
        # term field, which is a hash that contains a hash as a value.
        remove_blank_fields_from_dynamic_field_data!(value)
      end
    }
    
    # Step 2: Delete blank values on this object level
    df_data.delete_if{|key, value|
      value.blank?
    }
    
  end
  
  def trim_whitespace_for_dynamic_field_data!(df_data=@dynamic_field_data)
    # Step 1: Recursively handle values on lower levels
    df_data.each {|key, value|
      if value.is_a?(Array)
        value.each {|element|
          trim_whitespace_for_dynamic_field_data!(element)
        }
      elsif value.is_a?(Hash)
        trim_whitespace_for_dynamic_field_data!(value)
      elsif value.is_a?(String)
        value.strip!
      end
    }
    
  end

  def remove_dynamic_field_data_key!(dynamic_field_or_field_group_name, df_data=@dynamic_field_data)

    # Step 1: Delete specified key-value pair on this object level
    df_data.delete_if{|key, value|
      key == dynamic_field_or_field_group_name
    }

    # Step 2: Recursively handle values on lower levels
    df_data.each {|key, value|
      if value.is_a?(Array)
        # Recurse through non-empty elements
        value.each {|element|
          remove_dynamic_field_data_key!(dynamic_field_or_field_group_name, element)
        }
      end
    }

    # Step 3: Clean up any blank fields that were created as a result of the deletion
    remove_blank_fields_from_dynamic_field_data!(df_data)

  end

  #################################
  # dynamic_field_data processing #
  #################################

  # Returns a flat (single layer) hash of all dynamic_field string_keys to their values
  # Does NOT omit `.blank?` values by default, unless true is passed for the omit_blank_values param
  def get_flattened_dynamic_field_data(omit_blank_values=false)
    return self.class.recursively_generate_flattened_dynamic_field_data(@dynamic_field_data, omit_blank_values)
  end
  
  # Returns a csv-formatted flat (single layer) hash of all csv-header-style full-dynamic_field-path string_keys to their values
  # Does NOT omit `.blank?` values by default, unless true is passed for the omit_blank_values param
  def get_csv_style_flattened_dynamic_field_data(omit_blank_values=false)
    #code
  end

  module ClassMethods

    def recursively_generate_flattened_dynamic_field_data(df_data, omit_blank_values = false, flat_hash = {})
      df_data.each {|key, value|
        if value.is_a?(Array)
          value.each {|data_hsh|
            self.recursively_generate_flattened_dynamic_field_data(data_hsh, omit_blank_values, flat_hash)
          }
        else
          unless (omit_blank_values && value.blank?)
            flat_hash[key] = [] unless flat_hash.has_key?(key)
            
            if value.is_a?(Hash) && value.has_key?('uri')
              #This is a URI value.  Get value of 'value' key.
              flat_hash[key] << value['value']
            else
              #This is just a regular non-controlled-field dynamic_field value.
              flat_hash[key] << value
            end
            
          end
        end
      }
      
      return flat_hash
    end
    
    def recursively_generate_csv_style_flattened_dynamic_field_data(df_data, omit_blank_values = false, flat_hash = {}, current_path_string='')
      df_data.each do |key, value|
        if value.is_a?(Array)
          new_path_string = current_path_string + (current_path_string.length > 0 ? ':' : '') + key
          value.each_with_index do |data_hsh, index|
            self.recursively_generate_csv_style_flattened_dynamic_field_data(data_hsh, omit_blank_values, flat_hash, new_path_string + '-' + (index+1).to_s)
          end
        else
          unless (omit_blank_values && value.blank?)
            new_path_string = current_path_string + ':' + key
            if value.is_a?(Hash) && value.has_key?('uri')
              #This is a controlled term value hash.
              value.each do |term_key, term_value|
                flat_hash[new_path_string + '.' + term_key] = term_value
              end
            else
              #This is just a regular non-controlled-field dynamic_field value.
              flat_hash[new_path_string] = value
            end
          end
        end
      end
      
      return flat_hash
    end
  end

end
