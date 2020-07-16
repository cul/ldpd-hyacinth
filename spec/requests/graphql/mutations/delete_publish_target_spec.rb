# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DeletePublishTarget, type: :request do
  let(:project) { FactoryBot.create(:project) }
  let(:target_type) { publish_target.target_type }
  let(:publish_target) { FactoryBot.create(:publish_target, project: project) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) { { input: { projectStringKey: project.string_key, type: target_type.upcase } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user is an administrator' do
    before { sign_in_user as: :administrator }

    context 'when deleting a publish_target that exists' do
      let(:variables) { { input: { projectStringKey: project.string_key, type: target_type.upcase } } }

      before { graphql query, variables }

      it 'deletes record from database' do
        expect(PublishTarget.find_by(project: project, target_type: target_type)).to be nil
      end
    end

    context 'when deleting a publish_target with an invalid type' do
      let(:variables) { { input: { projectStringKey: project.string_key, type: 'not-valid' } } }

      before { graphql query, variables }

      it 'returns errors' do
        expect(response.body).to be_json_eql(%(
          "Variable input of type DeletePublishTargetInput! was provided invalid value for type (Expected \\\"not-valid\\\" to be one of: PRODUCTION, STAGING)"
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: DeletePublishTargetInput!) {
        deletePublishTarget(input: $input) {
          publishTarget {
            type
          }
        }
      }
    GQL
  end
end
