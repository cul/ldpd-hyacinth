# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DigitalObject::RemoveParent, type: :request do
  include_context 'with stubbed search adapters'

  let(:parent_project) { FactoryBot.create(:project) }
  let(:child_project) { FactoryBot.create(:project) }
  let(:parent) { FactoryBot.create(:item, primary_project: parent_project) }
  let(:child) { FactoryBot.create(:asset, :with_main_resource, primary_project: child_project, parents_to_add: [parent]) }
  let(:variables) { { input: { id: child.uid, parentId: parent.uid } } }

  include_examples 'a basic user with no abilities is not authorized to perform this request', 'You do not have permission to remove this parent-child relationship' do
    let(:request) { graphql query, variables }
  end

  context "when logged in user has appropriate permissions" do
    before do
      sign_in_project_contributor actions: [:update_objects], projects: [parent_project]
      graphql query, variables
      child.reload
    end

    it "returns the expected response" do
      expect(response.body).to be_json_eql("\"#{child.uid}\"").at_path('data/removeParent/digitalObject/id')
    end

    it "removes the correct parent" do
      child.reload
      expect(child.parents.length).to eq(0)
    end
  end

  def query
    <<~GQL
      mutation ($input: RemoveParentInput!) {
        removeParent(input: $input) {
          digitalObject {
            id
          }
        }
      }
    GQL
  end
end
