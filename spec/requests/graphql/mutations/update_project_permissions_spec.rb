# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdateProjectPermissions, type: :request do
  let(:project) { FactoryBot.create(:project) }
  let(:user) { FactoryBot.create(:user) }
  let(:permission_actions) { [Permission::PROJECT_ACTION_MANAGE, Permission::PROJECT_ACTION_READ_OBJECTS] }
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
        permission_actions.each do |action|
          expect(Permission.find_by(user: user, subject: 'Project', subject_id: project.id, action: action)).to be_present
        end
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
