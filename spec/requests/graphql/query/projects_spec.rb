# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Projects', type: :request do
  include_examples 'requires user to have correct permissions for graphql request' do
    let(:request) { graphql projects_query }
  end

  context 'when logged in user is an admin shows all projects' do
    describe 'when there are multiple results' do
      before do
        sign_in_user as: :administrator
        FactoryBot.create(:project)
        FactoryBot.create(:project, :legend_of_lincoln)
        graphql projects_query
      end

      it 'returns all projects' do
        expect(response.body).to be_json_eql(%(
          {
            "projects": [
              {
                "displayLabel": "Great Project",
                "isPrimary": true,
                "projectUrl": "https://example.com/great_project",
                "stringKey": "great_project"
              },
              {
                "displayLabel": "Legend of Lincoln",
                "isPrimary": true,
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
      graphql projects_query
    end

    it 'returns 1 project' do
      expect(response.body).to be_json_eql(%(
        {
          "projects": [
            {
              "displayLabel": "Great Project",
              "isPrimary": true,
              "projectUrl": "https://example.com/great_project",
              "stringKey": "great_project"
            }
          ]
        }
      )).at_path('data')
    end
  end

  context 'when querying with isPrimary argument' do
    before do
      sign_in_user as: :administrator
      FactoryBot.create(:project, :legend_of_lincoln)
      FactoryBot.create(:project, :myth_of_minken)
    end

    context 'when isPrimary is set to true' do
      before do
        graphql projects_query(is_primary: true)
      end
      it 'only returns primary projects' do
        expect(response.body).to be_json_eql(%(
          {
            "projects": [
              {
                "displayLabel": "Legend of Lincoln",
                "isPrimary": true,
                "projectUrl": "https://example.com/legend_of_lincoln",
                "stringKey": "legend_of_lincoln"
              }
            ]
          }
        )).at_path('data')
      end
    end

    context 'when isPrimary is set to false' do
      before do
        graphql projects_query(is_primary: false)
      end

      it 'only returns non-primary projects' do
        expect(response.body).to be_json_eql(%(
          {
            "projects": [
              {
                "displayLabel": "Myth of Minken",
                "isPrimary": false,
                "projectUrl": "https://example.com/myth_of_minken",
                "stringKey": "myth_of_minken"
              }
            ]
          }
        )).at_path('data')
      end
    end
  end
end
