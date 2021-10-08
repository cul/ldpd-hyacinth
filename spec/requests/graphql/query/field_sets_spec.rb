# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Field Sets', type: :request do
  let(:project) { FactoryBot.create(:project) }

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:request) { graphql query }
  end

  context 'when logged in user has correct permissions' do
    before { sign_in_project_contributor actions: :read_objects, projects: project }

    describe 'when there are multiple results' do
      before do
        FactoryBot.create(:field_set, project: project)
        FactoryBot.create(:field_set, display_label: 'Serial Part', project: project)
        graphql query
      end

      it 'returns all field sets' do
        expect(response.body).to be_json_eql(%(
          {
            "project": {
              "stringKey": "great_project",
              "fieldSets": [
                { "displayLabel": "Monographs" },
                { "displayLabel": "Serial Part" }
              ]
            }
          }
        )).at_path('data')
      end
    end
  end

  def query
    <<~GQL
      query {
        project(stringKey: "#{project.string_key}") {
          stringKey
          fieldSets {
            displayLabel
          }
        }
      }
    GQL
  end
end
