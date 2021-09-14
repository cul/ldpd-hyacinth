# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DigitalObject::AddParent, solr: true do
  subject(:graphql_request) { HyacinthSchema.execute(query, context: context, variables: variables) }
  let(:context) { { current_user: FactoryBot.create(:user), ability: ability } }
  let(:ability) { instance_double(Ability) }
  let(:parent) { FactoryBot.create(:item) }
  let(:item) { FactoryBot.create(:item) }
  let(:query) do
    <<~GQL
      mutation ($input: AddParentInput!) {
        addParent(input: $input) {
          digitalObject {
            id
          }
        }
      }
    GQL
  end
  before do
    # skipping authorization because it's not part of what we're testing
    allow(ability).to receive(:authorize!)
  end

  context 'when user has correct permissions' do
    let(:variables) { { input: { id: item.uid, parentId: parent.uid } } }
    it 'adds the correct parent' do
      graphql_request
      item.reload
      expect(item.parents.length).to eq(1)
      expect(item.parents[0].uid).to eq(parent.uid)
    end
  end
end
