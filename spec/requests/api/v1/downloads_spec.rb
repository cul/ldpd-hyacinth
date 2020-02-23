# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples "shared download examples" do
  before do
    # This shared spec requires the including context to define an adapter in a variable called adapter
    raise 'Must define variable `request_url` via `let(:request_url)`' unless defined?(request_url)
    raise 'Must define variable `expected_download_content` via `let(:expected_download_content)`' unless defined?(expected_download_content)
    raise 'Must define variable `authorized_user` via `let(:authorized_user)`' unless defined?(authorized_user)

    raise 'Must define variable `expected_content_type_header` via `let(:expected_content_type_header)`' unless defined?(expected_content_type_header)
    raise 'Must define variable `expected_content_disposition_header` via `let(:expected_content_disposition_header)`' unless defined?(expected_content_disposition_header)
    raise 'Must define variable `expected_content_length_header` via `let(:expected_content_length_header)`' unless defined?(expected_content_length_header)
    raise 'Must define variable `expected_content_last_modified_header` via `let(:expected_content_last_modified_header)`' unless defined?(expected_content_last_modified_header)
  end

  include_examples 'requires user to have correct permissions' do
    let(:request) do
      get request_url
    end
  end

  context "when user has correct permissions" do
    before do
      login_as authorized_user, scope: :user
      get request_url
    end
    it "returns the expected content" do
      expect(response.body).to eq(expected_download_content)
    end

    context "headers" do
      it 'has the correct value for header: Content-Type' do
        expect(response.header['Content-Type']).to eq(expected_content_type_header)
      end

      it 'has the correct value for header: Content-Disposition' do
        expect(response.header['Content-Disposition']).to eq(expected_content_disposition_header)
      end

      it 'has the correct value for header: Content-Length' do
        expect(response.header['Content-Length']).to eq(expected_content_length_header)
      end

      it 'has the correct value for header: Last-Modified' do
        expect(response.header['Last-Modified']).to eq(expected_content_last_modified_header)
      end
    end
  end
end

RSpec.describe "Downloads API endpoint", type: :request do
  context "for digital object resources" do
    before do
      # We don't care about solr indexing for these tests, so we'll disable it.
      allow(Hyacinth::Config.digital_object_search_adapter).to receive(:index)
    end

    let(:digital_object) do
      FactoryBot.create(:asset, :with_primary_project, :with_master_resource)
    end
    let(:resource_name) { 'master' }
    let(:request_url) { "/api/v1/downloads/digital_object/#{digital_object.uid}/#{resource_name}" }
    let(:expected_download_content) { 'What a great test file!' }
    let(:authorized_user) { create_project_contributor(to: :read_objects, project: digital_object.primary_project) }

    include_examples "shared download examples" do
      let(:expected_content_type_header) { 'text/plain' }
      let(:expected_content_disposition_header) { "attachment; ; filename*=utf-8''test.txt" }
      let(:expected_content_length_header) { expected_download_content.bytesize.to_s }
      let(:expected_content_last_modified_header) { digital_object.updated_at.httpdate }
    end

    context "when user has correct permissions" do
      before do
        login_as authorized_user, scope: :user
        get request_url
      end

      context "for an invalid digital object resource" do
        let(:resource_name) { 'definitely_not_valid' }
        it "returns 404" do
          expect(response.status).to be 404
        end
      end

      context "for a valid digital object resource that does not have an associated file" do
        let(:resource_name) { 'service' }
        it "returns 404" do
          expect(response.status).to be 404
        end
      end
    end
  end

  context "for batch exports" do
    let(:file_content) { 'the file content' }
    let(:csv_file) do
      f = Tempfile.new(['temp', '.csv'])
      f.write('the file content')
      f.flush
      f.rewind
      f
    end
    let(:file_path) do
      csv_file.path
    end
    let(:file_location) { "managed-disk://#{file_path}" }
    let(:authorized_user) { FactoryBot.create(:user, :basic) }
    let(:batch_export) { FactoryBot.create(:batch_export, :success, file_location: file_location, user: authorized_user) }
    let(:request_url) { "/api/v1/downloads/batch_export/#{batch_export.id}" }
    let(:expected_download_content) { file_content }

    include_examples "shared download examples" do
      let(:expected_content_type_header) { 'text/csv' }
      let(:expected_content_disposition_header) { "attachment; ; filename*=utf-8''export-#{batch_export.id}.csv" }
      let(:expected_content_length_header) { expected_download_content.bytesize.to_s }
      let(:expected_content_last_modified_header) { batch_export.updated_at.httpdate }
    end

    context "when user has correct permissions" do
      before do
        login_as authorized_user, scope: :user
        get request_url
      end

      context "when a csv file hasn't been generated for a batch export" do
        let(:batch_export) { FactoryBot.create(:batch_export, :in_progress, user: authorized_user) }

        it "returns 404" do
          expect(response.status).to be 404
        end
      end
    end
  end
end
