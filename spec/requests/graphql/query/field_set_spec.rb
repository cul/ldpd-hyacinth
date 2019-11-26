# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Field Set', type: :request do
  let(:project) { FactoryBot.create(:project) }
  let(:field_set) { FactoryBot.create(:field_set, project: project) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:request) { graphql query(field_set.id) }
  end

  context 'when logged in user has correct permissions' do
    before { sign_in_project_contributor to: :read_objects, project: project }

    context 'when id is valid' do
      before { graphql query(field_set.id) }

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%({
          "project": {
            "stringKey": "great_project",
            "fieldSet": { "displayLabel": "Monographs" }
          }
        })).at_path('data')
      end
    end

    context 'when id is invalid' do
      before { graphql query('invalid-id') }

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%(
          "Couldn't find FieldSet"
        )).at_path('errors/0/message')
      end
    end
  end

  def query(id)
    <<~GQL
      query {
        project(stringKey: "#{project.string_key}") {
          stringKey
          fieldSet(id: "#{id}") {
            displayLabel
          }
        }
      }
    GQL
  end
end
