# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdateDynamicFieldCategory, type: :request do
  let(:dynamic_field_category) { FactoryBot.create(:dynamic_field_category) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) { { input: { id: dynamic_field_category.id, displayLabel: 'Best Dynamic Field Category' } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user has appropriate permissions' do
    before { sign_in_user as: :administrator }

    context 'when updating record' do
      let(:variables) do
        { input: { id: dynamic_field_category.id, displayLabel: 'Best Dynamic Field Category' } }
      end

      before { graphql query, variables }

      it 'correctly updates record' do
        dynamic_field_category.reload
        expect(dynamic_field_category.display_label).to eql 'Best Dynamic Field Category'
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: UpdateDynamicFieldCategoryInput!) {
        updateDynamicFieldCategory(input: $input) {
          dynamicFieldCategory {
            id
          }
        }
      }
    GQL
  end
end
