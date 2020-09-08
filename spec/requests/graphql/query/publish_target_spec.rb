# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Publish Targets', type: :request do
  let(:project) { FactoryBot.create(:project) }
  let(:publish_target) { FactoryBot.create(:publish_target, project: project) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:request) do
      graphql query(publish_target.target_type)
    end
  end

  context 'when logged in user is admin' do
    before { sign_in_user as: :administrator }

    context 'when type is valid' do
      before do
        graphql query(publish_target.target_type)
      end

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%({
          "project": {
            "stringKey": "#{project.string_key}",
            "publishTarget": {
              "apiKey": "#{publish_target.api_key}",
              "publishUrl": "https://www.example.com/publish",
              "type": "PRODUCTION",
              "doiPriority": 100,
              "isAllowedDoiTarget": false
            }
          }
        })).at_path('data')
      end
    end
  end

  context 'when logged in user is not an admin, but has read permissions' do
    before { sign_in_project_contributor to: :read_objects, project: project }

    context 'when type is valid' do
      before do
        graphql query(publish_target.target_type)
      end

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%({
          "project": {
            "stringKey": "#{project.string_key}",
            "publishTarget": {
              "apiKey": "#{Types::PublishTargetType::OBSCURED_API_KEY}",
              "publishUrl": "https://www.example.com/publish",
              "type": "PRODUCTION",
              "doiPriority": 100,
              "isAllowedDoiTarget": false
            }
          }
        })).at_path('data')
      end
    end

    context 'when type is invalid' do
      before { graphql query('not_valid') }

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%(
          "Argument 'type' on Field 'publishTarget' has an invalid value. Expected type 'PublishTargetTypeEnum!'."
        )).at_path('errors/0/message')
      end
    end
  end

  def query(target_type)
    <<~GQL
      query {
        project(stringKey: "#{project.string_key}") {
          stringKey
          publishTarget(type: #{target_type.upcase}) {
            type
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
