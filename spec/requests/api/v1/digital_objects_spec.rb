# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Digital Objects API endpoint", type: :request do
  include_context 'with stubbed search adapters'
  let(:authorized_object) { FactoryBot.create(:digital_object_test_subclass, :with_sample_data) }
  let(:authorized_project) { authorized_object.projects.first }

  describe 'GET /api/v1/digital_objects/:id' do
    include_examples 'requires user to have correct permissions' do
      let(:request) do
        get "/api/v1/digital_objects/#{authorized_object.uid}"
      end
    end

    context "logged in" do
      before do
        sign_in_project_contributor actions: :read_objects, projects: authorized_project
        get "/api/v1/digital_objects/#{authorized_object.uid}"
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end
      it "return a single Digital Object with the expected fields" do
        expect(JSON.parse(response.body)['digital_object']).to include('uid' => authorized_object.uid)
      end
    end
  end

  # TODO: Replace this publish test with a GraphQL one (HYACINTH-623)
  # describe 'POST /api/v1/digital_objects/:id/publish' do
  #   include_examples 'requires user to have correct permissions' do
  #     let(:request) do
  #       post "/api/v1/digital_objects/#{authorized_object.uid}/publish"
  #     end
  #   end

  #   context "logged in" do
  #     before do
  #       allow(Hyacinth::Config).to receive(:publication_adapter).and_return(publication_adapter)
  #       allow(Hyacinth::Config).to receive(:digital_object_search_adapter).and_return(digital_object_search_adapter)
  #       sign_in_project_contributor actions: [:publish_objects, :read_objects], projects: authorized_project
  #       allow(publication_adapter).to receive(:publish).and_call_original
  #       allow(publication_adapter).to receive(:update_doi).and_call_original
  #     end

  #     let(:published_location) { "http://example.org/#{SecureRandom.uuid}" }

  #     it 'returns 200' do
  #       expect(publication_adapter).to receive(:publish_impl).with(authorized_publish_target, digital_object_matcher).and_return([true, [published_location]])
  #       post "/api/v1/digital_objects/#{authorized_object.uid}/publish"
  #       expect(response.status).to be 200
  #     end

  #     it 'publishes the object on post' do
  #       expect(publication_adapter).to receive(:publish_impl).with(authorized_publish_target, digital_object_matcher).and_return([true, [published_location]])
  #       post "/api/v1/digital_objects/#{authorized_object.uid}/publish"
  #       new_object = JSON.parse(response.body)['digital_object']
  #       expect(new_object).to have_key('publish_entries')
  #       publish_entry = new_object['publish_entries'][authorized_publish_target.combined_key]
  #       expect(publish_entry['published_at']).to be_present
  #       expect(publish_entry['citation_location']).to eql(published_location)
  #       get "/api/v1/digital_objects/#{authorized_object.uid}"
  #       old_object = JSON.parse(response.body)['digital_object']
  #       expect(old_object).to have_key('publish_entries')
  #       publish_entry = old_object['publish_entries'][authorized_publish_target.combined_key]
  #       expect(publish_entry['published_at']).to be_present
  #       expect(authorized_object.doi).to be_present
  #       # the in-memory external id adapter allows us to inspect its data
  #       doi_data_hash = external_identifier_adapter.identifiers[authorized_object.doi]
  #       expect(doi_data_hash).to be_present
  #       expect(doi_data_hash[:uid]).to eql(authorized_object.uid)
  #       expect(doi_data_hash[:target_url]).to eql(published_location)
  #       expect(doi_data_hash[:status]).to be(:active)
  #     end

  #     it "return json entity" do
  #       expect(publication_adapter).to receive(:publish_impl).with(authorized_publish_target, digital_object_matcher).and_return([true, [published_location]])
  #       post "/api/v1/digital_objects/#{authorized_object.uid}/publish"
  #       new_object = JSON.parse(response.body)['digital_object']
  #       expect(new_object['primary_project']).to include('string_key' => authorized_project.string_key)
  #     end
  #   end
  # end
end
