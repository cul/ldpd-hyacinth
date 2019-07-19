require 'rails_helper'

RSpec.describe "Digital Objects API endpoint", type: :request do
  let(:authorized_object) { FactoryBot.create(:digital_object_test_subclass, :with_sample_data, :with_lincoln_project) }
  let(:authorized_project) { authorized_object.projects.first }
  let(:authorized_publish_target) { authorized_project.publish_targets.first }
  let(:digital_object_matcher) { having_attributes(digital_object_record: authorized_object.digital_object_record) }
  # Stub adapters to limit tests to API
  let!(:configured_publication_adapter) { Hyacinth.config.publication_adapter }
  let!(:configured_search_adapter) { Hyacinth.config.search_adapter }
  let!(:configured_external_identifier_adapter) { Hyacinth.config.external_identifier_adapter }
  let(:publication_adapter) { Hyacinth::Adapters::PublicationAdapter::Abstract.new }
  let(:search_adapter) { instance_double(Hyacinth::Adapters::SearchAdapter::Abstract) }
  let!(:external_identifier_adapter) { Hyacinth::Adapters::ExternalIdentifierAdapter::Memory.new }
  before do
    Hyacinth.config.publication_adapter = publication_adapter
    Hyacinth.config.search_adapter = search_adapter
    Hyacinth.config.external_identifier_adapter = external_identifier_adapter
  end
  after do
    Hyacinth.config.publication_adapter = configured_publication_adapter
    Hyacinth.config.search_adapter = configured_search_adapter
    Hyacinth.config.external_identifier_adapter = configured_external_identifier_adapter
  end

  describe 'GET /api/v1/digital_objects/:id' do
    include_examples 'requires user to have correct permissions' do
      let(:request) do
        get "/api/v1/digital_objects/#{authorized_object.uid}"
      end
    end

    context "logged in" do
      before do
        sign_in_project_contributor to: :read_objects, project: authorized_project
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

  describe 'PATCH /api/v1/digital_objects/:id' do
    # these properties vary from the existing object properties from the factory
    let(:properties) do
      {
        digital_object: {
          dynamic_field_data: {
            title: [{
              non_sort_portion: 'The',
              sort_portion: 'Short Man and His Scarf'
            }]
          }
        }
      }
    end

    include_examples 'requires user to have correct permissions' do
      let(:request) do
        patch "/api/v1/digital_objects/#{authorized_object.uid}", params: properties
      end
    end

    context "logged in" do
      before do
        sign_in_project_contributor to: :update_objects, project: authorized_project
        allow(search_adapter).to receive(:index).with(digital_object_matcher).and_return([true, []])
        patch "/api/v1/digital_objects/#{authorized_object.uid}", params: properties
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end
      it "return a single Digital Object with the expected fields" do
        expect(
          JSON.parse(response.body)['digital_object']['dynamic_field_data'].to_json
        ).to be_json_eql(properties[:digital_object][:dynamic_field_data].to_json)
      end
    end
  end

  describe 'POST /api/v1/digital_objects' do
    let(:properties) do
      {
        digital_object: {
          digital_object_type: authorized_object.digital_object_type,
          serialization_version: DigitalObject::Base::SERIALIZATION_VERSION,
          projects: [
            {
              string_key: authorized_project.string_key
            }
          ],
          dynamic_field_data: {
            title: [{
              non_sort_portion: 'The',
              sort_portion: 'Short Man and His Scarf'
            }]
          }
        }
      }
    end

    include_examples 'requires user to have correct permissions' do
      let(:request) do
        post "/api/v1/digital_objects", params: properties
      end
    end

    context "logged in" do
      before do
        sign_in_project_contributor to: :create_objects, project: authorized_project
        allow(search_adapter).to receive(:index).with(instance_of(DigitalObject::TestSubclass)).and_return([true, []])
        post "/api/v1/digital_objects", params: properties
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end
      it "return a single Digital Object with the expected fields" do
        new_object = JSON.parse(response.body)['digital_object']
        expect(
          new_object['dynamic_field_data'].to_json
        ).to be_json_eql(properties[:digital_object][:dynamic_field_data].to_json)
        expect(new_object['projects'].first).to include('string_key' => authorized_project.string_key)
      end
    end
  end

  describe 'DELETE /api/v1/digital_objects/:id' do
    include_examples 'requires user to have correct permissions' do
      let(:request) do
        delete "/api/v1/digital_objects/#{authorized_object.uid}"
      end
    end

    context "logged in" do
      before do
        sign_in_project_contributor to: [:delete_objects, :read_objects], project: authorized_project
        allow(publication_adapter).to receive(:unpublish).and_call_original
        allow(publication_adapter).to receive(:update_doi).and_call_original
      end

      it 'returns 204' do
        allow(publication_adapter).to receive(:unpublish_impl).with(authorized_publish_target, digital_object_matcher).and_return([true, []])
        allow(search_adapter).to receive(:remove).with(digital_object_matcher).and_return([true, []])
        delete "/api/v1/digital_objects/#{authorized_object.uid}"
        expect(response.status).to be 204
        get "/api/v1/digital_objects/#{authorized_object.uid}"
        expect(response.status).to be 404
      end
      it 'unpublishes the object on delete' do
        expect(publication_adapter).to receive(:unpublish_impl).with(authorized_publish_target, digital_object_matcher).and_return([true, []])
        expect(search_adapter).to receive(:remove).with(digital_object_matcher).and_return([true, []])
        delete "/api/v1/digital_objects/#{authorized_object.uid}"
      end
      it "return blank response entity" do
        allow(publication_adapter).to receive(:unpublish_impl).with(authorized_publish_target, digital_object_matcher).and_return([true, []])
        allow(search_adapter).to receive(:remove).with(digital_object_matcher).and_return([true, []])
        delete "/api/v1/digital_objects/#{authorized_object.uid}"
        expect(response.body).to be_blank
      end
    end
  end

  describe 'POST /api/v1/digital_objects/:id/publish' do
    include_examples 'requires user to have correct permissions' do
      let(:request) do
        post "/api/v1/digital_objects/#{authorized_object.uid}/publish"
      end
    end

    context "logged in" do
      before do
        Hyacinth.config.publication_adapter = publication_adapter
        Hyacinth.config.search_adapter = search_adapter
        sign_in_project_contributor to: [:publish_objects, :read_objects], project: authorized_project
        allow(publication_adapter).to receive(:publish).and_call_original
        allow(publication_adapter).to receive(:update_doi).and_call_original
      end

      let(:published_location) { "http://example.org/#{SecureRandom.uuid}" }

      it 'returns 200' do
        expect(publication_adapter).to receive(:publish_impl).with(authorized_publish_target, digital_object_matcher).and_return([true, [published_location]])
        post "/api/v1/digital_objects/#{authorized_object.uid}/publish"
        expect(response.status).to be 200
      end

      it 'publishes the object on post' do
        expect(publication_adapter).to receive(:publish_impl).with(authorized_publish_target, digital_object_matcher).and_return([true, [published_location]])
        post "/api/v1/digital_objects/#{authorized_object.uid}/publish"
        new_object = JSON.parse(response.body)['digital_object']
        expect(new_object).to have_key('publish_entries')
        publish_entry = new_object['publish_entries'][authorized_publish_target.string_key]
        expect(publish_entry['published_at']).to be_present
        expect(publish_entry['cited_at']).to eql(published_location)
        get "/api/v1/digital_objects/#{authorized_object.uid}"
        old_object = JSON.parse(response.body)['digital_object']
        expect(old_object).to have_key('publish_entries')
        publish_entry = old_object['publish_entries'][authorized_publish_target.string_key]
        expect(publish_entry['published_at']).to be_present
        expect(authorized_object.doi).to be_present
        # the in-memory external id adapter allows us to inspect its data
        doi_data_hash = external_identifier_adapter.identifiers[authorized_object.doi]
        expect(doi_data_hash).to be_present
        expect(doi_data_hash[:location_uri]).to eql(published_location)
        expect(doi_data_hash[:status]).to be(:active)
      end

      it "return json entity" do
        expect(publication_adapter).to receive(:publish_impl).with(authorized_publish_target, digital_object_matcher).and_return([true, [published_location]])
        post "/api/v1/digital_objects/#{authorized_object.uid}/publish"
        new_object = JSON.parse(response.body)['digital_object']
        expect(new_object['projects'].first).to include('string_key' => authorized_project.string_key)
      end
    end
  end
end
