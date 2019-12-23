# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieve project permissions for project', type: :request do
  let(:project) { FactoryBot.create(:project) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:request) { graphql query(project.string_key) }
  end

  context 'when logged-in user has manage permission for the specified project' do
    before do
      project = FactoryBot.create(:project)
      FactoryBot.create(:project, :legend_of_lincoln)
      sign_in_project_contributor to: :manage, project: project
      graphql query(project.string_key)
    end

    it 'returns the correct response' do
      expect(response.body).to be_json_eql(%({
        "projectPermissionsForProject": [
          {
            "actions": [
              "manage"
            ],
            "project": {
              "displayLabel": "Great Project",
              "stringKey": "great_project"
            },
            "user": {
              "fullName": "Signed In User"
            }
          }
        ]
      })).at_path('data')
    end
  end

  def query(project_string_key)
    <<~GQL
      query {
        projectPermissionsForProject(stringKey: "#{project_string_key}") {
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
      }
    GQL
  end
end
