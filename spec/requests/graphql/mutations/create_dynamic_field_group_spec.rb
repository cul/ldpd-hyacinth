# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::CreateDynamicFieldGroup, type: :request do
  let(:parent) { FactoryBot.create(:dynamic_field_category) }
  # let!(:field_export_profile) { FactoryBot.create(:field_export_profile) }

  describe '.resolve' do

    context 'when logged in user has appropriate permissions' do
    let(:variables) do
      {
        input: {
          stringKey: 'location', displayLabel: 'Location', sortOrder: 8,
          isRepeatable: true, parentType: parent.class.to_s, parentId: parent.id
        }
      }
    end
      before { sign_in_user as: :administrator }

      context 'when creating a new group' do
        before { graphql query, variables }

        it 'returns correct response' do
           expect(response.body).to be_json_eql(%({
            "dynamicFieldGroup": {
                "parentType": "DynamicFieldCategory",
                "children": [],
                "displayLabel": "Location",
                "isRepeatable": true,
                "stringKey": "location",
                "type": "DynamicFieldGroup",
                "sortOrder": 8
            }
          })).at_path('data/createDynamicFieldGroup')
         
         # "exportRules": [ { "translation_logic": "[\\n\\n]"}]

        end

        it 'creates new dynamic field group' do
          expect(DynamicFieldGroup.find_by(display_label: 'Location')).not_to be nil
        end
      end

      it 'adds child to parent' do
         parent.reload
         expect(parent.children.length).to be 1
      end

      context 'when creating without a string_key' do
        let(:variables) do
          {
            input: {
            displayLabel: 'Location', sortOrder: 8,
            isRepeatable: true, parentType: parent.class.to_s, parentId: parent.id
            }
          }
        end
        before { graphql query, variables }
        it 'returns errors' do
          expect(response.body).to be_json_eql(%(
                "Variable input of type CreateDynamicFieldGroupInput! was provided invalid value for stringKey (Expected value to not be null)" 
          )).at_path('errors/0/message')
        end
    end
  end
    def query
      <<~GQL
        mutation ($input: CreateDynamicFieldGroupInput!) {
          createDynamicFieldGroup(input: $input) {
            dynamicFieldGroup {
              parentType,
              children,
              displayLabel,
              isRepeatable,
              stringKey,
              type: __typename,
              sortOrder
            }
          }
        }
      GQL
    end
  end
end
