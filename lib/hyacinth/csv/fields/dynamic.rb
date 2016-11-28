module Hyacinth
  module Csv
    module Fields
      class Dynamic < Base
        def parse_path(dynamic_field_header_name)
          new_builder_path = dynamic_field_header_name.split(/[:-]/).map do |piece|
            raise Hyacinth::Exceptions::InvalidCsvHeader, 'Dynamic field header names cannot be 0-indexed. Must be 1-indexed.' if piece == '0'

            piece.match(/^\d+$/) ? piece.to_i - 1 : piece # This line converts 'name-0:name_role-0:name_role_type' to ['name', 0, 'name_role', 0, 'name_role_type']
          end
          if new_builder_path.last.index('.')
            # Convert ['aaa', 0, 'bbb', 0, 'ccc.ddd'] into ['aaa', 0, 'bbb', 0, 'ccc', 'ddd']
            new_last_two_elements = new_builder_path.pop.split('.') # Temporarily pop and split last element
            new_builder_path += new_last_two_elements # Add new two elements to new_builder_path
          end
          new_builder_path
        end

        def put_value(object, value, create_missing_path = true)
          super(object[DigitalObject::DynamicField::DATA_KEY] ||= {}, value, create_missing_path)
        end

        def get_value(object)
          # TODO: Come up with a better way to prevent duping the DFD key
          super(object.fetch(DigitalObject::DynamicField::DATA_KEY, object))
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
          header = parts.join(':')
          header
        end

        def <=>(other)
          return 1 if other.is_a? Hyacinth::Csv::Fields::Internal
          return 0 unless other.is_a? Hyacinth::Csv::Fields::Dynamic
          super
        end
      end
    end
  end
end
