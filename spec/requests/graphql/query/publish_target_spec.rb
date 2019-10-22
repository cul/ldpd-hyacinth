require 'rails_helper'

RSpec.describe 'Retrieving Publish Targets', type: :request do
  let(:project) { FactoryBot.create(:project) }
  let(:publish_target) { FactoryBot.create(:publish_target, project: project) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:request) do
      graphql query(publish_target.string_key)
    end
  end

  context 'when logged in user has correct permissions' do
    before { sign_in_project_contributor to: :read_objects, project: project }

    context 'when string_key is valid' do
      before do
        graphql query(publish_target.string_key)
      end

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%({
          "project": {
            "stringKey": "great_project",
            "publishTarget": {
              "apiKey": "bestapikey",
              "displayLabel": "Great Project Website",
              "publishUrl": "https://www.example.com/publish",
              "stringKey": "great_project_website",
              "doiPriority": 100,
              "isAllowedDoiTarget": false
            }
          }
        })).at_path('data')
      end
    end

    context 'when string_key is invalid' do
      before { graphql query('not_valid') }

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%(
          "Couldn't find PublishTarget"
        )).at_path('errors/0/message')
      end
    end
  end

  def query(string_key)
    <<~GQL
      query {
        project(stringKey: "#{project.string_key}") {
          stringKey
          publishTarget(stringKey: "#{string_key}") {
            stringKey
            displayLabel
            publishUrl
            doiPriority
            isAllowedDoiTarget
            apiKey
          }
        }
      }
    GQL
  end
end
