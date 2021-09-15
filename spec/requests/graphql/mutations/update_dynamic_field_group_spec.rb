# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdateDynamicFieldGroup, type: :request do
  let(:dynamic_field_group) { FactoryBot.create(:dynamic_field_group, :with_export_rule) }

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:variables) { { input: { id: dynamic_field_group.id, displayLabel: 'Best Dynamic Field Group', sortOrder: 1, isRepeatable: true } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user has appropriate permissions' do
    before { sign_in_user as: :administrator }

    context 'when updating display label' do
      let(:variables) do
        { input: { id: dynamic_field_group.id, displayLabel: 'Best Dynamic Field Group' } }
      end

      before { graphql query, variables }

      it 'correctly updates record' do
        dynamic_field_group.reload
        expect(dynamic_field_group.display_label).to eql 'Best Dynamic Field Group'
      end
    end

    context 'when updating sort order' do
      let(:variables) do
        { input: { id: dynamic_field_group.id, sortOrder: 3 } }
      end

      before { graphql query, variables }

      it 'correctly updates record' do
        dynamic_field_group.reload
        expect(dynamic_field_group.sort_order).to be 3
      end
    end

    context 'when updating is repeatable' do
      let(:variables) do
        { input: { id: dynamic_field_group.id, isRepeatable: false } }
      end

      before { graphql query, variables }

      it 'correctly updates record' do
        dynamic_field_group.reload
        expect(dynamic_field_group.is_repeatable).to eq false
      end
    end

    context 'when updating export_rules' do
      let(:variables) do
        {
          input: {
            id: dynamic_field_group.id,
            exportRules: [
              {
                id: dynamic_field_group.export_rules.first.id,
                translationLogic: "[{}, {}]"
              }
            ]
          }
        }
      end

      before { graphql query, variables }

      it 'correctly updates record' do
        dynamic_field_group.reload
        expect(dynamic_field_group.export_rules.first.translation_logic).to eql "[\n  {\n  },\n  {\n  }\n]"
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
