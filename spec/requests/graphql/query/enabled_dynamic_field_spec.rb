# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Enabled Dynamic Field', type: :request do
  let(:project) { FactoryBot.create(:project) }
  let(:dynamic_field) { FactoryBot.create(:dynamic_field) }
  let(:default_value) { "exampleDefaultValue" }
  let!(:enabled_dynamic_field) { FactoryBot.create(:enabled_dynamic_field, project: project, dynamic_field: dynamic_field, required: false, default_value: default_value) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:request) { graphql query(dynamic_field.id) }
  end

  context 'when logged in user is an administrator' do
    before { sign_in_user as: :administrator }
    context 'when id is valid' do
      before { graphql query(enabled_dynamic_field.id) }
      it 'returns correct response' do
        expect(response.body).to be_json_eql(%({  "enabledDynamicField": {
          "digitalObjectType": "item", "type": "EnabledDynamicField", "project": { "stringKey": "#{project.string_key}" },
          "hidden": false, "locked": false, "ownerOnly": false, "required": false, "defaultValue": "#{default_value}",
          "shareable": false, "dynamicField": { "id": #{dynamic_field.id} } } }
          )).at_path('data')
      end
    end

    context 'when id is invalid' do
      before { graphql query('not-valid') }
      it 'returns correct response' do
        expect(response.body).to be_json_eql(%(
           "Couldn't find EnabledDynamicField with 'id'=not-valid"
          )).at_path('errors/0/message')
      end
    end
  end

  def query(id)
    <<~GQL
    query {
      enabledDynamicField(id: "#{id}") {
        type: __typename
        id
        project {
          stringKey
        }
        dynamicField {
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
