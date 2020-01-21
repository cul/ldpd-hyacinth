# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Digital Object Uploads API endpoint", type: :request do
  let(:authorized_object) { FactoryBot.create(:digital_object_test_subclass, :with_sample_data, :with_lincoln_project) }
  let(:authorized_project) { authorized_object.primary_project }
  let(:digital_object_matcher) { having_attributes(digital_object_record: authorized_object.digital_object_record) }
  let(:digital_object_search_adapter) { instance_double(Hyacinth::Adapters::DigitalObjectSearchAdapter::Abstract) }
  before do
    # Stub adapters to limit tests to API
    allow(Hyacinth::Config).to receive(:digital_object_search_adapter).and_return(digital_object_search_adapter)
  end

  describe 'POST /api/v1/digital_objects/:id/uploads' do
    # these properties vary from the existing object properties from the factory
    let(:properties) do
      {
        blob: {
          signed_id: 'foo'
        }
      }
    end
    let(:attributes) do
      {
        blob: {
          filename: 'foo',
          byte_size: 1,
          checksum: 'foo',
          content_type: 'Text/Foo',
          metadata: {}
        }
      }
    end

    include_examples 'requires user to have correct permissions' do
      let(:request) do
        post "/api/v1/digital_objects/#{authorized_object.uid}/uploads", params: attributes
      end
    end

    context "logged in" do
      before do
        sign_in_project_contributor to: [:read_objects, :update_objects], project: authorized_project
        allow(digital_object_search_adapter).to receive(:index).with(digital_object_matcher).and_return([true, []])
        post "/api/v1/digital_objects/#{authorized_object.uid}/uploads", params: attributes
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end
      it "returns ActiveStorage direct upload key data" do
        response_json = JSON.parse(response.body).to_json
        expect(response_json).to have_json_path("direct_upload/headers/Content-Type")
        expect(response_json).to have_json_path("direct_upload/url")
        expect(response_json).to have_json_path("key")
        expect(response_json).to have_json_path("signed_id")
      end
    end
  end
end
