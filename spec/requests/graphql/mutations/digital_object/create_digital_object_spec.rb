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
            string_key: 'alternative_title',
            display_label: 'Alternative Title',
            is_repeatable: true,
            dynamic_fields: [
              { display_label: 'Value', sort_order: 1, string_key: 'value', field_type: DynamicField::Type::STRING }
            ]
          }
        ]
      }]
    }
  end

  before do
    Hyacinth::DynamicFieldsLoader.load_fields!(field_definitions)
    base_etf_attrs = { digital_object_type: 'item', project: project }
    dfields = [DynamicField.find_by_path_traversal(['alternative_title', 'value'])]
    dfields.each do |df|
      EnabledDynamicField.create(base_etf_attrs.merge(dynamic_field: df))
    end
  end

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:variables) do
      { input: { digitalObjectType: 'ITEM', title: { 'value' => { 'sortPortion' => 'Cool' } }, project: { stringKey: project.string_key }, descriptiveMetadata: {}, identifiers: [] } }
    end
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
            title: {
              value: {
                nonSortPortion: 'The',
                sortPortion: 'United States'
              }
            },
            descriptiveMetadata: {
              alternative_title: [{
                value: "Ain't That America?"
              }]
            },
            identifiers: ['US']
          }
        }
      end

      let(:expected_title) do
        variables[:input][:title].deep_stringify_keys
      end
      let(:expected_descriptive_metadata) do
        variables[:input][:descriptiveMetadata].deep_stringify_keys
      end
      let(:expected_identifiers) do
        variables[:input][:identifiers]
      end

      before do
        sign_in_project_contributor actions: :create_objects, projects: project
        graphql query, variables
      end

      it "returns a single item with the expected metadata fields" do
        expect(response.body).to be_json_eql("\"Ain't That America?\"").at_path('data/createDigitalObject/digitalObject/descriptiveMetadata/alternative_title/0/value')
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

      context "when title and descriptive metadata include non-ascii UTF8" do
        let(:variables) do
          {
            input: {
              digitalObjectType: 'ITEM',
              project: {
                stringKey: project.string_key
              },
              title: {
                value: {
                  sortPortion: [80, 97, 114, 97, 32, 77, 97, 99, 104, 117, 99, 97, 114, 32, 77, 101, 117, 32, 67, 111, 114, 97, 231, 227, 111].pack("U*")
                }
              },
              descriptiveMetadata: {
                alternative_title: [
                  {
                    value: [24_040, 22_823, 12_525, 12_508, 12_483, 12_488].pack("U*") # Japanese characters
                  },
                  {
                    value: [128_077, 127_875, 128_077].pack("U*") # Emoji characters
                  }
                ]
              },
              identifiers: ['US']
            }
          }
        end

        it 'sets title and descriptive metadata fields' do
          json_response = JSON.parse(response.body)
          digital_object_id = json_response.dig('data', 'createDigitalObject', 'digitalObject', 'id')
          expect(digital_object_id).not_to be_nil
          DigitalObject.find_by_uid!(digital_object_id).tap do |dobj|
            expect(dobj.title['value']['sort_portion']).to eq(expected_title['value']['sortPortion'])
            expect(dobj.descriptive_metadata).to include expected_descriptive_metadata
          end
        end
      end

      context 'when optional fields are not present' do
        let(:variables) do
          {
            input: {
              digitalObjectType: 'ITEM',
              project: {
                stringKey: project.string_key
              },
              descriptiveMetadata: {
                alternative_title: [{
                  value: "Ain't That America?"
                }]
              }
            }
          }
        end

        it 'runs without any errors' do
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
              title: {
                value: {
                  nonSortPortion: 'The',
                  sortPortion: 'United States'
                }
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
            title {
              value {
                sortPortion
              }
            }
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
