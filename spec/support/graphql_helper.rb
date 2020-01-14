# frozen_string_literal: true

module GraphQLHelper
  def graphql(query, variables = {})
    params = { query: query }
    params[:variables] = variables.is_a?(Hash) ? variables.to_json : variables unless variables.blank?

    post '/graphql', params: params
  end

  def projects_query(is_primary: nil)
    if is_primary.nil?
      <<~GQL
        query {
          projects {
            stringKey
            displayLabel
            projectUrl
            isPrimary
          }
        }
      GQL
    else
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
