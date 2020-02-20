# frozen_string_literal: true

class HyacinthSchema < GraphQL::Schema
  use GraphQL::Execution::Errors

  max_depth 13

  rescue_from(ActiveRecord::RecordNotFound) do |err, _obj, _args, _ctx, _field|
    # Raise a graphql-friendly error with a custom message or we could just send back nil
    error = "Couldn't find #{err.model}"
    error += " with '#{err.primary_key}'=#{err.id}" if err.primary_key && err.id
    raise GraphQL::ExecutionError, error
  end

  rescue_from ActiveRecord::RecordInvalid do |exception|
    raise GraphQL::ExecutionError, exception.record.errors.full_messages.join('; ')
  end

  rescue_from(CanCan::AccessDenied) do |err, _obj, _args, _ctx, _field|
    # Raise a graphql-friendly error with a custom message or we could just send back nil
    raise GraphQL::ExecutionError, err.message.to_s
  end

  rescue_from RSolr::Error::ConnectionRefused do |exception|
    Rails.logger.error exception.message

    raise GraphQL::ExecutionError, 'Unexpected Error'
  end

  rescue_from RSolr::Error::Http do |exception|
    Rails.logger.error exception.message
    Rails.logger.error exception.backtrace.join("\n")

    raise GraphQL::ExecutionError, 'Unexpected Error'
  end

  mutation(Types::MutationType)
  query(Types::QueryType)
end
