module DigitalObject::UriServiceValues
  extend ActiveSupport::Concern

  def controlled_term_fields
    ::DynamicField.where(dynamic_field_type: DynamicField::Type::CONTROLLED_TERM)
  end

  # Returns Array of string_key values
  def controlled_term_field_string_keys
    controlled_term_fields.find_each.map(&:string_key)
  end

  # Returns Array of ['controlled_term_dynamic_field_string_key', 'parent_dynamic_field_group_string_key']
  def controlled_term_field_string_keys_to_controlled_vocabulary_string_keys
    controlled_term_fields.find_each.map { |df| [df.string_key, df.controlled_vocabulary_string_key] }
  end

  def register_new_uris_and_values_for_dynamic_field_data!(dynamic_field_data)
    controlled_term_field_string_keys_to_controlled_vocabulary_string_keys.each do |controlled_term_df_string_key, controlled_vocabulary_string_key|
      Hyacinth::Utils::HashUtils.find_nested_hashes_that_contain_key(dynamic_field_data, controlled_term_df_string_key).each do |dynamic_field_group_value|
        # We check for the presence of a 'uri' key (in the case of external or local terms) or a 'value' key (for temporary terms)
        next unless dynamic_field_group_value[controlled_term_df_string_key]['uri'].present? || dynamic_field_group_value[controlled_term_df_string_key]['value'].present?

        controlled_term_value = dynamic_field_group_value[controlled_term_df_string_key]
        uri = controlled_term_value['uri']
        value = controlled_term_value['value']
        authority = controlled_term_value['authority']
        additional_fields = controlled_term_value.reject { |key, _value| (key == 'uri') || (key == 'value') || (key == 'authority') }
        term = term_for(controlled_vocabulary_string_key, uri, value, authority, additional_fields)
        dynamic_field_group_value[controlled_term_df_string_key] = term
      end
    end
  end

  def term_for(controlled_vocabulary_string_key, uri, value, authority, additional_fields)
    term = nil
    if uri.blank? && value.present?
      # If URI is blank and a value is present, then we'll assign this value to a temporary term, only considering the string value
      # Note: If a temporary term with the same value already exists, that existing term will be returned by the create_term method
      # and any new additional_fields will be added.
      term = create_term(
        UriService::TermType::TEMPORARY,
        vocabulary_string_key: controlled_vocabulary_string_key, value: value, authority: authority, additional_fields: additional_fields
      )
    else
      # Be prepared to retry the following code because there may be two parallel processes trying to register this URI at the same time
      Retriable.retriable on: [UriService::ExistingUriError], tries: 2, base_interval: 0 do
        # URI is present, so we'll check whether it exists already.
        # If it does, retrieve its controlled value and update dynamic_field_data to correct errors
        # If it doesn't exist, register it as a new EXTERNAL term
        term = UriService.client.find_term_by_uri(uri)
        term ||= create_term(
          UriService::TermType::EXTERNAL,
          vocabulary_string_key: controlled_vocabulary_string_key, value: value, uri: uri, authority: authority, additional_fields: additional_fields
        )
      end
    end
    term
  end

  def create_term(type, properties)
    UriService.client.create_term(type, properties)
  end

  def add_extra_controlled_term_uri_data_to_dynamic_field_data!(dynamic_field_data)
    # TODO: Aggregate all hashes into array and do single URI lookup for better performance (fewer UriService calls)

    controlled_term_field_string_keys.each do |controlled_term_df_string_key|
      Hyacinth::Utils::HashUtils.find_nested_hashes_that_contain_key(dynamic_field_data, controlled_term_df_string_key).each do |dynamic_field_group_value|
        uri_string = dynamic_field_group_value[controlled_term_df_string_key]
        raise "During additional uri data addition, expected string value, but got #{uri_string.class.name} with value: #{uri_string.inspect}" unless uri_string.is_a?(String)
        term = UriService.client.find_term_by_uri(uri_string)
        dynamic_field_group_value[controlled_term_df_string_key] = term
      end
    end
    dynamic_field_data
  end

  def remove_extra_controlled_term_uri_data_from_dynamic_field_data!(dynamic_field_data)
    # It is expected that when this method is called, it receives JSON that has term hashes for all controlled term fields, and each of those term hashes has a 'uri' key
    controlled_term_field_string_keys.each do |controlled_term_df_string_key|
      Hyacinth::Utils::HashUtils.find_nested_hashes_that_contain_key(dynamic_field_data, controlled_term_df_string_key).each do |dynamic_field_group_value|
        term_data_hash = dynamic_field_group_value[controlled_term_df_string_key]
        raise "During additional uri term data removal, expected hash value, but got #{term_data_hash.class.name} with value: #{term_data_hash.inspect}" unless term_data_hash.is_a?(Hash)
        if dynamic_field_group_value[controlled_term_df_string_key]['uri'].present?
          uri = dynamic_field_group_value[controlled_term_df_string_key]['uri']
          dynamic_field_group_value[controlled_term_df_string_key] = uri
        else
          raise "Expected 'uri' key to be present in term data hash, but it wasn't. Term data hash: " + term_data_hash.inspect
        end
      end
    end
    dynamic_field_data
  end

  def raise_exception_if_malformed_controlled_field_data!(dynamic_field_data)
    controlled_term_field_string_keys.each do |controlled_term_df_string_key|
      Hyacinth::Utils::HashUtils.find_nested_hashes_that_contain_key(dynamic_field_data, controlled_term_df_string_key).each do |dynamic_field_group_value|
        term_value = dynamic_field_group_value[controlled_term_df_string_key]
        next unless term_value['uri'].blank? && term_value['value'].blank?

        raise Hyacinth::Exceptions::MalformedControlledTermFieldValue, "Malformed data for controlled term field value (for field #{controlled_term_df_string_key}). Must supply either uri or value field. Got: " + dynamic_field_group_value[controlled_term_df_string_key].inspect
      end
    end
  end
end
