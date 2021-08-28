# frozen_string_literal: true

require 'rails_helper'

# TODO: Update these tests because the structure of children in the graphql request has changed (now "children" instead of "structured_children")

RSpec.describe 'Retrieving Child Assets', type: :request do
  include_context 'with stubbed search adapters'
  let(:authorized_object) { FactoryBot.create(:item, :with_asset) }
  let(:authorized_project) { authorized_object.projects.first }
  let(:expected_type) { 'sequence' }
  let(:expected_child_assets) { authorized_object.children.map { |child| { 'id' => child.uid } } }
  include_examples 'requires user to have correct permissions for graphql request' do
    let(:request) { graphql query(authorized_object.uid) }
  end

  context 'logged in' do
    before do
      sign_in_project_contributor to: :read_objects, project: authorized_project
      graphql query(authorized_object.uid)
    end

    it "returns a list of digital objects with id" do
      expect(expected_child_assets).to be_present
      expect(response.body).to be_json_eql(expected_child_assets.to_json).at_path('data/childStructure/structure')
    end

    it "returns a parent digital object with id" do
      expect(response.body).to have_json_path('data/childStructure/parent/id')
      expect(response.body).to have_json_type(String).at_path('data/childStructure/parent/id')
    end

    it "returns a type for the structure" do
      expect(response.body).to be_json_eql({ type: expected_type }.to_json)
        .at_path('data/childStructure')
        .excluding('parent', 'structure')
    end
  end

  def query(id)
    <<~GQL
      query {
        childStructure(id: "#{id}") {
          parent {
            id
          },
          type,
          structure {
            id
          }
        }
      }
    GQL
  end
end
