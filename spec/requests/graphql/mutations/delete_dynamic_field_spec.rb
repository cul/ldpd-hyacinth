# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DeleteDynamicField, type: :request do
  let(:dynamic_field) { FactoryBot.create(:dynamic_field) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:request) { graphql query, input: { stringKey: dynamic_field.string_key } }
  end

  context 'when logged in user is an administrator' do
    before { sign_in_user as: :administrator }

    context 'when deleting a dynamic_field that exists' do
      let(:stringKey) { dynamic_field.string_key }
      before do
        graphql query, input: { stringKey: stringKey }
      end

      it 'deletes record from database' do
        expect(DynamicField.find_by(string_key: stringKey)).to be nil
      end
    end

    context 'when deleting a dynamic_field that does not exist' do
      before do
        graphql query, input: { stringKey: "invalid-key" }
      end
      it 'returns errors' do
        expect(response.body).to be_json_eql(%(
          "Couldn't find DynamicField"
        )).at_path('errors/0/message')
      end
    end
  end
  def query
    <<~GQL
    mutation ($input: DeleteDynamicFieldInput!) {
      deleteDynamicField(input: $input) {
        dynamicField {
          stringKey
        }
      }
    }
    GQL
  end
end
