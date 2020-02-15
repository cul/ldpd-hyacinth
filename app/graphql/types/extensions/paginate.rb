# frozen_string_literal: true

module Types
  module Extensions
    class Paginate < GraphQL::Schema::FieldExtension
      def apply
        field.argument :limit, "Types::Scalar::Limit", required: true
        field.argument :offset, "Types::Scalar::Offset", required: false
      end

      def resolve(object:, arguments:, context:)
        unpaginated_args = arguments.dup
        unpaginated_args.delete(:limit)
        unpaginated_args.delete(:offset)
        yield(object, unpaginated_args)
      end

      def after_resolve(object:, arguments:, value:, context:, memo:)
        raise GraphQL::ExecutionError, 'Paginate extension can only be used on ActiveRecord:Relation objects' unless value.is_a?(ActiveRecord::Relation)

        limit = arguments[:limit]
        offset = arguments.fetch(:offset, 0)
        total_count = value.count

        OpenStruct.new(
          total_count: total_count,
          nodes: value.limit(limit).offset(offset),
          page_info: OpenStruct.new(
            has_next_page: limit + offset < total_count,
            has_previous_page: !offset.zero? && !total_count.zero?
          )
        )
      end
    end
  end
end
