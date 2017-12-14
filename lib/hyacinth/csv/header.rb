module Hyacinth
  module Csv
    class Header
      attr_accessor :fields
      def initialize(fields = [])
        self.fields = fields.map { |field| (field.is_a? String) ? Header.header_to_input_field(field) : field }

        # Cache currently known boolean and integer DynamicField string keys at time of instance initialization
        @known_boolean_field_string_keys = DynamicField.select('string_key').where(dynamic_field_type: DynamicField::Type::BOOLEAN).pluck('string_key')
        @known_integer_field_string_keys = DynamicField.select('string_key').where(dynamic_field_type: DynamicField::Type::INTEGER).pluck('string_key')
      end

      def document_for(data = [])
        digital_object_data = {}

        data.each_with_index do |cell_value, index|
          next if fields[index].blank? # Ignore columns that have a nil (absent) hyacinth header value

          cell_value ||= '' # If the cell value is nil, convert it into an empty string
          cell_value = cast_cell_value_if_necessary(cell_value, fields[index].builder_path.last)
          fields[index].put_value(digital_object_data, cell_value, true)
        end

        # Clean up digital_object_data top level fields, removing any blank array values generated from blank spreadsheet cells
        digital_object_data.each do |_key, value|
          # If this value is an array, remove any blank strings or hashes with only blank values
          next unless value.is_a?(Array) && value.length > 0
          value.reject! { |el| el.blank? || (el.is_a?(Hash) && el.select { |_k, v| v.present? }.blank?) } # Remove blank elements or hashes with all blank values
        end

        digital_object_data
      end

      def cast_cell_value_if_necessary(cell_value, dynamic_field_string_key_from_last_builder_path_element)
        if @known_boolean_field_string_keys.include?(dynamic_field_string_key_from_last_builder_path_element)
          # Convert field value to boolean if it's a boolean field
          (cell_value.downcase == 'true')
        elsif @known_integer_field_string_keys.include?(dynamic_field_string_key_from_last_builder_path_element)
          # Convert field value to integer if it's an integer field
          cell_value.blank? ? nil : cell_value.to_i
        else
          # Otherwise just return the original string value
          cell_value
        end
      end

      def csv_headers
        fields.map(&:to_header)
      end

      def self.from_document(_document = {}); end

      def self.header_to_input_field(header_data)
        return if header_data.blank? # Skip blank headers

        if header_data.start_with?('_')
          # Handle internal field, which is named with a leading underscore
          Hyacinth::Csv::Fields::Internal.new(header_data)
        else
          # Handle dynamic field, which never starts with a leading underscore
          Hyacinth::Csv::Fields::Dynamic.new(header_data)
        end
      end
    end
  end
end
