# frozen_string_literal: true

module Types
  module Extensions
    class SolrSearch < GraphQL::Schema::FieldExtension
      def apply
        field.argument :limit, "Types::Scalar::Limit", required: true
        field.argument :offset, "Types::Scalar::Offset", required: false
        field.argument :query, String, required: false
        field.argument :filters, [FilterAttributes], required: false
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
          page_info: OpenStruct.new(
            has_next_page: limit + offset < total_count,
            has_previous_page: offset != 0 && !total_count.zero?
          )
        )
      end
    end
  end
end
