# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DigitalObject::CreateDigitalObject, type: :request do
  include_context 'with stubbed search adapters'
  let(:project) { FactoryBot.create(:project) }

  let(:field_definitions) do
    {
      dynamic_field_categories: [{
        display_label: "Descriptive Metadata",
        metadata_form: 'descriptive',
        dynamic_field_groups: [
          {
            string_key: 'title',
            display_label: 'Title',
            dynamic_fields: [
              { display_label: 'Non-Sort Portion', sort_order: 1, string_key: 'non_sort_portion', field_type: DynamicField::Type::STRING },
              { display_label: 'Sort Portion', sort_order: 2, string_key: 'sort_portion', field_type: DynamicField::Type::STRING }
            ]
          }
        ]
      }]
    }
  end

  before do
    Hyacinth::DynamicFieldsLoader.load_fields!(field_definitions)
    search_params = { digital_object_type: 'item' }
    search_params[:project_id] = project.id
    dfields = DynamicField.where(string_key: ['non_sort_portion', 'sort_portion'])
    dfields.each do |df|
      attributes = search_params.dup
      attributes[:dynamic_field_id] = df.id
      EnabledDynamicField.create(attributes)
    end
  end

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) { { input: { digitalObjectType: 'ITEM', project: { stringKey: project.string_key }, descriptiveMetadata: {}, identifiers: [] } } }
    let(:request) { graphql query, variables }
  end

  context "when logged in user has appropriate permissions" do
    context 'when updating field values' do
      # the descriptiveMetadata field is a JSON scalar, so below that field names are snakecase
      let(:variables) do
        {
          input: {
            digitalObjectType: 'ITEM',
            project: {
              stringKey: project.string_key
            },
            descriptiveMetadata: {
              title: [{
                non_sort_portion: "The",
                sort_portion: "United States"
              }]
            },
            identifiers: ['US']
          }
        }
      end

      let(:expected_descriptive_metadata) do
        variables[:input][:descriptiveMetadata].deep_stringify_keys
      end
      let(:expected_identifiers) do
        variables[:input][:identifiers]
      end

      before do
        sign_in_project_contributor to: :create_objects, project: project
        graphql query, variables
      end

      it "returns a single item with the expected metadata fields" do
        expect(response.body).to be_json_eql("\"United States\"").at_path('data/createDigitalObject/digitalObject/descriptiveMetadata/title/0/sort_portion')
      end

      it 'sets descriptive metadata fields' do
        json_response = JSON.parse(response.body)
        digital_object_id = json_response.dig('data', 'createDigitalObject', 'digitalObject', 'id')
        expect(digital_object_id).not_to be_nil
        expect(DigitalObject.find_by_uid!(digital_object_id).descriptive_metadata).to include expected_descriptive_metadata
      end

      it 'sets identifiers' do
        json_response = JSON.parse(response.body)
        digital_object_id = json_response.dig('data', 'createDigitalObject', 'digitalObject', 'id')
        expect(digital_object_id).not_to be_nil
        expect(DigitalObject.find_by_uid!(digital_object_id).identifiers.to_a).to include(*expected_identifiers)
      end

      context "when metadata includes non-ascii UTF8" do
        let(:variables) do
          {
            input: {
              digitalObjectType: 'ITEM',
              project: {
                stringKey: project.string_key
              },
              descriptiveMetadata: {
                title: [{
                  sort_portion: [80, 97, 114, 97, 32, 77, 97, 99, 104, 117, 99, 97, 114, 32, 77, 101, 117, 32, 67, 111, 114, 97, 231, 227, 111].pack("U*")
                }]
              },
              identifiers: ['US']
            }
          }
        end

        it 'sets descriptive metadata fields' do
          json_response = JSON.parse(response.body)
          digital_object_id = json_response.dig('data', 'createDigitalObject', 'digitalObject', 'id')
          expect(digital_object_id).not_to be_nil
          expect(DigitalObject.find_by_uid!(digital_object_id).descriptive_metadata).to include expected_descriptive_metadata
        end
      end

      context "when user errors are present" do
        let(:variables) do
          {
            input: {
              digitalObjectType: 'ITEM',
              project: {
                stringKey: project.string_key
              },
              descriptiveMetadata: {
                this_field_group_does_not_exist: [{ this_field_also_does_not_exist: "Invalid" }]
              },
              identifiers: ['US']
            }
          }
        end

        it "returns a null digital object and an error of the expected format at the expected path" do
          expect(response.body).to be_json_eql(%(null)).at_path('data/createDigitalObject/digitalObject')
          expect(response.body).to be_json_eql(%(["this_field_group_does_not_exist/this_field_also_does_not_exist"])).at_path('data/createDigitalObject/userErrors/0/path')
          expect(response.body).to be_json_eql(%(
            "field must be enabled"
          )).at_path('data/createDigitalObject/userErrors/0/message')
        end
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: CreateDigitalObjectInput!) {
        createDigitalObject(input: $input) {
          digitalObject {
            id
            descriptiveMetadata
          }
          userErrors {
            message
            path
          }
        }
      }
    GQL
  end
end
