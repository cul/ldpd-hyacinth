# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Digital Objects', type: :request do
  let(:authorized_object) { FactoryBot.create(:item, :with_primary_project, :with_other_projects) }
  let(:authorized_project) { authorized_object.projects.first }
  context 'logged in' do
    before do
      sign_in_project_contributor to: :read_objects, project: authorized_project
      graphql query(limit: 2)
    end
    let(:expected_response) do
      %(
        [
          { "id": "#{authorized_object.uid}", "title": "The Best Item Ever", "digitalObjectType": "item" }
        ]
      )
    end

    it "return digital objects with expected fields" do
      expect(response.body).to be_json_eql(expected_response).at_path('data/digitalObjects/nodes')
    end
  end

  def query(limit:)
    <<~GQL
      query {
        digitalObjects(limit: #{limit}) {
          nodes {
            id
            title
            digitalObjectType
          }
        }
      }
    GQL
  end
end
