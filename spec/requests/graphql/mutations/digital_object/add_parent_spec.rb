# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DigitalObject::AddParent, type: :request do
  include_context 'with stubbed search adapters'

  let(:parent_project) { FactoryBot.create(:project) }
  let(:child_project) { FactoryBot.create(:project) }
  let(:parent) { FactoryBot.create(:item, primary_project: parent_project) }
  let(:child) { FactoryBot.create(:asset, :with_main_resource, primary_project: child_project) }
  let(:variables) { { input: { id: child.uid, parentId: parent.uid } } }

  include_examples 'a basic user with no abilities is not authorized to perform this request', 'You do not have permission to add the specified parent-child relationship' do
    let(:request) { graphql query, variables }
  end

  context "when logged in user has appropriate permissions" do
    before do
      sign_in_project_contributor actions: [:read_objects, :update_objects], projects: [parent_project, child_project]
      graphql query, variables
      child.reload
    end

    it "returns the expected response" do
      expect(response.body).to be_json_eql("\"#{child.uid}\"").at_path('data/addParent/digitalObject/id')
    end

    it "adds the correct parent" do
      expect(child.parents.length).to eq(1)
      expect(child.parents[0].uid).to eq(parent.uid)
    end
  end

  def query
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
end
