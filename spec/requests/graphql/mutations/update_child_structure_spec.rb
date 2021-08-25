# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DigitalObject::UpdateChildStructure, type: :request do
  let(:parent_item) { FactoryBot.create(:item) }
  let(:asset1) { FactoryBot.create(:asset, :with_main_resource) }
  let(:asset2) { FactoryBot.create(:asset, :with_main_resource) }

  before do
    parent_item.children_to_add << asset1
    parent_item.children_to_add << asset2
    parent_item.save
  end

  context 'when reordering the children of a digital object' do
    let :ordered_children_input do
      [
        { uid: asset1.id, sort_order: 1 },
        { uid: asset2.id, sort_order: 0 }
      ]
    end

    let(:variables) do
      { input: { parent_id: parent_item.id, ordered_children: ordered_children_input } }
    end

    before { graphql query, variables }

    it 'correctly updates order' do
      parent_item.reload
      expect(ParentChildRelationship.find_by(child_id: asset1.id).sort_order).to eq 1
      expect(ParentChildRelationship.find_by(child_id: asset2.id).sort_order).to eq 0
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
