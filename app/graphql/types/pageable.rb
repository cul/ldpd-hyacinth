# frozen_string_literal: true

module Types
  module Pageable
    extend ActiveSupport::Concern

    module ClassMethods
      def results_type(&block)
        wrapped_type = self

        Class.new(GraphQL::Schema::Object) do
          type_extends_graphql_schema_object = wrapped_type < GraphQL::Schema::Object
          type_name = type_extends_graphql_schema_object ? wrapped_type.graphql_name : wrapped_type.name.demodulize

          graphql_name("#{type_name}Results")
          description("The search result type for #{type_name}.")

          field :totalCount, Integer, "Count of total results", method: :total_count
          field :nodes, [wrapped_type], "A list of nodes."
          field :facets, [Types::Facets::FieldType], "A list of facets.", method: :facets
          field :pageInfo, PageInfo.to_non_null_type, "Information to aid in pagination.", method: :page_info

          # Once we have a use case for edges we can add them here. Because we don't have any
          # information to add to an edge besides a node, its probably best to discorage their use.

          block && instance_eval(&block)
        end
      end
    end
  end
end
