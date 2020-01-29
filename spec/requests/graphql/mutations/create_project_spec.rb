# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::CreateProject, type: :request do
  describe '.resolve' do
    include_examples 'requires user to have correct permissions for graphql request' do
      let(:variables) { { input: { stringKey: 'best_project', displayLabel: 'Best Project' } } }
      let(:request) { graphql query, variables }
    end

    context 'when logged in user has appropriate permissions' do
      before { sign_in_user as: :administrator }

      context 'when creating a new project' do
        let(:variables) do
          {
            input: {
              stringKey: 'best_project',
              displayLabel: 'Best Project',
              isPrimary: true,
              hasAssetRights: true,
              projectUrl: 'https://best_project.com'
            }
          }
        end

        before { graphql query, variables }

        it 'returns correct response' do
          expect(response.body).to be_json_eql(%({
            "project": {
              "displayLabel": "Best Project",
              "isPrimary": true,
              "hasAssetRights": true,
              "projectUrl": "https://best_project.com",
              "stringKey": "best_project"
            }
          })).at_path('data/createProject')
        end

        it 'creates new project' do
          expect(Project.find_by(string_key: 'best_project')).not_to be nil
        end
      end

      context 'when create request is missing string_key' do
        let(:variables) do
          { input: { displayLabel: 'Best Project', projectUrl: 'https://best_project.com' } }
        end

        before { graphql query, variables }

        it 'returns error' do
          expect(response.body).to be_json_eql(%(
            "Variable input of type CreateProjectInput! was provided invalid value for stringKey (Expected value to not be null)"
          )).at_path('errors/0/message')
        end
      end

      context 'when create request is missing display_label' do
        let(:variables) do
          { input: { stringKey: 'best_project', projectUrl: 'https://best_project.com' } }
        end

        before { graphql query, variables }

        it 'returns error' do
          expect(response.body).to be_json_eql(%(
            "Variable input of type CreateProjectInput! was provided invalid value for displayLabel (Expected value to not be null)"
          )).at_path('errors/0/message')
        end
      end
    end

    def query
      <<~GQL
        mutation ($input: CreateProjectInput!) {
          createProject(input: $input) {
            project {
              stringKey
              displayLabel
              projectUrl
              isPrimary
              hasAssetRights
            }
          }
        }
      GQL
    end
  end
end
