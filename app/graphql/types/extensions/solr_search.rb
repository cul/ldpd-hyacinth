# frozen_string_literal: true

module Types
  module Extensions
    class SolrSearch < GraphQL::Schema::FieldExtension
      def apply
        field.argument :limit, "Types::Scalar::Limit", required: true
        field.argument :offset, "Types::Scalar::Offset", required: false
        field.argument :search_params, Types::SearchAttributes, required: false
        field.argument :filters, [FilterAttributes, null: true], required: false
      end

      def resolve(object:, arguments:, context:)
        yield(object, arguments)
      end

      def after_resolve(object:, arguments:, value:, context:, memo:)
        raise GraphQL::ExecutionError, 'SolrSearch can only be used on RSolr::HashWithResponse objects' unless value.is_a?(RSolr::HashWithResponse)

        limit = arguments[:limit]
        offset = arguments.fetch(:offset, 0)
        total_count = value['response']['numFound']

        OpenStruct.new(
          total_count: total_count,
          nodes: value['response']['docs'],
          facets: facets(value.fetch('facet_counts', {}), value.fetch('stats', {})),
          page_info: OpenStruct.new(
            has_next_page: limit + offset < total_count,
            has_previous_page: offset != 0 && !total_count.zero?
          )
        )
      end

      # parse the facet objects or return an empty array
      def facets(facet_counts, stats)
        return [] unless facet_counts['facet_fields']
        display_label_map = Hyacinth::DigitalObject::Facets.facet_display_label_map
        facet_page_size = Hyacinth::Config.digital_object_search_adapter.ui_config.facet_page_size

        facet_counts['facet_fields'].map do |facet_field, value_counts|
          has_more = !value_counts[2 * facet_page_size].nil?
          {
            field_name: facet_field,
            display_label: display_label_map[facet_field] || facet_field.split('_')[0...-1].map(&:titlecase).join(' '),
            values: facet_values_from_counts(value_counts, facet_page_size),
            total_count: stats.dig('stats_fields', facet_field, 'countDistinct').to_i,
            has_more: has_more
          }
        end
      end

      def facet_values_from_counts(value_counts, facet_page_size)
        value_parse_limit = (value_counts.length / 2) < facet_page_size ? value_counts.length : (2 * facet_page_size)
        (0...value_parse_limit).step(2).map { |ix| { value: value_counts[ix], count: value_counts[ix + 1] } }
      end
    end
  end
end
