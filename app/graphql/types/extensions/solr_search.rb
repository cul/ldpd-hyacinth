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
          facets: facets(value.fetch('facet_counts', {})),
          page_info: OpenStruct.new(
            has_next_page: limit + offset < total_count,
            has_previous_page: offset != 0 && !total_count.zero?
          )
        )
      end

      # parse the facet objects or return an empty array
      def facets(facet_counts)
        return [] unless facet_counts['facet_fields']
        facet_counts['facet_fields'].map do |facet_field, value_counts|
          {
            field_name: facet_field,
            display_label: facet_field.split('_')[0...-1].map(&:titlecase).join(' '),
            values: (0...value_counts.length).step(2).map { |ix| { value: value_counts[ix], count: value_counts[ix + 1] } }
          }
        end
      end
    end
  end
end
