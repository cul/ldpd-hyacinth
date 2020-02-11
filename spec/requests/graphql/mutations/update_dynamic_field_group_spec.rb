# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdateDynamicFieldGroup, type: :request do
  let(:dynamic_field_group) { FactoryBot.create(:dynamic_field_group) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) { { input: { stringKey: dynamic_field_group.string_key, displayLabel: 'Best Dynamic Field Group', sortOrder: 1, isRepeatable: true } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user has appropriate permissions' do
    before { sign_in_user as: :administrator }

    context 'when updating display label' do
      let(:variables) do
        { input: { stringKey: dynamic_field_group.string_key, displayLabel: 'Best Dynamic Field Group' } }
      end

      before { graphql query, variables }

      it 'correctly updates record' do
        dynamic_field_group.reload
        expect(dynamic_field_group.display_label).to eql 'Best Dynamic Field Group'
      end
    end
    context 'when updating sort order' do
      let(:variables) do
        { input: { stringKey: dynamic_field_group.string_key, sortOrder: 3 } }
      end

      before { graphql query, variables }

      it 'correctly updates record' do
        dynamic_field_group.reload
        expect(dynamic_field_group.sort_order).to be 3
      end
    end
    context 'when updating is repeatable' do
      let(:variables) do
        { input: { stringKey: dynamic_field_group.string_key, isRepeatable: false } }
      end

      before { graphql query, variables }

      it 'correctly updates record' do
        dynamic_field_group.reload
        expect(dynamic_field_group.is_repeatable).to eq false
      end
    end
  end
  def query
    <<~GQL
      mutation ($input: UpdateDynamicFieldGroupInput!) {
        updateDynamicFieldGroup(input: $input) {
          dynamicFieldGroup {
            displayLabel
          }
        }
      }
    GQL
  end
end
