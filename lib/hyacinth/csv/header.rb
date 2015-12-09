module Hyacinth
  module Csv
    class Header
      attr_accessor :fields
      def initialize(fields = [])
        self.fields = fields.map { |field| (field.is_a? String) ? Header.header_to_input_field(field) : field }
      end

      def document_for(data = [])
        digital_object_data = {}

        data.each_with_index do |cell_value, index|
          cell_value = '' if cell_value.nil? # If the cell value is nil, convert it into an empty string

          fields[index].put_value(digital_object_data, cell_value, true)
        end

        digital_object_data
      end

      def csv_headers
        fields.map(&:to_header)
      end

      def self.from_document(_document = {}); end

      def self.header_to_input_field(header_data)
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
