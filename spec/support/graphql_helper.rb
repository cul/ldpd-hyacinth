module GraphQLHelper
  def graphql(query)
    post '/graphql', params: { query: query }
  end
end
