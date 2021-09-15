# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Projects', type: :request do
  include_examples 'requires user to have correct permissions for graphql request' do
    let(:request) { graphql query }
  end

  context 'when logged in user is an admin shows all projects' do
    describe 'when there are multiple results' do
      before do
        sign_in_user as: :administrator
        FactoryBot.create(:project)
        FactoryBot.create(:project, :legend_of_lincoln)
        graphql query
      end

      it 'returns all projects' do
        expect(response.body).to be_json_eql(%(
          {
            "projects": [
              {
                "displayLabel": "Great Project",
                "hasAssetRights": false,
                "projectUrl": "https://example.com/great_project",
                "stringKey": "great_project"
              },
              {
                "displayLabel": "Legend of Lincoln",
                "hasAssetRights": false,
                "projectUrl": "https://example.com/legend_of_lincoln",
                "stringKey": "legend_of_lincoln"
              }
            ]
          }
        )).at_path('data')
      end
    end
  end

  context 'when logged-in user only has permissions to one project' do
    before do
      project = FactoryBot.create(:project)
      FactoryBot.create(:project, :legend_of_lincoln)
      sign_in_project_contributor to: :read_objects, project: project
      graphql query
    end

    it 'returns 1 project' do
      expect(response.body).to be_json_eql(%(
        {
          "projects": [
            {
              "displayLabel": "Great Project",
              "hasAssetRights": false,
              "projectUrl": "https://example.com/great_project",
              "stringKey": "great_project"
            }
          ]
        }
      )).at_path('data')
    end
  end

  def query
    <<~GQL
      query {
        projects {
          stringKey
          displayLabel
          projectUrl
          hasAssetRights
        }
      }
    GQL
  end
end
