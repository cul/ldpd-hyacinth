# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Digital Object Rights API endpoint", type: :request do
  let(:authorized_object) { FactoryBot.create(:digital_object_test_subclass, :with_sample_data, :with_lincoln_project) }
  let(:authorized_project) { authorized_object.primary_project }
  let(:digital_object_matcher) { having_attributes(digital_object_record: authorized_object.digital_object_record) }
  let(:digital_object_search_adapter) { instance_double(Hyacinth::Adapters::DigitalObjectSearchAdapter::Abstract) }
  let!(:external_identifier_adapter) { Hyacinth::Adapters::ExternalIdentifierAdapter::Memory.new }
  before do
    # Stub adapters to limit tests to API
    allow(Hyacinth::Config).to receive(:digital_object_search_adapter).and_return(digital_object_search_adapter)
    allow(Hyacinth::Config).to receive(:external_identifier_adapter).and_return(external_identifier_adapter)
  end

  describe 'GET /api/v1/digital_objects/:id/rights' do
    include_examples 'requires user to have correct permissions' do
      let(:request) do
        get "/api/v1/digital_objects/#{authorized_object.uid}/rights"
      end
    end

    context "logged in" do
      before do
        sign_in_project_contributor to: :read_objects, project: authorized_project
        get "/api/v1/digital_objects/#{authorized_object.uid}/rights"
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end
      it "return a single Digital Object with the expected fields" do
        expect(JSON.parse(response.body)['digital_object']).to include('uid' => authorized_object.uid)
      end
      it "return a single Digital Object with the expected project fields" do
        expect(JSON.parse(response.body)['digital_object']['primary_project']).to include('has_asset_rights' => true)
      end
    end
  end

  describe 'PATCH /api/v1/digital_objects/:id/rights' do
    # these properties vary from the existing object properties from the factory
    let(:properties) do
      {
        digital_object: {
          rights: {
            descriptive_metadata: {
              type_of_content: 'architectural'
            }
          }
        }
      }
    end

    include_examples 'requires user to have correct permissions' do
      let(:request) do
        patch "/api/v1/digital_objects/#{authorized_object.uid}/rights", params: properties
      end
    end

    context "logged in" do
      before do
        sign_in_project_contributor to: [:read_objects, :assess_rights], project: authorized_project
        allow(digital_object_search_adapter).to receive(:index).with(digital_object_matcher).and_return([true, []])
        patch "/api/v1/digital_objects/#{authorized_object.uid}/rights", params: properties
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end
      it "return a single Digital Object with the expected fields" do
        expect(
          JSON.parse(response.body)['digital_object']['rights'].to_json
        ).to be_json_eql(properties[:digital_object][:rights].to_json)
      end
      context "to assess an Asset object" do
        let(:authorized_object) { DigitalObject::Base.find(authorized_item.structured_children['structure'].first) }
        let(:authorized_item) { create(:item, :with_primary_project, :with_asset) }

        context "in a project that has not enabled asset rights assessment" do
          let(:properties) do
            {
              digital_object: {
                rights: {
                  copyright_status_override: {
                    copyright_note: ['some notes']
                  }
                }
              }
            }
          end
          it 'returns 400' do
            expect(response.status).to be 400
          end
        end
        context "in a project that has enabled asset rights assessment" do
          let(:authorized_item) { create(:item, :with_primary_project_asset_rights, :with_asset) }
          let(:properties) do
            {
              digital_object: {
                rights: {
                  copyright_status_override: {
                    copyright_note: ['some notes']
                  }
                }
              }
            }
          end
          it 'returns 200' do
            expect(response.status).to be 200
          end
        end
        context "with only access control data" do
          let(:properties) do
            {
              digital_object: {
                rights: {
                  access_condition: {
                    note: ['some notes']
                  }
                }
              }
            }
          end
          it 'returns 200' do
            expect(response.status).to be 200
          end
        end
      end
    end
  end
end
