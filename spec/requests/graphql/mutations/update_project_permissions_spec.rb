# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdateProjectPermissions, type: :request do
  let(:project) { FactoryBot.create(:project) }
  let(:user) { FactoryBot.create(:user) }
  let(:permission_actions) { ['read_objects', 'create_objects'] }
  let(:variables) do
    {
      input: {
        projectPermissions: [
          {
            projectStringKey: project.string_key,
            userId: user.uid,
            permissions: permission_actions
          }
        ]
      }
    }
  end

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:request) { graphql query, variables }
  end

  context 'when logged in user is project manager' do
    before do
      sign_in_project_contributor to: :manage, project: project
    end

    context 'when updating record' do
      before { graphql query, variables }

      it 'creates the expected permissions' do
        expect(Permission.where(
          user: user, subject: 'Project', subject_id: project.id
        ).pluck(:action).sort).to eq(permission_actions.sort)
      end
    end

    context 'when the "manage" action is provided' do
      before { graphql query, variables }

      let(:permission_actions) { ['manage'] }
      it 'sets the manage permission AND all other project action types' do
        expect(Permission.where(
          user: user, subject: 'Project', subject_id: project.id, action: Permission::PROJECT_ACTIONS
        ).pluck(:action).sort).to eq(Permission::PROJECT_ACTIONS.sort)
      end
    end

    context 'when updating record with invalid permission action' do
      let(:variables) do
        {
          input: {
            projectPermissions: [
              {
                projectStringKey: project.string_key,
                userId: user.uid,
                permissions: ['bananas']
              }
            ]
          }
        }
      end

      before { graphql query, variables }

      it 'returns error' do
        expect(response.body).to be_json_eql(%(
          "Action is invalid"
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
      mutation UpdateProjectPermissions($input: UpdateProjectPermissionsInput!) {
        updateProjectPermissions(input: $input) {
          errors
        }
      }
    GQL
  end
end
