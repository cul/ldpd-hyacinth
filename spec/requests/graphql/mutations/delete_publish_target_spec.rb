# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DeletePublishTarget, type: :request do
  let(:project) { FactoryBot.create(:project) }
  let(:string_key) { publish_target.string_key }
  let(:publish_target) { FactoryBot.create(:publish_target, project: project, string_key: 'great_project_publish_target') }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) { { input: { projectStringKey: project.string_key, stringKey: publish_target.string_key } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user is an administrator' do
    before { sign_in_user as: :administrator }

    context 'when deleting a publish_target that exists' do
      let(:variables) { { input: { projectStringKey: project.string_key, stringKey: publish_target.string_key } } }

      before { graphql query, variables }

      it 'deletes record from database' do
        expect(PublishTarget.find_by(project: project, string_key: string_key)).to be nil
      end
    end

    context 'when deleting a publish_target that dooes not exist' do
      let(:variables) { { input: { projectStringKey: project.string_key, stringKey: 'not-valid' } } }

      before { graphql query, variables }

      it 'returns errors' do
        expect(response.body).to be_json_eql(%(
          "Couldn't find PublishTarget"
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: DeletePublishTargetInput!) {
        deletePublishTarget(input: $input) {
          publishTarget {
            stringKey
          }
        }
      }
    GQL
  end
end
