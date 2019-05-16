require 'rails_helper'

RSpec.describe "Digital Objects API endpoint", type: :request do
  let(:authorized_object) { FactoryBot.create(:digital_object_test_subclass, :with_sample_data, :with_lincoln_project) }
  let(:authorized_project) { authorized_object.projects.first }
  let(:authorized_publish_target) { authorized_project.publish_targets.first }
  let(:digital_object_matcher) { having_attributes(digital_object_record: authorized_object.digital_object_record) }
  # Stub adapters to limit tests to API
  let!(:configured_publication_adapter) { Hyacinth.config.publication_adapter }
  let!(:configured_search_adapter) { Hyacinth.config.search_adapter }
  let(:publication_adapter) { instance_double(Hyacinth::Adapters::PublicationAdapter::Abstract) }
  let(:search_adapter) { instance_double(Hyacinth::Adapters::SearchAdapter::Abstract) }
  before do
    Hyacinth.config.publication_adapter = publication_adapter
    Hyacinth.config.search_adapter = search_adapter
  end
  after do
    Hyacinth.config.publication_adapter = configured_publication_adapter
    Hyacinth.config.search_adapter = configured_search_adapter
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
        expect(JSON.parse(response.body)).to include('uid' => authorized_object.uid)
      end
    end
  end

  describe 'PATCH /api/v1/digital_objects/:id' do
    # these properties vary from the existing object properties from the factory
    let(:properties) do
      {
        digital_object: {
          digital_object_data_json: {
            'dynamic_field_data' => {
              'title' => [{
                'non_sort_portion' => 'The',
                'sort_portion' => 'Short Man and His Scarf'
              }]
            }
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
        expect(JSON.parse(response.body)).to include(properties[:digital_object][:digital_object_data_json])
      end
    end
  end

  describe 'POST /api/v1/digital_objects' do
    let(:properties) do
      {
        digital_object: {
          digital_object_data_json: {
            'digital_object_type' => authorized_object.digital_object_type,
            'serialization_version' => DigitalObject::Base::SERIALIZATION_VERSION,
            'projects' => [
              {
                'string_key' => authorized_project.string_key
              }
            ],
            'dynamic_field_data' => {
              'title' => [{
                'non_sort_portion' => 'The',
                'sort_portion' => 'Short Man and His Scarf'
              }]
            }
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
        new_object = JSON.parse(response.body)
        expect(new_object['dynamic_field_data']).to include(properties[:digital_object][:digital_object_data_json]['dynamic_field_data'])
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
      end

      it 'returns 204' do
        allow(publication_adapter).to receive(:unpublish).with(authorized_publish_target, digital_object_matcher).and_return([true, []])
        allow(search_adapter).to receive(:remove).with(digital_object_matcher).and_return([true, []])
        delete "/api/v1/digital_objects/#{authorized_object.uid}"
        expect(response.status).to be 204
        get "/api/v1/digital_objects/#{authorized_object.uid}"
        expect(response.status).to be 404
      end
      it 'unpublishes the object on delete' do
        expect(publication_adapter).to receive(:unpublish).with(authorized_publish_target, digital_object_matcher).and_return([true, []])
        expect(search_adapter).to receive(:remove).with(digital_object_matcher).and_return([true, []])
        delete "/api/v1/digital_objects/#{authorized_object.uid}"
      end
      it "return blank response entity" do
        allow(publication_adapter).to receive(:unpublish).with(authorized_publish_target, digital_object_matcher).and_return([true, []])
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
        allow(publication_adapter).to receive(:update_doi).with(digital_object_matcher, anything)
      end

      it 'returns 200' do
        allow(publication_adapter).to receive(:publish).with(authorized_publish_target, digital_object_matcher, anything).and_return([true, []])
        post "/api/v1/digital_objects/#{authorized_object.uid}/publish"
        expect(response.status).to be 200
      end
      it 'publishes the object on post' do
        expect(publication_adapter).to receive(:publish).with(authorized_publish_target, digital_object_matcher, anything).and_return([true, []])
        post "/api/v1/digital_objects/#{authorized_object.uid}/publish"
      end
      it "return json entity" do
        allow(publication_adapter).to receive(:publish).with(authorized_publish_target, digital_object_matcher, anything).and_return([true, []])
        post "/api/v1/digital_objects/#{authorized_object.uid}/publish"
        new_object = JSON.parse(response.body)
        expect(new_object['projects'].first).to include('string_key' => authorized_project.string_key)
      end
    end
  end
end
