require 'rails_helper'

RSpec.describe "Digital Objects API endpoint", type: :request do
  let(:authorized_object) { FactoryBot.create(:digital_object_test_subclass, :with_sample_data, :with_lincoln_project) }
  let(:authorized_project) { authorized_object.projects.first }

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
        post "/api/v1/digital_objects", params: properties
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end
      it "return a single Digital Object with the expected fields" do
        new_object = JSON.parse(response.body)
        expect(new_object['dynamic_field_data']).to include(properties[:digital_object][:digital_object_data_json]['dynamic_field_data'])
        expect(new_object['projects'][0]).to include('string_key' => authorized_project.string_key)
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
        delete "/api/v1/digital_objects/#{authorized_object.uid}"
      end

      xit 'returns 200' do
        expect(response.status).to be 204
        get "/api/v1/digital_objects/#{authorized_object.uid}"
        expect(response.status).to be 404
      end
      xit "return a single Digital Object with the expected fields" do
        expect(JSON.parse(response.body)).to be_blank
      end
    end
  end
end
