module Hyacinth
  module Csv
    class Row
      attr_accessor :header, :fields
      def initialize(header, fields = [])
        @header = header
        self.fields = fields
      end

      def csv_headers
        fields.map(&:to_header)
      end

      def self.from_document(document = {}, headers = nil)
        headers ||= Header.from_document(document).sort!
        data = headers.map { |field| field.get_value(document) }
        Row.new(Header.new(headers), data)
      end
    end
  end
end
