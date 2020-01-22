# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdateDynamicFieldGroup, type: :request do
  let(:dynamic_field_group) { FactoryBot.create(:dynamic_field_group) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) do
      { input: { 
        stringKey: dynamic_field_group.string_key, 
        displayLabel: 'Best Dynamic Field Group',
        sortOrder: 1,
        isRepeatable: true,
        parentId: 1,
        parentType: 'DynamicFieldCategory' 
        } 
      }
    end
    let(:request) { graphql query, variables }
  end

  context 'when logged in user has appropriate permissions' do
    before { sign_in_user as: :administrator }

    context 'when updating record' do
      let(:variables) do
        { input: { 
          stringKey: dynamic_field_group.string_key, 
          displayLabel: 'Best Dynamic Field Group',
          sortOrder: 1,
          isRepeatable: true,
          parentId: 1,
          parentType: 'DynamicFieldCategory' 
          } 
        }
      end

      before { 
        graphql query, variables 
        puts response.body
      }

      it 'correctly updates record' do
        dynamic_field_group.reload
        expect(dynamic_field_group.display_label).to eql 'Best Dynamic Field Group'
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
