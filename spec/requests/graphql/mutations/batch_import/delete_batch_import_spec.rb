# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::BatchImport::DeleteBatchImport, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:batch_import) { FactoryBot.create(:batch_import, :with_successful_digital_object_import, user: user) }
  let(:id) { batch_import.id }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) { { input: { id: id } } }
    let(:request) { graphql query, variables }
  end

  context 'when user is logged in' do
    before do
      sign_in user
    end

    context 'when deleting an batch import that exists' do
      let(:variables) { { input: { id: id } } }

      before { graphql query, variables }

      it 'deletes record from database' do
        expect(BatchImport.find_by(id: id)).to be nil
      end
    end

    context 'when deleting a batch import with an in_progress import' do
      let(:variables) { { input: { id: id } } }

      before do
        batch_import.digital_object_imports.first.update(status: :in_progress)
        graphql query, variables
      end

      it 'returns errors' do
        expect(response.body).to be_json_eql(%(
         "Cannot destroy batch import while imports are in_progress or pending"
        )).at_path('errors/0/message')
      end
    end

    context "when deleting an batch import that doesn't exist" do
      let(:variables) { { input: { id: '90210' } } }

      before { graphql query, variables }

      it 'returns errors' do
        expect(response.body).to be_json_eql(%(
         "Couldn't find BatchImport with 'id'=90210"
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: DeleteBatchImportInput!) {
        deleteBatchImport(input: $input) {
          batchImport {
            id
          }
        }
      }
    GQL
  end
end
