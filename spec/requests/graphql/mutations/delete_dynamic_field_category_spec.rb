# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DeleteDynamicFieldCategory, type: :request do
  let(:dynamic_field_category) { FactoryBot.create(:dynamic_field_category) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) { { input: { id: dynamic_field_category.id } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user has appropriate permissions' do
    before { sign_in_user as: :administrator }

    context 'when deleting a dynamic field category that exists' do
      before do
        graphql query, input: { id: dynamic_field_category.id }
      end

      it 'deletes record from database' do
        expect(DynamicFieldCategory.find_by(id: dynamic_field_category.id)).to be nil
      end
    end

    context 'when deleting a dynamic field category that does not exist' do
      before { graphql query, input: { id: '1234' } }

      it 'returns errors' do
        expect(response.body).to be_json_eql(%(
          "Couldn't find DynamicFieldCategory with 'id'=1234"
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: DeleteDynamicFieldCategoryInput!) {
        deleteDynamicFieldCategory(input: $input) {
          dynamicFieldCategory {
            id
          }
        }
      }
    GQL
  end
end
