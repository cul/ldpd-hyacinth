# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Digital Objects', type: :request, solr: true do
  let!(:authorized_object) { FactoryBot.create(:item, :with_ascii_title, :with_other_projects) }
  let!(:authorized_project) { authorized_object.projects.first }
  let!(:unauthorized_project) { FactoryBot.create(:project, string_key: 'a', display_label: 'A') }
  let!(:unauthorized_object) do
    dynamic_fields = DynamicFieldsHelper.load_title_fields! # Adding dynamic fields used in descriptive metadata. Validations will fail if these field definitions aren't present.
    DynamicFieldsHelper.enable_dynamic_fields(:item, unauthorized_project, dynamic_fields)
    FactoryBot.create(
      :item,
      'primary_project' => unauthorized_project,
      'descriptive_metadata' => {
        'title' => [
          {
            'non_sort_portion' => 'The',
            'sort_portion' => 'Other Pretty Great Item'
          }
        ]
      }
    )
  end
  context 'logged in non-admin user' do
    before do
      sign_in_project_contributor to: :read_objects, project: authorized_project
      graphql(query, search_params)
    end
    let(:search_params) { { limit: 2, searchParams: {} } }
    let(:expected_response) do
      %(
        [
          { "id": "#{authorized_object.uid}", "title": "The Best Item Ever", "digitalObjectType": "ITEM" }
        ]
      )
    end

    it "returns only the readable digital object, with expected fields" do
      expect(response.body).to be_json_eql(expected_response).at_path('data/digitalObjects/nodes')
    end
  end

  context 'logged in admin user' do
    before do
      sign_in_user as: :administrator
      graphql(query, search_params)
    end
    context "with no search type or query defined" do
      let(:search_params) { { limit: 2, searchParams: {} } }
      let(:expected_response) do
        %(
          [
            { "id": "#{authorized_object.uid}", "title": "The Best Item Ever", "digitalObjectType": "ITEM" },
            { "id": "#{unauthorized_object.uid}", "title": "The Other Pretty Great Item", "digitalObjectType": "ITEM" }
          ]
        )
      end

      it "returns all objects, with expected fields" do
        expect(response.body).to be_json_eql(expected_response).at_path('data/digitalObjects/nodes')
      end
    end
    context "with a search type and query" do
      let(:search_params) { { limit: 2, searchParams: { searchType: 'TITLE', searchTerms: 'Pretty Great' } } }
      let(:expected_response) do
        %(
          [
            { "id": "#{unauthorized_object.uid}", "title": "The Other Pretty Great Item", "digitalObjectType": "ITEM" }
          ]
        )
      end

      it "returns all objects, with expected fields" do
        expect(response.body).to be_json_eql(expected_response).at_path('data/digitalObjects/nodes')
      end
    end
  end
  def query
    <<~GQL
      query($limit: Limit!, $searchParams: SearchAttributes!) {
        digitalObjects(limit: $limit, searchParams: $searchParams) {
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
