# frozen_string_literal: true

class HyacinthSchema < GraphQL::Schema
  use GraphQL::Execution::Errors

  rescue_from(ActiveRecord::RecordNotFound) do |err, _obj, _args, _ctx, _field|
    # Raise a graphql-friendly error with a custom message or we could just send back nil
    raise GraphQL::ExecutionError, err.message.to_s
  end

  rescue_from ActiveRecord::RecordInvalid do |exception|
    raise GraphQL::ExecutionError, exception.record.errors.full_messages.join('; ')
  end

  rescue_from(CanCan::AccessDenied) do |err, _obj, _args, _ctx, _field|
    # Raise a graphql-friendly error with a custom message or we could just send back nil
    raise GraphQL::ExecutionError, err.message.to_s
  end

  mutation(Types::MutationType)
  query(Types::QueryType)
end
