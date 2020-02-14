# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DeleteDynamicField, type: :request do
  let(:dynamic_field) { FactoryBot.create(:dynamic_field) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:request) { graphql query, input: { id: dynamic_field.id } }
  end

  context 'when logged in user is an administrator' do
    before { sign_in_user as: :administrator }

    context 'when deleting a dynamic_field that exists' do
      let(:id) { dynamic_field.id }
      before do
        graphql query, input: { id: id }
      end

      it 'deletes record from database' do
        expect(DynamicField.find_by(id: id)).to be nil
      end
    end

    context 'when deleting a dynamic_field that does not exist' do
      before do
        graphql query, input: { id: "invalid-key" }
      end
      it 'returns errors' do
        expect(response.body).to be_json_eql(%(
          "Couldn't find DynamicField with 'id'=invalid-key"
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
    mutation ($input: DeleteDynamicFieldInput!) {
      deleteDynamicField(input: $input) {
        dynamicField {
          id
        }
      }
    }
    GQL
  end
end
