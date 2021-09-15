# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DeleteDynamicFieldGroup, type: :request do
  let(:dynamic_field_group) { FactoryBot.create(:dynamic_field_group) }

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:variables) { { input: { id: dynamic_field_group.id } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user has appropriate permissions' do
    before { sign_in_user as: :administrator }

    context 'when deleting a dynamic field group that exists' do
      before do
        graphql query, input: { id: dynamic_field_group.id }
      end

      it 'deletes record from database' do
        expect(DynamicFieldGroup.find_by(id: dynamic_field_group.id)).to be nil
      end
    end

    context 'when deleting a dynamic field group that does not exist' do
      before { graphql query, input: { id: 'invalid-id' } }

      it 'returns errors' do
        expect(response.body).to be_json_eql(%(
          "Couldn't find DynamicFieldGroup with 'id'=invalid-id"
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
