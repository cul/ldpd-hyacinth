# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::FieldExportProfile::UpdateFieldExportProfile, type: :request do
  let(:field_export_profile) { FactoryBot.create(:field_export_profile) }

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:variables) { { input: { id: field_export_profile.id, name: "rights" } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user is an administrator' do
    before { sign_in_user as: :administrator }

    context 'when updating name' do
      let(:variables) { { input: { id: field_export_profile.id, name: 'DescMetadata' } } }

      before { graphql query, variables }

      it 'correctly updates record' do
        field_export_profile.reload
        expect(field_export_profile.name).to eql 'DescMetadata'
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: UpdateFieldExportProfileInput!) {
        updateFieldExportProfile(input: $input) {
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
