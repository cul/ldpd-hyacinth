# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdateDynamicField, type: :request do
  let(:dynamic_field) { FactoryBot.create(:dynamic_field) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) { { input: { id: dynamic_field.id, displayLabel: 'New Location' } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user is an administrator' do
    before { sign_in_user as: :administrator }

    context 'when updating display_label' do
      let(:variables) do
        {
          input: {
            id: dynamic_field.id,
            displayLabel: 'New Location'
          }
        }
      end

      before { graphql query, variables }
      it 'correctly updates record' do
        dynamic_field.reload
        expect(dynamic_field.display_label).to eql 'New Location'
      end
    end

    context 'when updating controlled vocabulary' do
      let(:variables) do
        {
          input: {
            id: dynamic_field.id,
            controlledVocabulary: 'vocabulary2'
          }
        }
      end

      before { graphql query, variables }
      it 'correctly updates record' do
        dynamic_field.reload
        expect(dynamic_field.controlled_vocabulary).to eql 'vocabulary2'
      end
    end

    context 'when updating select options' do
      let(:variables) do
        {
          input: {
            id: dynamic_field.id,
            selectOptions: '[{"value":"val1","label":"Value 1"}, {"value":"val2","label":"Value 2"}]'
          }
        }
      end

      before { graphql query, variables }
      it 'correctly updates record' do
        dynamic_field.reload
        expect(dynamic_field.select_options).to eql '[{"value":"val1","label":"Value 1"}, {"value":"val2","label":"Value 2"}]'
      end
    end

    context 'when updating is title searchable' do
      let(:variables) do
        {
          input: {
            id: dynamic_field.id,
            isTitleSearchable: true
          }
        }
      end

      before { graphql query, variables }
      it 'correctly updates record' do
        dynamic_field.reload
        expect(dynamic_field.is_title_searchable).to be true
      end
    end

    context 'when updating to incorrect field type' do
      let(:variables) do
        {
          input: {
            id: dynamic_field.id,
            displayLabel: 'New Location',
            fieldType: 'not-valid'
          }
        }
      end

      before { graphql query, variables }
      it 'returns errors' do
        expect(response.body).to be_json_eql(%(
          "Field type is not among the list of allowed values"
        )).at_path('errors/0/message')
      end
    end
  end
  def query
    <<~GQL
    mutation ($input: UpdateDynamicFieldInput!) {
      updateDynamicField(input: $input) {
        dynamicField {
          controlledVocabulary,
          displayLabel,
          fieldType,
          filterLabel,
          isFacetable,
          isIdentifierSearchable,
          isKeywordSearchable,
          isTitleSearchable,
          selectOptions,
          sortOrder,
          stringKey,
          type: __typename,
        }
      }
    }
    GQL
  end
end
