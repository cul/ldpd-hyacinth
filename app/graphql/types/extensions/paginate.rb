# frozen_string_literal: true

module Types
  module Extensions
    class Paginate < GraphQL::Schema::FieldExtension
      def apply
        field.argument :limit, "Types::Scalar::Limit", required: true
        field.argument :offset, "Types::Scalar::Offset", required: false
      end

      def resolve(object:, arguments:, **rest)
        # Since the underlying type that we're extending doesn't have limit and offset fields,
        # we only want to yield arguments that are NOT limit or offset.
        unpaginated_args = arguments.dup
        limit = unpaginated_args.delete(:limit)
        offset = unpaginated_args.delete(:offset)
        # The arguments passed to yield are the arguments that are passed to after_resolve,
        # so we need to pass limit and offset in the third "memo" argument so they're available.
        yield(object, unpaginated_args, { limit: limit, offset: offset })
      end

      def after_resolve(value:, arguments:, memo:,  **rest)
        raise GraphQL::ExecutionError, 'Paginate extension can only be used on ActiveRecord:Relation objects' unless value.is_a?(ActiveRecord::Relation)
        limit = memo[:limit]
        offset = memo[:offset] || 0
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
