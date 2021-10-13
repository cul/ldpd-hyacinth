# frozen_string_literal: true

module Types
  module Facets
    class ValueTypeResults < Types::BaseObject
      description 'The search result type for Type::Facets::ValueType.'
      field :total_count, Integer, "Count of total results", null: false
      field :nodes, [Types::Facets::ValueType], "A list of facet values.", null: false
      field :page_info, Types::PageInfo, "Information to aid in pagination.", null: false

      def field_name
        object.dig('responseHeader', 'params', 'facet.field')
      end

      def limit
        object.dig('responseHeader', 'params', "f.#{field_name}.facet.limit").to_i
      end

      def offset
        object.dig('responseHeader', 'params', "f.#{field_name}.facet.offset").to_i
      end

      def total_count
        object.dig('stats', 'stats_fields', field_name, 'countDistinct').to_i
      end

      def raw_value_counts
        object.dig('facet_counts', 'facet_fields', field_name) || []
      end

      def page_info
        raise GraphQL::ExecutionError, 'ValueTypeResults can only be used on RSolr::HashWithResponse objects' unless object.is_a?(RSolr::HashWithResponse)
        limit_or_returned = limit.positive? ? limit : (raw_value_counts.length / 2)
        count = total_count
        {
          has_next_page: limit_or_returned + offset < count,
          has_previous_page: offset != 0 && !count.zero?
        }
      end

      # parse the facet values or return an empty array
      def nodes
        value_counts = raw_value_counts
        (0...value_counts.length).step(2).map { |ix| { value: value_counts[ix], count: value_counts[ix + 1] } }
      end
    end
  end
end
