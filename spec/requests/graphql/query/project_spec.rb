require 'rails_helper'

RSpec.describe 'Retrieving Project', type: :request do
  let(:project) { FactoryBot.create(:project) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:request) { graphql query(project.string_key) }
  end

  context 'when logged in user has appropriate permissions' do
    before do
      sign_in_project_contributor to: :read_objects, project: project
    end

    context 'when string_key is valid' do
      before { graphql query(project.string_key) }

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%({
          "project": {
            "displayLabel": "Great Project",
            "projectUrl": "https://example.com/great_project",
            "stringKey": "great_project"
          }
        })).at_path('data')
      end
    end

    context 'when string_key is invalid' do
      before { graphql query('test-string-key') }

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%(
          "Couldn't find Project"
        )).at_path('errors/0/message')
      end
    end
  end

  def query(string_key)
    <<~GQL
      query {
        project(stringKey: "#{string_key}") {
          stringKey
          displayLabel
          projectUrl
        }
      }
    GQL
  end
end
