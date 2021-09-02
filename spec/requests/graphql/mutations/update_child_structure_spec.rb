# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DigitalObject::UpdateChildStructure, type: :request, solr: true do
  let(:parent_item) { FactoryBot.create(:item) }
  let(:asset1) { FactoryBot.create(:asset, :with_main_resource) }
  let(:asset2) { FactoryBot.create(:asset, :with_main_resource) }

  before do
    parent_item.children_to_add << asset1
    parent_item.children_to_add << asset2
    parent_item.save
  end

  let :ordered_children_input do
    [
      { uid: asset1.uid, sortOrder: 1 },
      { uid: asset2.uid, sortOrder: 0 }
    ]
  end

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) { { input: { parentUid: parent_item.uid, orderedChildren: ordered_children_input } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user is an administrator' do
    before { sign_in_user as: :administrator }

    context 'when reordering with real values the children of a digital object' do
      let(:variables) { { input: { parentUid: parent_item.uid, orderedChildren: ordered_children_input } } }
      before { graphql query, variables }

      it 'correctly updates order' do
        expect(ParentChildRelationship.find_by(child_id: asset1.id).sort_order).to eq 1
        expect(ParentChildRelationship.find_by(child_id: asset2.id).sort_order).to eq 0
      end
    end
    context 'when ordered children input contains no values' do
      let(:ordered_children_input) { [] }
      let(:variables) { { input: { parentUid: parent_item.uid, orderedChildren: ordered_children_input } } }
      before { graphql query, variables }

      it 'child order values are not modified' do
        expect(ParentChildRelationship.find_by(child_id: asset1.id).sort_order).to eq 0
        expect(ParentChildRelationship.find_by(child_id: asset2.id).sort_order).to eq 1
      end
    end
  end

  def query
    <<~GQL
    mutation ($input: UpdateChildStructureInput!) {
      updateChildStructure(input: $input) {
        parent {
          id
        }
      }
    }
    GQL
  end
end
