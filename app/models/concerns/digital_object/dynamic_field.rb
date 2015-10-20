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

      end
    }
    # Step 2: Delete blank values on this object level
    df_data.delete_if{|key, value|
      value.blank?
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
    return recursively_gather_dynamic_field_data_values(@dynamic_field_data, omit_blank_values)
  end

  def recursively_gather_dynamic_field_data_values(df_data, omit_blank_values = false, flat_hash = {})
    df_data.each {|key, value|
      if value.is_a?(Array)
        value.each {|data_hsh|
          self.recursively_gather_dynamic_field_data_values(data_hsh, omit_blank_values, flat_hash)
        }
      else
        unless (omit_blank_values && value.blank?)
          flat_hash[key] = [] unless flat_hash.has_key?(key)
          flat_hash[key] << value
        end
      end
    }
    return flat_hash
  end

end
