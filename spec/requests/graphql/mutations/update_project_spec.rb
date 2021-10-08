# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdateProject, type: :request do
  let(:project) { FactoryBot.create(:project) }

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:variables) { { input: { stringKey: project.string_key, displayLabel: 'Best Project' } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user has appropriate permissions' do
    before { sign_in_project_contributor actions: :manage, projects: project }

    context 'when updating record' do
      let(:variables) do
        { input: { stringKey: project.string_key, displayLabel: 'Best Project', projectUrl: 'https://best_project.com', hasAssetRights: true } }
      end

      before { graphql query, variables }

      it 'correctly updates record' do
        project.reload
        expect(project.display_label).to eql 'Best Project'
        expect(project.project_url).to eql 'https://best_project.com'
        expect(project.has_asset_rights).to be true
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: UpdateProjectInput!) {
        updateProject(input: $input) {
          project {
            stringKey
          }
        }
      }
    GQL
  end
end
