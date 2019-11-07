module GraphQLHelper
  def graphql(query, variables = {})
    params = { query: query }
    params[:variables] = variables.is_a?(Hash) ? variables.to_json : variables unless variables.blank?

    post '/graphql', params: params
  end
end
