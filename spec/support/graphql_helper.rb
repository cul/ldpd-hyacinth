# frozen_string_literal: true

module GraphQLHelper
  def graphql(query, variables = {})
    params = { query: query }
    params[:variables] = variables.is_a?(Hash) ? variables.to_json : variables unless variables.blank?

    post '/graphql', params: params
  end

  def projects_query(is_primary: nil)
    # Remember: passing nil/null to isPrimary is a way to omit an isPrimary true/false filter altogether
    <<~GQL
      query {
        projects(isPrimary: #{is_primary}) {
          stringKey
          displayLabel
          projectUrl
          isPrimary
        }
      }
    GQL
  end

  def project_query(string_key)
    <<~GQL
      query {
        project(stringKey: "#{string_key}") {
          stringKey
          displayLabel
          projectUrl
          isPrimary
          projectPermissions {
            user {
              id,
              fullName
            },
            project {
              stringKey
              displayLabel
            },
            actions
          }
          enabledDigitalObjectTypes
        }
      }
    GQL
  end
end
