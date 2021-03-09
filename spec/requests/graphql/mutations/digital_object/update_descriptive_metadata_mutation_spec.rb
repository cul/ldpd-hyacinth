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
    search_params = { digital_object_type: 'ITEM' }
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
    before do
      sign_in_project_contributor to: :update_objects, project: project
      graphql query, variables
    end

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

      it "return a single item with the expected metadata fields" do
        expect(response.body).to be_json_eql("\"United States\"").at_path('data/updateDescriptiveMetadata/digitalObject/descriptiveMetadata/title/0/sort_portion')
      end

      it 'sets descriptive metadata fields' do
        expect(DigitalObject::Base.find(authorized_item.uid).descriptive_metadata).to include expected_descriptive_metadata
      end

      it 'sets identifiers' do
        expect(DigitalObject::Base.find(authorized_item.uid).identifiers.to_a).to include(*expected_identifiers)
      end

      context "when user errors are present" do
        let(:variables) do
          {
            input: {
              id: authorized_item.uid,
              descriptiveMetadata: {
                this_field_group_does_not_exist: [{ this_field_also_does_not_exist: "Invalid" }]
              }
            }
          }
        end

        it "returns a null digital object and an error of the expected format at the expected path" do
          expect(response.body).to be_json_eql(%(null)).at_path('data/updateDescriptiveMetadata/digitalObject')
          expect(response.body).to be_json_eql(%(["descriptive_metadata.this_field_group_does_not_exist"])).at_path('data/updateDescriptiveMetadata/userErrors/0/path')
          expect(response.body).to be_json_eql(%(
            "is not a valid field"
          )).at_path('data/updateDescriptiveMetadata/userErrors/0/message')
        end
      end
    end

    context "when optional optimistic lock token is provided" do
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
            identifiers: ['US'],
            optimisticLockToken: authorized_item.optimistic_lock_token
          }
        }
      end

      it "works when the token provided matches the db-stored value" do
        expect(response.body).to be_json_eql("\"United States\"").at_path('data/updateDescriptiveMetadata/digitalObject/descriptiveMetadata/title/0/sort_portion')
      end

      context "when the optimistic lock token doesn't match the expected value in the database" do
        before do
          DigitalObject::Base.find(authorized_item.uid).save # change the optimistic lock token in the db
          graphql query, variables
        end
        it "returns an error of the expected format at the expected path" do
          expect(response.body).to be_json_eql(%(null)).at_path('data/updateDescriptiveMetadata/digitalObject')
          expect(response.body).to be_json_eql(%(["optimistic_lock_token"])).at_path('data/updateDescriptiveMetadata/userErrors/0/path')
          expect(response.body).to be_json_eql(%(
            "This digital object has been updated by another process and your data is stale. Please reload and apply your changes again."
          )).at_path('data/updateDescriptiveMetadata/userErrors/0/message')
        end
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
          userErrors {
            message
            path
          }
        }
      }
    GQL
  end
end
