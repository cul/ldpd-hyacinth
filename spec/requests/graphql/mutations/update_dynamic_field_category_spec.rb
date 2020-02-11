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

    context 'when updating display label' do
      let(:variables) do
        { input: { id: dynamic_field_category.id, displayLabel: 'Best Dynamic Field Category' } }
      end

      before { graphql query, variables }

      it 'correctly updates record' do
        dynamic_field_category.reload
        expect(dynamic_field_category.display_label).to eql 'Best Dynamic Field Category'
      end
    end
    context 'when updating sort order' do
      let(:variables) do
        { input: { id: dynamic_field_category.id, sortOrder: 15 } }
      end

      before { graphql query, variables }

      it 'correctly updates record' do
        dynamic_field_category.reload
        expect(dynamic_field_category.sort_order).to be 15
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
