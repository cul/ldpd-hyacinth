# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::FieldExportProfile::DeleteFieldExportProfile, type: :request do
  let(:field_export_profile) { FactoryBot.create(:field_export_profile) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) { { input: { id: field_export_profile.id } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user is an administrator' do
    before { sign_in_user as: :administrator }

    context 'when deleting a field_export_profile that exists' do
      let(:variables) { { input: { id: field_export_profile.id } } }
      before { graphql query, variables }

      it 'deletes record from database' do
        expect(FieldExportProfile.find_by(id: field_export_profile.id)).to be nil
      end
    end

    context 'when deleting a field_export_profile that does not exist' do
      let(:variables) { { input: { id: '123' } } }
      before { graphql query, variables }

      it 'returns errors' do
        expect(response.body).to be_json_eql(%(
          "Couldn't find FieldExportProfile with 'id'=123"
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: DeleteFieldExportProfileInput!) {
        deleteFieldExportProfile(input: $input) {
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
