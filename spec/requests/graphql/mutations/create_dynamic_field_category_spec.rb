# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::CreateDynamicFieldCategory, type: :request do
  describe '.resolve' do
    include_examples 'requires user to have correct permissions for graphql request' do
      let(:variables) { { input: { displayLabel: 'Another Dynamic Field Category', sortOrder: 8 } } }
      let(:request) { graphql query, variables }
    end

    context 'when logged in user has appropriate permissions' do
      before { sign_in_user as: :administrator }

      context 'when creating a new project' do
        let(:variables) do
          {
            input: {
              displayLabel: 'Another Dynamic Field Category',
              sortOrder: 8
            }
          }
        end

        before { graphql query, variables }

        it 'returns correct response' do
          expect(response.body).to be_json_eql(%({
            "dynamicFieldCategory": {
              "displayLabel": "Another Dynamic Field Category",
              "children": [],
              "sortOrder": 8
            }
          })).at_path('data/createDynamicFieldCategory')
        end

        it 'creates new dynamic field category' do
          expect(DynamicFieldCategory.find_by(display_label: 'Another Dynamic Field Category')).not_to be nil
        end
      end

      context 'when create request is missing displayLabel' do
        let(:variables) do
          { input: {  sortOrder: 8 } }
        end

        before { graphql query, variables }

        it 'returns error' do
          expect(response.body).to be_json_eql(%(
            "Variable input of type CreateDynamicFieldCategoryInput! was provided invalid value for displayLabel (Expected value to not be null)"
          )).at_path('errors/0/message')
        end
      end

      context 'when create request is missing sortOrder' do
        let(:variables) do
          { input: {  displayLabel: 'New Dynamic Field Category' } }
        end

        before { graphql query, variables }

        it 'returns error' do
          expect(response.body).to be_json_eql(%(
            "Variable input of type CreateDynamicFieldCategoryInput! was provided invalid value for sortOrder (Expected value to not be null)"
          )).at_path('errors/0/message')
        end
      end
    end

    def query
      <<~GQL
        mutation ($input: CreateDynamicFieldCategoryInput!) {
          createDynamicFieldCategory(input: $input) {
            dynamicFieldCategory {
              displayLabel,
              children {id},
              sortOrder
            }
          }
        }
      GQL
    end
  end
end
