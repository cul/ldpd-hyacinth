# frozen_string_literal: true

class GraphqlController < ApplicationController
  skip_before_action :verify_authenticity_token

  def execute
    variables = ensure_hash(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      # Query context goes here, for example:
      current_user: current_user,
      ability: current_ability
    }
    result = HyacinthSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue => e
    raise e unless Rails.env.development?
    handle_error_in_development e
  end

  private

    # Handle form data, JSON body, or a blank value
    def ensure_hash(ambiguous_param)
      case ambiguous_param
      when String
        ambiguous_param.present? ? ensure_hash(JSON.parse(ambiguous_param)) : {}
      when Hash
        ambiguous_param
      when ActionController::Parameters
        ambiguous_param.to_unsafe_hash
      when nil
        {}
      else
        raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
      end
    end

    def handle_error_in_development(e)
      logger.error e.message
      logger.error e.backtrace.join("\n")

      render json: { error: { message: e.message, backtrace: e.backtrace }, data: {} }, status: :internal_server_error
    end
end
