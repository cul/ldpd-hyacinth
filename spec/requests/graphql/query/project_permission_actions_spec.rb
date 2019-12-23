# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieve project permission actions', type: :request do
  include_examples 'requires user to have correct permissions for graphql request' do
    let(:request) { graphql query }
  end

  context 'when logged-in user has read permission for at least one project' do
    before do
      project = FactoryBot.create(:project)
      FactoryBot.create(:project, :legend_of_lincoln)
      sign_in_project_contributor to: :read_objects, project: project
      graphql query
    end

    it 'returns correct response' do
      expect(response.body).to be_json_eql(%({
        "projectPermissionActions": {
          "actions": [
            "read_objects",
            "create_objects",
            "update_objects",
            "delete_objects",
            "publish_objects",
            "assess_rights",
            "manage"
          ],
          "actionsDisallowedForAggregatorProjects": [
            "create_objects"
          ],
          "readObjectsAction": "read_objects",
          "manageAction": "manage"
        }
      })).at_path('data')
    end
  end

  def query
    <<~GQL
      query {
        projectPermissionActions {
          actions,
          actionsDisallowedForAggregatorProjects,
          readObjectsAction,
          manageAction
        }
      }
    GQL
  end
end
