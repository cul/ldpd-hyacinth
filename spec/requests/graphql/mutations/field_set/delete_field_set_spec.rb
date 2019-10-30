require 'rails_helper'

RSpec.describe Mutations::FieldSet::DeleteFieldSet, type: :request do
  let(:project) { FactoryBot.create(:project) }
  let(:field_set) { FactoryBot.create(:field_set, project: project) }
  let(:id)        { field_set.id }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) { { input: { projectStringKey: project.string_key, id: field_set.id } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user is project manager' do
    before { sign_in_project_contributor to: :manage, project: project }

    context 'when deleting a field set that exists' do
      let(:variables) { { input: { projectStringKey: project.string_key, id: field_set.id } } }

      before { graphql query, variables }

      it 'deletes record from database' do
        expect(PublishTarget.find_by(id: id)).to be nil
      end
    end

    context 'when deleting a field set that doesn\'t exist' do
      let(:variables) { { input: { projectStringKey: project.string_key, id: '12344' } } }

      before { graphql query, variables }

      it 'returns errors' do
        expect(response.body).to be_json_eql(%(
         "Couldn't find FieldSet"
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: DeleteFieldSetInput!) {
        deleteFieldSet(input: $input) {
          fieldSet {
            id
            displayLabel
          }
        }
      }
    GQL
  end
end
