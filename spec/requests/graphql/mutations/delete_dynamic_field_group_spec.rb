# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DeleteDynamicFieldGroup, type: :request do
  let(:dynamic_field_group) { FactoryBot.create(:dynamic_field_group) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) { { input: { stringKey: dynamic_field_group.string_key } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user has appropriate permissions' do
    before { sign_in_user as: :administrator }

    context 'when deleting a dynamic field group that exists' do
      before do
        graphql query, input: { stringKey: dynamic_field_group.string_key }
      end

      it 'deletes record from database' do
        expect(DynamicFieldGroup.find_by(string_key: dynamic_field_group.string_key)).to be nil
      end
    end

    context 'when deleting a dynamic field group that does not exist' do
      before { graphql query, input: { stringKey: 'invalid-string-key' } }

      it 'returns errors' do
        expect(response.body).to be_json_eql(%(
          "Couldn't find DynamicFieldGroup"
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: DeleteDynamicFieldGroupInput!) {
        deleteDynamicFieldGroup(input: $input) {
          dynamicFieldGroup {
            id
          }
        }
      }
    GQL
  end
end
