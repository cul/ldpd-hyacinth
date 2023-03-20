module DigitalObject::DynamicField
  extend ActiveSupport::Concern

  DATA_KEY = 'dynamic_field_data'

  included do
    include DigitalObject::UriServiceValues
    attr_accessor :dynamic_field_data
  end

  def update_dynamic_field_data(new_dynamic_field_data, merge)
    # TODO: Field validation
    # validate_dynamic_field_data_fields(new_dynamic_field_data)

    raise_exception_if_dynamic_field_data_contains_invalid_utf8!(new_dynamic_field_data)

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
    trim_whitespace_and_clean_control_characters_for_dynamic_field_data!(@dynamic_field_data)

    # Handle URI fields:

    # Validate URI fields and raise exception if any of them are malformed
    raise_exception_if_malformed_controlled_field_data!(@dynamic_field_data)

    # 1) Register any non-existent newly-supplied URIs, adding URIs as needed
    register_new_uris_and_values_for_dynamic_field_data!(@dynamic_field_data)

    # 2) Correct associated URI fields (value, etc.), regardless of what user entered,
    # by running remove_extra_controlled_term_uri_data_from_dynamic_field_data!() followed by
    # add_extra_controlled_term_uri_data_to_dynamic_field_data!()
    remove_extra_controlled_term_uri_data_from_dynamic_field_data!(@dynamic_field_data)
    add_extra_controlled_term_uri_data_to_dynamic_field_data!(@dynamic_field_data)
  end

  def remove_blank_fields_from_dynamic_field_data!(df_data = @dynamic_field_data)
    return if df_data.frozen? # We can't modify a frozen hash (e.g. uri-based controlled vocabulary field), so we won't.

    # Step 1: Recursively handle values on lower levels
    df_data.each do |_key, value|
      if value.is_a?(Array)
        # Recurse through non-empty elements
        value.each do |element|
          remove_blank_fields_from_dynamic_field_data!(element)
        end

        # Delete blank array element values on this array level (including empty object ({}) values)
        value.delete_if(&:blank?)
      elsif value.is_a?(Hash)
        # This code will run when we're dealing with something like a controlled
        # term field, which is a hash that contains a hash as a value.
        remove_blank_fields_from_dynamic_field_data!(value)
      end
    end

    # Step 2: Delete blank values on this object level
    df_data.delete_if { |_key, value| value.blank? }
  end

  def trim_whitespace_and_clean_control_characters_for_dynamic_field_data!(df_data = @dynamic_field_data)
    df_data.each do |key, value|
      if value.is_a?(Array)
        value.each { |element| trim_whitespace_and_clean_control_characters_for_dynamic_field_data!(element) }
      elsif value.is_a?(Hash)
        trim_whitespace_and_clean_control_characters_for_dynamic_field_data!(value)
      elsif value.is_a?(String)
        next if df_data.frozen? # can't modify a frozen hash, so we won't try to (this generally applies to controlled term values)
        df_data[key] = clean_control_characters(value).strip
      end
    end
  end

  # The control character cleaning logic below is based on:
  # https://github.com/ndlib/curate_nd/blob/4c19def027b062ee3b17e8eac77a51cde2dbb30f/lib/curate/sanitize_control_characters_for_indexing.rb#L11
  def clean_control_characters(str)
    str.gsub(/[[:cntrl:]]/) do |character|
      case character
      when "\t", "\n", "\r"
        character
      else
        "" # we want to completely eliminate the unwanted control character
      end
    end
  end

  def raise_exception_if_dynamic_field_data_contains_invalid_utf8!(df_data)
    return if df_data.nil?
    # If JSON.generate() encounters invalid UTF-8, it raises an Encoding::UndefinedConversionError.
    # So we can use the JSON.generate() function as a convenient, pre-existing shortcut for
    # detecting invalid UTF-8 in dynamic field data.
    JSON.generate(df_data)
  rescue Encoding::UndefinedConversionError => e
    raise Hyacinth::Exceptions::InvalidUtf8DetectedError, "Invalid UTF-8 detected: #{e.message}"
  end

  def remove_dynamic_field_data_key!(dynamic_field_or_field_group_name, df_data = @dynamic_field_data)
    # Step 1: Delete specified key-value pair on this object level
    df_data.delete_if { |key, _value| key == dynamic_field_or_field_group_name }

    # Step 2: Recursively handle values on lower levels
    df_data.each do |_key, value|
      next unless value.is_a?(Array)

      # Recurse through non-empty elements
      value.each do |element|
        remove_dynamic_field_data_key!(dynamic_field_or_field_group_name, element)
      end
    end

    # Step 3: Clean up any blank fields that were created as a result of the deletion
    remove_blank_fields_from_dynamic_field_data!(df_data)
  end

  #################################
  # dynamic_field_data processing #
  #################################

  # Returns a flat (single layer) hash of all dynamic_field string_keys to their values
  # Does NOT omit `.blank?` values by default, unless true is passed for the omit_blank_values param
  def get_flattened_dynamic_field_data(omit_blank_values = false)
    self.class.recursively_generate_flattened_dynamic_field_data(@dynamic_field_data, omit_blank_values)
  end

  # Returns a csv-formatted flat (single layer) hash of all csv-header-style full-dynamic_field-path string_keys to their values
  # Does NOT omit `.blank?` values by default, unless true is passed for the omit_blank_values param
  def get_csv_style_flattened_dynamic_field_data(omit_blank_values = false)
    # code
  end

  module ClassMethods
    def flat_value(value)
      if value.is_a?(Hash) && value.key?('uri')
        # This is a URI value.  Get value of 'value' key.
        value['value']
      else
        # This is just a regular non-controlled-field dynamic_field value.
        value
      end
    end

    def recursively_generate_flattened_dynamic_field_data(df_data, omit_blank_values = false, flat_hash = {})
      df_data.each do |key, value|
        if value.is_a?(Array)
          value.each do |data_hsh|
            recursively_generate_flattened_dynamic_field_data(data_hsh, omit_blank_values, flat_hash)
          end
        else
          next if omit_blank_values && value.blank?

          flat_hash[key] ||= []

          flat_hash[key] << flat_value(value)
        end
      end

      flat_hash
    end

    # return a hash of csv field headers and values
    def flat_csv_value(key, value)
      if value.is_a?(Hash) && value.key?('uri')
        # This is a controlled term value hash.
        value.map do |term_key, term_value|
          [key + '.' + term_key, term_value]
        end.to_h
      else
        # This is just a regular non-controlled-field dynamic_field value.
        { key => value }
      end
    end

    def recursively_generate_csv_style_flattened_dynamic_field_data(df_data, omit_blank_values = false, flat_hash = {}, current_path_string = '')
      df_data.each do |key, value|
        if value.is_a?(Array)
          new_path_string = current_path_string + (current_path_string.length > 0 ? ':' : '') + key
          value.each_with_index do |data_hsh, index|
            recursively_generate_csv_style_flattened_dynamic_field_data(data_hsh, omit_blank_values, flat_hash, new_path_string + '-' + (index + 1).to_s)
          end
        else
          next if omit_blank_values && value.blank?

          new_path_string = current_path_string + ':' + key
          flat_hash.merge! flat_csv_value(new_path_string, value)
        end
      end

      flat_hash
    end
  end
end
