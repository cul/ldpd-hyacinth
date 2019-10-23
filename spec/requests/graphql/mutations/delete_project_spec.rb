require 'rails_helper'

RSpec.describe Mutations::DeleteProject, type: :request do
  let(:string_key) { 'best_project' }

  before { FactoryBot.create(:project, string_key: string_key) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) { { input: { stringKey: string_key } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user has appropriate permissions' do
    before { sign_in_user as: :administrator }

    context 'when deleting a project that exists' do
      before do
        graphql query, { input: { stringKey: string_key } }
      end

      it 'deletes record from database' do
        expect(Project.find_by(string_key: string_key)).to be nil
      end
    end

    context 'when deleting a project that does not exist' do
      before { graphql query, { input: { stringKey: 'not-valid' } } }

      it 'returns errors' do
        expect(response.body).to be_json_eql(%(
          "Couldn't find Project"
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: DeleteProjectInput!) {
        deleteProject(input: $input) {
          project {
            stringKey
          }
        }
      }
    GQL
  end
end
