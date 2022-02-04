# frozen_string_literal: true

module GraphQLHelper
  def graphql(query, variables = {})
    params = { query: query }
    if variables.present?
      params[:variables] = variables.is_a?(Hash) ? variables.to_json : variables
    end
    post '/graphql', params: params
  end
end
