# frozen_string_literal: true

module Types
  module Pageable
    extend ActiveSupport::Concern

    module ClassMethods
      def results_type(&block)
        wrapped_type = self

        GraphQL::ObjectType.define do
          type_name = wrapped_type.is_a?(GraphQL::BaseType) ? wrapped_type.name : wrapped_type.graphql_name

          name("#{type_name}Results")
          description("The search result type for #{type_name}.")

          field :totalCount, !types.Int, "Count of total results", property: :total_count
          field :nodes, types[wrapped_type], "A list of nodes."
          field :pageInfo, PageInfo.to_non_null_type, "Information to aid in pagination.", property: :page_info

          # Once we have a use case for edges we can add them here. Because we don't have any
          # information to add to an edge besides a node, its probably best to discorage their use.

          block && instance_eval(&block)
        end
      end
    end
  end
end
