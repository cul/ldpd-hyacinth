# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Updating Item Descriptive Metadata', type: :request, solr: true do
  let(:project) { FactoryBot.create(:project) }
  let(:authorized_item) { FactoryBot.create(:item, primary_project: project) }

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
    EnabledDynamicField.where(search_params).delete_all
    search_params[:project_id] = project.id
    dfields = DynamicField.where(string_key: ['non_sort_portion', 'sort_portion'])
    dfields.each do |df|
      attributes = search_params.dup
      attributes[:dynamic_field_id] = df.id
      EnabledDynamicField.create(attributes)
    end
  end

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) { { input: { id: authorized_item.uid, descriptiveMetadata: {}, identifiers: [] } } }
    let(:request) { graphql query, variables }
  end

  context "when logged in user has appropriate permissions" do
    context 'when updating field values' do
      # the descriptiveMetadata field is a JSON scalar, so below that field names are snakecase
      let(:variables) do
        {
          input: {
            id: authorized_item.uid,
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
        sign_in_project_contributor to: :update_objects, project: project
        graphql query, variables
      end

      it "return a single item with the expected metadata fields" do
        expect(response.body).to be_json_eql("\"United States\"").at_path('data/updateDescriptiveMetadata/digitalObject/descriptiveMetadata/title/0/sort_portion')
      end

      it 'sets descriptive metadata fields' do
        expect(DigitalObject::Base.find(authorized_item.uid).descriptive_metadata).to include expected_descriptive_metadata
      end

      it 'sets identifiers' do
        expect(DigitalObject::Base.find(authorized_item.uid).identifiers.to_a).to include(*expected_identifiers)
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: UpdateDescriptiveMetadataInput!) {
        updateDescriptiveMetadata(input: $input) {
          digitalObject {
            id
            descriptiveMetadata
          }
        }
      }
    GQL
  end
end
