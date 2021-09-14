# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::FieldExportProfile::CreateFieldExportProfile, type: :request do
  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:variables) { { input: { name: "descMetadata", translationLogic: "{}" } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user is an administrator' do
    before { sign_in_user as: :administrator }

    context 'when creating a new field_export_profile' do
      let(:variables) do
        { input: { name: 'descMetadata', translationLogic: '{}' } }
      end

      let(:expected_response) do
        %(
          {
            "fieldExportProfile": {
              "name": "descMetadata",
              "translationLogic": "{\\n}"
            }
          }
        )
      end

      before { graphql query, variables }

      it 'returns correct response' do
        expect(response.body).to be_json_eql(expected_response).at_path('data/createFieldExportProfile')
      end

      it 'create field export profile' do
        expect(FieldExportProfile.find_by(name: 'descMetadata')).not_to be nil
      end
    end

    context 'when create is missing name' do
      let(:variables) { { input: {  translationLogic: '{}' } } }

      before { graphql query, variables }

      it 'returns error' do
        expect(response.body).to be_json_eql(%(
          "Variable input of type CreateFieldExportProfileInput! was provided invalid value for name (Expected value to not be null)"
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: CreateFieldExportProfileInput!) {
        createFieldExportProfile(input: $input) {
          fieldExportProfile {
            id
            name
            translationLogic
          }
        }
      }
    GQL
  end
end
