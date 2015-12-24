module Hyacinth
  module Csv
    module Fields
      class Base
        attr_accessor :builder_path
        def initialize(builder_path)
          builder_path = parse_path(builder_path) unless builder_path.is_a? Array
          self.builder_path = builder_path.freeze
        end

        def put_value(object, value, create_missing_path = true)
          current_value = get_value(object)

          unless current_value || create_missing_path
            raise Hyacinth::Exceptions::BuilderPathNotFoundError, Hyacinth::Utils::CsvImportExportUtils::PATH_MISSING
          end

          if current_value.nil?
            create_value(object, value)
          else
            current_value = branch_field.get_value(object)
            current_value[builder_path.last] = value
          end
        end

        def create_value(object, value)
          pointer = object

          builder_path.each_with_index do |element, i|
            if i == (builder_path.length - 1)
              pointer[element] = value
              break
            end

            if pointer[element].nil?
              # We need to create this part of the path
              if builder_path[i + 1].is_a?(Fixnum)
                pointer[element] = []
              else
                pointer[element] = {}
              end
            end

            pointer = pointer[element]
          end
        end

        def get_value(object)
          pointer = object
          builder_path.each do |element|
            # If pointer is an array and element is a string, this is an invalid path and we should raise an error.
            if pointer.is_a?(Array) && element.is_a?(String)
              raise Hyacinth::Exceptions::BuilderPathNotFoundError, Hyacinth::Utils::CsvImportExportUtils::PATH_INVALID
            end

            # Element will be either a Fixnum (for array access) or a String (for hash access)
            if pointer[element]
              pointer = pointer[element]
            else
              return nil
            end
          end
          pointer
        end

        def branch_field
          @branch ||= begin
            self.class.new(builder_path.slice(0, builder_path.length - 1).freeze)
          end
        end

        def <=>(other)
          return 0 unless other.is_a? Hyacinth::Csv::Fields::Base
          min_array_length = [builder_path.length, other.builder_path.length].min
          ix = min_array_length.times.detect { |i| 0 != (builder_path[i] <=> other.builder_path[i]) }
          ix ? (builder_path[ix] <=> other.builder_path[ix]) : 0
        end

        def self.from_header(header)
          if header.start_with? '_'
            Hyacinth::Csv::Fields::Internal.new(header)
          else
            Hyacinth::Csv::Fields::Dynamic.new(header)
          end
        end
      end
    end
  end
end
