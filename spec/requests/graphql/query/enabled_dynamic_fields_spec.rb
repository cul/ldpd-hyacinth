# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Enabled Dynamic Fields', type: :request do
  let(:project) { FactoryBot.create(:project) }
  let(:field_set) { FactoryBot.create(:field_set, project: project) }
  let(:dynamic_field) { FactoryBot.create(:dynamic_field) }
  let(:default_value) { "exampleDefaultValue" }
  let(:digital_object_type) { "item" }
  let!(:enabled_dynamic_field) do
    FactoryBot.create(:enabled_dynamic_field, project: project, digital_object_type: digital_object_type,
      dynamic_field: dynamic_field, required: false, default_value: default_value, field_sets: [field_set])
  end

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:request) { graphql query(project.string_key, digital_object_type) }
  end

  context 'when logged in user is an administrator' do
    before { sign_in_user as: :administrator }
    context 'when id is valid' do
      before { graphql query(project.string_key, enabled_dynamic_field.digital_object_type) }
      it 'returns correct response' do
        expect(response.body).to be_json_eql(%({  "enabledDynamicFields": [{
          "digitalObjectType": "item", "type": "EnabledDynamicField", "project": { "stringKey": "#{project.string_key}" },
          "hidden": false, "locked": false, "ownerOnly": false, "required": false, "defaultValue": "#{default_value}",
          "shareable": false, "dynamicField": { "id": #{dynamic_field.id} }, "fieldSets": [ { "id": #{field_set.id} } ] }]
          })).at_path('data')
      end
    end

    context 'when project string key is invalid' do
      before { graphql query('not-valid', enabled_dynamic_field.digital_object_type) }
      it 'returns correct response' do
        expect(response.body).to be_json_eql(%(
           "Couldn't find Project"
          )).at_path('errors/0/message')
      end
    end
  end

  def query(project_string_key, digital_object_type)
    <<~GQL
    query {
      enabledDynamicFields(project: {stringKey: "#{project_string_key}"}, digitalObjectType: #{digital_object_type}) {
        type: __typename
        project {
          stringKey
        }
        dynamicField {
          id
        }
        fieldSets {
          id
        }
        digitalObjectType
        required
        locked
        hidden
        ownerOnly
        defaultValue
        shareable
      }
    }
    GQL
  end
end
