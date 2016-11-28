module Hyacinth
  module Csv
    module Fields
      class Internal < Base
        def parse_path(internal_field_header_name)
          raise "Internal field header names must begin with an underscore ('_')" if internal_field_header_name[0] != '_'

          # Converts '_publish_target-2.string_key' to ['_publish_target', 2, 'string_key']
          new_builder_path = internal_field_header_name.split(/[\.-]/).map do |piece|
            raise Hyacinth::Exceptions::InvalidCsvHeader, 'Internal field header names cannot be 0-indexed. Must be 1-indexed.' if piece == '0'
            piece.match(/^\d+$/) ? piece.to_i - 1 : piece # This line converts ['_publish_target', '2', 'string_key'] to ['_publish_target', 1, 'string_key']
          end

          # Remove underscore from first builder path element name
          new_builder_path[0] = new_builder_path[0][1..-1]
          new_builder_path
        end

        def to_header
          parts = []
          builder_path.each do |segment|
            if segment.is_a? Fixnum
              parts[-1] = "#{parts[-1]}-#{segment + 1}"
            else
              parts << segment.to_s
            end
          end
          parts[0] = "_#{parts[0]}" unless parts[0] =~ /^_/
          parts.join('.')
        end

        def <=>(other)
          return -1 if other.is_a? Hyacinth::Csv::Fields::Dynamic
          return 0 unless other.is_a? Hyacinth::Csv::Fields::Internal
          return -1 if builder_path[0] == "pid"
          return 1 if other.builder_path[0] == "pid"
          super
        end
      end
    end
  end
end
