# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::CreateDynamicFieldGroup, type: :request do
  let!(:field_export_profile) { FactoryBot.create(:field_export_profile) }
  let(:parent) { FactoryBot.create(:dynamic_field_category) }

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:variables) do
      {
        input: {
          stringKey: 'location',
          displayLabel: 'Location',
          sortOrder: 8,
          isRepeatable: true,
          parentType: parent.class.to_s,
          parentId: parent.id
        }
      }
    end
    let(:request) { graphql query, variables }
  end

  context 'when logged in user has appropriate permissions' do
    before { sign_in_user as: :administrator }

    context 'when creating a new group' do
      let(:variables) do
        {
          input: {
            stringKey: 'location',
            displayLabel: 'Location',
            sortOrder: 8,
            isRepeatable: true,
            parentType: parent.class.to_s,
            parentId: parent.id,
            exportRules: [
              {
                fieldExportProfileId: field_export_profile.id,
                translationLogic: '{ "name": "something" }'
              }
            ]
          }
        }
      end

      let(:expected_response) do
        %(
          {
            "parent": {
              "type": "DynamicFieldCategory"
            },
            "children": [],
            "displayLabel": "Location",
            "isRepeatable": true,
            "stringKey": "location",
            "type": "DynamicFieldGroup",
            "sortOrder": 8,
            "exportRules": [
              {
                "fieldExportProfile": {
                  "id": "#{field_export_profile.id}"
                },
                "translationLogic": "{\\n  \\"name\\": \\"something\\"\\n}"
              }
            ]
          }
        )
      end

      before { graphql query, variables }

      it 'returns correct response' do
        expect(response.body).to be_json_eql(expected_response).at_path('data/createDynamicFieldGroup/dynamicFieldGroup')
      end

      it 'creates new dynamic field group' do
        expect(DynamicFieldGroup.find_by(display_label: 'Location')).not_to be nil
      end

      it 'adds child to parent' do
        parent.reload
        expect(parent.children.length).to be 1
      end

      it 'creates export rule' do
        expect(DynamicFieldGroup.find_by(string_key: 'location').export_rules.count).to be 1
      end
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

    context 'when creating with an incorrect parent object type' do
      let(:bad_parent) { FactoryBot.create(:dynamic_field) }
      let(:variables) do
        {
          input: {
            displayLabel: 'Location', sortOrder: 8, stringKey: 'location',
            isRepeatable: true, parentType: bad_parent.class.to_s, parentId: bad_parent.id
          }
        }
      end

      before { graphql query, variables }

      it 'returns an error' do
        expect(response.body).to be_json_eql(%(
          "Parent type is not among the list of allowed values"
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: CreateDynamicFieldGroupInput!) {
        createDynamicFieldGroup(input: $input) {
          dynamicFieldGroup {
            children,
            displayLabel,
            isRepeatable,
            stringKey,
            type: __typename,
            sortOrder,
            parent {
              type: __typename
            }
            exportRules {
              fieldExportProfile {
                id
              }
              translationLogic
            }
          }
        }
      }
    GQL
  end
end
