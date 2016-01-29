module DigitalObject::UriServiceValues
  extend ActiveSupport::Concern

  # Returns hash of format {'controlled_term_dynamic_field_string_key' => 'parent_dynamic_field_group_string_key'}
  def get_controlled_term_field_string_keys_to_controlled_vocabulary_string_keys()
    return ::DynamicField.where(dynamic_field_type: DynamicField::Type::CONTROLLED_TERM).map{|df| [df.string_key, df.controlled_vocabulary_string_key] }
  end

  def register_new_uris_and_values_for_dynamic_field_data!(dynamic_field_data)
    # We only need to register new uri values if there are elements that contain the key "uri" somewhere in the dynamic_field_data
    if Hyacinth::Utils::HashUtils::find_nested_hash_values(dynamic_field_data, 'uri').length > 0   
      get_controlled_term_field_string_keys_to_controlled_vocabulary_string_keys().each do |controlled_term_df_string_key, controlled_vocabulary_string_key|
        Hyacinth::Utils::HashUtils::find_nested_hashes_that_contain_key(dynamic_field_data, controlled_term_df_string_key).each do |dynamic_field_group_value|
          # We check for the presence of a 'uri' key (in the case of external or local terms) or a 'value' key (for temporary terms)
          if dynamic_field_group_value[controlled_term_df_string_key]['uri'].present? || dynamic_field_group_value[controlled_term_df_string_key]['value'].present?
            uri = nil
            value = nil
            authority = nil
            additional_fields = {}
            dynamic_field_group_value[controlled_term_df_string_key].each do |key, val|
              if key == 'uri'
                uri = val
              elsif key == 'value'
                value = val
              elsif key == 'authority'
                authority = val
              else
                additional_fields[key] = val
              end
            end

            if uri.blank? && value.present?
              # If URI is blank and a value is present, then we'll assign this value to a temporary term, only considering the string value
              temporary_term = UriService.client.create_term(UriService::TermType::TEMPORARY, {vocabulary_string_key: controlled_vocabulary_string_key, value: value})
              dynamic_field_group_value[controlled_term_df_string_key] = temporary_term # Update dynamic_field_data
            else
              # URI is present, so we'll check whether it exists already.
              # If it does, retrieve its controlled value and update dynamic_field_data to correct errors
              # If it doesn't exist, register it as a new EXTERNAL term
              term = UriService.client.find_term_by_uri(uri)
              if term.nil?
                new_external_term = UriService.client.create_term(UriService::TermType::EXTERNAL, {vocabulary_string_key: controlled_vocabulary_string_key, value: value, uri: uri, authority: authority, additional_fields: additional_fields})
                dynamic_field_group_value[controlled_term_df_string_key] = new_external_term # Update dynamic_field_data
              else
                # Term exists. Assign term data to record.
                dynamic_field_group_value[controlled_term_df_string_key] = term # Update dynamic_field_data
              end
            end
          end
        end
      end
    end
  end

  def add_extra_uri_data_to_dynamic_field_data!(dynamic_field_data)
    # TODO: Aggregate all hashes into array and do single URI lookup for better performance (fewer UriService calls)
    
    get_controlled_term_field_string_keys_to_controlled_vocabulary_string_keys().each do |controlled_term_df_string_key, controlled_vocabulary_string_key|
      Hyacinth::Utils::HashUtils::find_nested_hashes_that_contain_key(dynamic_field_data, controlled_term_df_string_key).each do |dynamic_field_group_value|
        uri = dynamic_field_group_value[controlled_term_df_string_key]
        raise "Expected uri to be a string, but got #{uri.class.name} with value: #{uri.inspect}" unless uri.is_a?(String)
        term = UriService.client.find_term_by_uri(uri)
        dynamic_field_group_value[controlled_term_df_string_key] = term
      end
    end
    return dynamic_field_data
  end
  
  def remove_extra_uri_data_from_dynamic_field_data!(dynamic_field_data)
    # We only need to remove uri display labels is there are elements that contain the key "uri" somewhere in the dynamic_field_data
    if Hyacinth::Utils::HashUtils::find_nested_hash_values(dynamic_field_data, 'uri').length > 0
      get_controlled_term_field_string_keys_to_controlled_vocabulary_string_keys().each do |controlled_term_df_string_key, controlled_vocabulary_string_key|
        Hyacinth::Utils::HashUtils::find_nested_hashes_that_contain_key(dynamic_field_data, controlled_term_df_string_key).each do |dynamic_field_group_value|
          if dynamic_field_group_value[controlled_term_df_string_key]['uri'].present?
            uri = dynamic_field_group_value[controlled_term_df_string_key]['uri']
            dynamic_field_group_value[controlled_term_df_string_key] = uri
          end
        end
      end  
    end

    return dynamic_field_data
  end
  
  def raise_exception_if_malformed_controlled_field_data!(dynamic_field_data)
    get_controlled_term_field_string_keys_to_controlled_vocabulary_string_keys().each do |controlled_term_df_string_key, controlled_vocabulary_string_key|
      Hyacinth::Utils::HashUtils::find_nested_hashes_that_contain_key(dynamic_field_data, controlled_term_df_string_key).each do |dynamic_field_group_value|
        if dynamic_field_group_value[controlled_term_df_string_key]['uri'].blank?
          if dynamic_field_group_value[controlled_term_df_string_key]['value'].blank?
            raise Hyacinth::Exceptions::MalformedControlledTermFieldValue, "Malformed data for controlled term field value (for field #{controlled_term_df_string_key}). Must supply either uri or value field. Got: " + dynamic_field_group_value[controlled_term_df_string_key].inspect
          elsif dynamic_field_group_value[controlled_term_df_string_key]['authority'].present?
            raise Hyacinth::Exceptions::MalformedControlledTermFieldValue, "Malformed data for controlled term field value (for field #{controlled_term_df_string_key}).  Cannot supply authority without URI. Got: " + dynamic_field_group_value[controlled_term_df_string_key].inspect
          end
        end
      end
    end  
  end
end
