# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::BatchExport::DeleteBatchExport, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:file_location) { Hyacinth::Config.batch_export_storage.generate_new_location_uri('test-123') }
  let(:batch_export) do
    exp_job = FactoryBot.create(:batch_export, :success, user: user, file_location: file_location)
    Hyacinth::Config.batch_export_storage.write(exp_job.file_location, 'Some content')
    exp_job
  end
  let(:id) { batch_export.id }

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:variables) { { input: { id: id } } }
    let(:request) { graphql query, variables }
  end

  context 'when user is logged in' do
    before do
      login_as user, scope: :user
    end

    context 'when deleting an batch export that exists' do
      let(:variables) { { input: { id: id } } }

      before { graphql query, variables }

      it 'deletes record from database and the associated file' do
        expect(BatchExport.find_by(id: id)).to be nil
      end

      it 'deletes the associated file' do
        expect(Hyacinth::Config.batch_export_storage.exists?(file_location)).to eq(false)
      end
    end

    context "when deleting an batch export that doesn't exist" do
      let(:variables) { { input: { id: '90210' } } }

      before { graphql query, variables }

      it 'returns errors' do
        expect(response.body).to be_json_eql(%(
         "Couldn't find BatchExport with 'id'=90210"
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: DeleteBatchExportInput!) {
        deleteBatchExport(input: $input) {
          batchExport {
            id
          }
        }
      }
    GQL
  end
end
