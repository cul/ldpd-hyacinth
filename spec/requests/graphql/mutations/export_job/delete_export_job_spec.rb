# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::ExportJob::DeleteExportJob, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:file_location) { Hyacinth::Config.export_job_storage.generate_new_location_uri('test-123') }
  let(:export_job) do
    exp_job = FactoryBot.create(:export_job, :success, user: user, file_location: file_location)
    Hyacinth::Config.export_job_storage.write(exp_job.file_location, 'Some content')
    exp_job
  end
  let(:id) { export_job.id }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) { { input: { id: id } } }
    let(:request) { graphql query, variables }
  end

  context 'when user is logged in' do
    before do
      login_as user, scope: :user
      export_job # create the export job
    end

    context 'when deleting an export job that exists' do
      let(:variables) { { input: { id: id } } }

      before { graphql query, variables }

      it 'deletes record from database and the associated file' do
        expect(ExportJob.find_by(id: id)).to be nil
      end

      it 'deletes the associated file' do
        expect(Hyacinth::Config.export_job_storage.exists?(file_location)).to eq(false)
      end
    end

    context "when deleting an export job that doesn't exist" do
      let(:variables) { { input: { id: '90210' } } }

      before { graphql query, variables }

      it 'returns errors' do
        expect(response.body).to be_json_eql(%(
         "Couldn't find ExportJob with 'id'=90210"
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: DeleteExportJobInput!) {
        deleteExportJob(input: $input) {
          exportJob {
            id
          }
        }
      }
    GQL
  end
end
