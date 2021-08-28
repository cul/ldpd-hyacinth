# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Facet Values', type: :request, solr: true do
  let!(:authorized_object) { FactoryBot.create(:item, :with_ascii_title, :with_other_projects) }
  let!(:authorized_project) { authorized_object.projects.first }
  let!(:unauthorized_project) { FactoryBot.create(:project, string_key: 'other_project', display_label: 'Another Project') }
  let!(:unauthorized_object) do
    FactoryBot.create(
      :item,
      'primary_project' => unauthorized_project,
      'title' => {
        'non_sort_portion' => 'The',
        'sort_portion' => 'Other Pretty Great Item'
      }
    )
  end
  context 'logged in non-admin user' do
    before do
      sign_in_project_contributor to: :read_objects, project: authorized_project
      graphql(query, search_params)
    end
    let(:search_params) { { fieldName: 'primary_project_ssi', limit: 2, searchParams: {}, orderBy: { field: 'COUNT' } } }
    let(:expected_response) do
      %(
        [
          { "value": "#{authorized_object.primary_project.string_key}", "count": 1 }
        ]
      )
    end

    it "returns only the readable digital object, with expected fields" do
      expect(response.body).to be_json_eql(expected_response).at_path('data/facetValues/nodes')
    end
  end

  context 'logged in admin user' do
    before do
      sign_in_user as: :administrator
      graphql(query, search_params)
    end
    context "with no search type or query defined" do
      let(:search_params) { { fieldName: 'primary_project_ssi', limit: 2, searchParams: {}, orderBy: { field: 'COUNT' } } }
      let(:expected_response) do
        %(
          [
            { "value": "#{authorized_object.primary_project.string_key}", "count": 1 },
            { "value": "#{unauthorized_object.primary_project.string_key}", "count": 1 }
          ]
        )
      end

      it "returns all objects, with expected fields" do
        expect(response.body).to be_json_eql(expected_response).at_path('data/facetValues/nodes')
      end
    end
    context "with a search type and query" do
      let(:search_params) { { fieldName: 'primary_project_ssi', limit: 2, searchParams: { searchType: 'TITLE', searchTerms: 'Pretty Great' }, orderBy: { field: 'COUNT' } } }
      let(:expected_response) do
        %(
          [
            { "value": "#{unauthorized_object.primary_project.string_key}", "count": 1 }
          ]
        )
      end

      it "returns matching objects, with expected fields" do
        expect(response.body).to be_json_eql(expected_response).at_path('data/facetValues/nodes')
      end
    end
  end
  def query
    <<~GQL
      query($fieldName: String!, $limit: Limit!, $searchParams: SearchAttributes!, $orderBy: FacetOrderByInput!) {
        facetValues(fieldName: $fieldName, limit: $limit, searchParams: $searchParams, orderBy: $orderBy) {
          nodes {
            value
            count
          }
        }
      }
    GQL
  end
end
