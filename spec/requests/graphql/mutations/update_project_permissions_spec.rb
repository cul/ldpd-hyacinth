# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdateProjectPermissions, type: :request do
  let(:project) { FactoryBot.create(:project) }
  let(:user) { FactoryBot.create(:user) }
  let(:permission_actions) { ['read_objects', 'create_objects'] }
  let(:variables) do
    {
      input: {
        projectPermissionsUpdate: [
          {
            projectStringKey: project.string_key,
            userId: user.uid,
            actions: permission_actions
          }
        ]
      }
    }
  end

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:request) { graphql query, variables }
  end

  context 'when logged in user is project manager' do
    before do
      sign_in_project_contributor actions: :manage, projects: project
    end

    context 'when updating permissions' do
      before { graphql query, variables }

      it 'creates the expected permissions' do
        expect(Permission.where(
          user: user, subject: 'Project', subject_id: project.id
        ).pluck(:action).sort).to eq(permission_actions.sort)
      end
    end

    context 'when the "manage" action is provided' do
      let(:permission_actions) { ['manage'] }
      before { graphql query, variables }

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
            projectPermissionsUpdate: [
              {
                projectStringKey: project.string_key,
                userId: user.uid,
                actions: ['bananas']
              }
            ]
          }
        }
      end

      before { graphql query, variables }

      it 'returns error' do
        expect(response.body).to be_json_eql(%(
          "Action bananas is not allowed for a project"
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
      mutation UpdateProjectPermissions($input: UpdateProjectPermissionsInput!) {
        updateProjectPermissions(input: $input) {
          projectPermissions {
            user {
              id,
              fullName,
              sortName
            },
            project {
              stringKey
              displayLabel
            },
            actions
          }
        }
      }
    GQL
  end
end
