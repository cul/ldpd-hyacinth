# frozen_string_literal: true

# Using the given metadata form(s) generates a map of dynamic field and dynamic field groups. Provides
# some helpers methods that use the map to extract data.
module Hyacinth
  class DynamicFieldsMap
    attr_reader :map

    # @param [String|Array<String>] for_metadata_form limits map to fields related forms
    def initialize(*for_metadata_form)
      @map = generate_map(for_metadata_form)
    end

    # Based on the map given extracts all terms within the data.
    #
    # @return [Hash<String, Array<Hash>>] references to term hashes organized by vocabulary string key
    def extract_terms(data)
      get_terms(map, data)
    end

    # Based on the map given extracts all terms within the data.
    #
    # @return [Hash] references to lang hashes
    def extract_langs(data)
      get_langs(map, data)
    end

    # Based on the map returns a list of all the dynamic fields. Return an array of dynamic fields
    # configs. Each config includes a path to the field.
    def all_fields
      get_all_fields(map)
    end

    private

      def get_all_fields(dynamic_field_map, path = [])
        all_fields = []

        dynamic_field_map.each do |field_or_group_key, config|
          new_path = path + [field_or_group_key]
          if config[:type] == 'DynamicFieldGroup'
            all_fields.concat get_all_fields(config[:children], new_path)
          else
            config[:path] = new_path
            all_fields.append(config)
          end
        end

        all_fields
      end

      def get_terms(dynamic_field_map, data)
        terms = {}

        data.each do |field_or_group_key, value|
          next unless dynamic_field_map.key?(field_or_group_key)

          reduced_map = dynamic_field_map[field_or_group_key]

          case reduced_map[:type]
          when 'DynamicFieldGroup'
            next unless value.is_a?(Array)

            value.each do |v|
              get_terms(reduced_map[:children], v).each do |vocab, new_terms|
                terms[vocab] = terms.fetch(vocab, []).concat(new_terms)
              end
            end
          when 'DynamicField'
            next unless reduced_map[:field_type] == DynamicField::Type::CONTROLLED_TERM
            next unless value.is_a?(Hash)
            vocab = reduced_map[:controlled_vocabulary]

            terms[vocab] = [] unless terms.key?(vocab)
            terms[vocab] += [value]
          end
        end

        terms
      end

      def get_langs(dynamic_field_map, data)
        langs = []

        data.each do |field_or_group_key, value|
          next unless dynamic_field_map.key?(field_or_group_key)

          reduced_map = dynamic_field_map[field_or_group_key]

          case reduced_map[:type]
          when 'DynamicFieldGroup'
            next unless value.is_a?(Array)

            value.each do |v|
              get_langs(reduced_map[:children], v).tap do |new_langs|
                langs.concat(new_langs)
              end
            end
          when 'DynamicField'
            next unless reduced_map[:field_type] == DynamicField::Type::LANG
            next unless value.is_a?(Hash)
            langs << value
          end
        end

        langs
      end

      # Generates map of dynamic fields for the given metadata form.
      #
      # @param [Array<String>] for_metadata_form limits map to fields related forms
      def generate_map(for_metadata_form)
        valid_metadata_forms = DynamicFieldCategory.metadata_forms.keys
        raise ArgumentError, "for_metadata_form parameters must be one of #{valid_metadata_forms}. Given #{for_metadata_form}." unless (for_metadata_form - valid_metadata_forms).blank?

        categories = DynamicFieldCategory.where(metadata_form: for_metadata_form)
                                         .includes(dynamic_field_groups: [:dynamic_field_groups, :dynamic_fields])

        return {} if categories.empty?

        field_map(categories.collect_concat(&:dynamic_field_groups)).with_indifferent_access
      end

      # Generates a map of dynamic fields groups and dynamic fields.
      def field_map(fields_or_groups)
        fields_or_groups.map { |field_or_group|
          case field_or_group
          when DynamicField
            value = field_or_group.as_json.except(:id, :string_key, :sort_order)
          when DynamicFieldGroup
            value = { type: 'DynamicFieldGroup', is_repeatable: field_or_group.is_repeatable, children: field_map(field_or_group.children) }
          else
            raise 'Invalid type when generating field map'
          end

          [field_or_group.string_key, value]
        }.to_h
      end
  end
end
