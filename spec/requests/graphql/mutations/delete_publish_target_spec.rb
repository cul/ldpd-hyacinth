# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DeletePublishTarget, type: :request do
  let(:publish_target) { FactoryBot.create(:publish_target) }

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:variables) { { input: { stringKey: publish_target.string_key } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user is an administrator' do
    before { sign_in_user as: :administrator }

    context 'when deleting a publish_target that exists' do
      let(:variables) { { input: { stringKey: publish_target.string_key } } }

      before { graphql query, variables }

      it 'deletes record from database' do
        expect(PublishTarget.find_by(string_key: publish_target.string_key)).to be nil
      end
    end

    context 'when deleting a publish_target with an invalid type' do
      let(:variables) { { input: { stringKey: 'not-valid' } } }

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
